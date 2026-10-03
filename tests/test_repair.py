"""Regression checks for bounded lexical repair and compiler preservation."""

import copy
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from lift_tools.common import save
from lift_tools.repair import (
    load_rules,
    preservation,
    propose_rules,
    rewrite_identifiers,
)


class RepairTests(unittest.TestCase):
    def test_lexical_rewrite_preserves_comments_strings_and_longer_names(self):
        source = 'import Old.Module\n-- Old.Module\n/- Old.Module /- Old.Module -/ -/\ndef text := "Old.Module"\n#check Old.Module\n#check Old.ModuleX\n#check «Old.Module»\n'
        result = rewrite_identifiers(source, {"Old.Module": "New.Module"})
        self.assertEqual(result.count("New.Module"), 2)
        self.assertEqual(result.count("Old.Module"), 6)

    def test_type_definition_and_trust_drift_fail(self):
        before = {
            "records": [
                {
                    "declaration_key": "Demo::x",
                    "kind": "def",
                    "type": "Nat",
                    "definition_value": "3",
                    "axioms": [],
                }
            ]
        }
        self.assertTrue(preservation(before, before)["passed"])
        for field, value in [
            ("type", "Int"),
            ("definition_value", "4"),
            ("axioms", ["sorryAx"]),
            ("is_unsafe", True),
            ("kind", "axiom"),
        ]:
            after = copy.deepcopy(before)
            after["records"][0][field] = value
            self.assertFalse(preservation(before, after)["passed"])

    def test_changed_proof_dependency_is_reported(self):
        before = {
            "records": [
                {
                    "declaration_key": "Demo::x",
                    "type": "True",
                    "value_dependencies": ["a"],
                    "axioms": [],
                }
            ]
        }
        after = copy.deepcopy(before)
        after["records"][0]["value_dependencies"] = ["b"]
        result = preservation(before, after)
        self.assertTrue(result["passed"])
        self.assertEqual(result["dependency_changes"], ["Demo::x"])

    def test_rules_are_version_bound_and_cannot_insert_sorry(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "rules.json"
            save(
                path,
                {
                    "schema": "lift.migration-rules.v1",
                    "source_toolchain": "a",
                    "target_toolchain": "b",
                    "replacements": [{"old": "x", "new": "sorry", "reason": "invalid"}],
                },
            )
            with self.assertRaises(ValueError):
                load_rules(path, "a", "b")
            with self.assertRaises(ValueError):
                load_rules(path, "other", "b")


class ModelRepairTests(unittest.TestCase):
    def proposal(self, old="Old.Module", new="New.Module"):
        return {
            "schema": "lift.migration-rules.v1",
            "source_toolchain": "a",
            "target_toolchain": "b",
            "replacements": [{"old": old, "new": new, "reason": "Moved import"}],
        }

    def invoke(self, proposal):
        class Provider:
            def call(self, request):
                assert request["role"] == "migration_repair"
                assert "import Old.Module" in request["sources"]["Demo.lean"]
                return proposal

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "Demo.lean").write_text("import Old.Module\n")
            return propose_rules(
                Provider(),
                "a",
                "b",
                "unknown module Old.Module",
                root,
                {"Demo.lean"},
                root,
            )

    def test_model_repair_is_exact_diagnostic_bound_identifier(self):
        self.assertEqual(self.invoke(self.proposal())[0]["new"], "New.Module")

    def test_model_cannot_supply_code_or_unrelated_rename(self):
        for proposal in (
            self.proposal(new="sorry"),
            self.proposal(new="x := by sorry"),
            self.proposal(old="Unrelated"),
            {**self.proposal(), "files": {}},
        ):
            with self.subTest(proposal=proposal), self.assertRaises(ValueError):
                self.invoke(proposal)

    def test_explicit_no_safe_repair_is_preserved(self):
        proposal = self.proposal()
        proposal["replacements"] = []
        self.assertEqual(self.invoke(proposal), [])


if __name__ == "__main__":
    unittest.main()
