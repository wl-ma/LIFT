"""Regression checks for migration isolation and evidence boundary handling."""

from __future__ import annotations

import copy
import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "upgrade", ROOT / "tools/toolchain/upgrade.py"
)
UPGRADE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(UPGRADE)


def bundle() -> dict:
    return {
        "schema": "lift.compiler-facts.v1",
        "records": [
            {
                "declaration_key": "Fixture::Demo.value",
                "kind": "def",
                "type": "Nat",
                "definition_value": "3",
                "axioms": [],
                "is_unsafe": False,
                "is_partial": False,
                "constructors": [],
                "structure_fields": [],
            }
        ],
    }


class ComparisonTests(unittest.TestCase):
    def test_definition_drift_is_reported(self) -> None:
        before, after = bundle(), bundle()
        after["records"][0]["definition_value"] = "4"
        result = UPGRADE.compare(before, after)
        self.assertEqual(result["status"], "review_required")
        self.assertEqual(result["changed"][0]["fields"], ["definition_value"])

    def test_new_axiom_is_not_treated_as_preserved(self) -> None:
        before, after = bundle(), bundle()
        after["records"][0]["axioms"] = ["sorryAx"]
        self.assertEqual(UPGRADE.compare(before, after)["status"], "review_required")

    def test_missing_and_duplicate_declarations(self) -> None:
        before, after = bundle(), bundle()
        extra = copy.deepcopy(before["records"][0])
        extra["declaration_key"] = "Fixture::Demo.other"
        before["records"].append(extra)
        self.assertEqual(
            UPGRADE.compare(before, after)["missing"], ["Fixture::Demo.other"]
        )
        after["records"] = []
        with self.assertRaises(ValueError):
            UPGRADE.compare(before, after)
        after = bundle()
        after["records"].append(copy.deepcopy(after["records"][0]))
        with self.assertRaises(ValueError):
            UPGRADE.compare(before, after)

    def test_changed_declaration_kind_requires_review(self) -> None:
        before, after = bundle(), bundle()
        after["records"][0]["kind"] = "opaque"
        self.assertEqual(UPGRADE.compare(before, after)["status"], "review_required")

    def test_empty_baseline_cannot_claim_preservation(self) -> None:
        before = bundle()
        before["records"] = []
        with self.assertRaises(ValueError):
            UPGRADE.compare(before, bundle())


class PreparationTests(unittest.TestCase):
    def test_isolation_and_explicit_mathlib_pin(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source, target = root / "source", root / "candidate"
            source.mkdir()
            (source / "lean-toolchain").write_text("leanprover/lean4:v4.26.0\n")
            config = (
                'name = "demo"\n[[require]]\nname = "mathlib"\n'
                'git = "https://github.com/leanprover-community/mathlib4.git"\n'
                'rev = "' + "a" * 40 + '"\n[[lean_lib]]\nname = "Demo"\n'
            )
            (source / "lakefile.toml").write_text(config)
            (source / "Demo.lean").write_text("def answer : Nat := 42\n")
            (source / "lake-manifest.json").write_text("{}")
            (source / ".env").write_text("EXAMPLE_PRIVATE_CONFIG=not-a-real-key")
            with self.assertRaises(ValueError):
                UPGRADE.prepare(source, target, "leanprover/lean4:v4.30.0", None)
            self.assertFalse(target.exists())
            report = UPGRADE.prepare(
                source, target, "leanprover/lean4:v4.30.0", "b" * 40
            )
            self.assertEqual(report["status"], "prepared_not_built")
            self.assertEqual(
                (source / "lakefile.toml").read_text(encoding="utf-8"), config
            )
            self.assertFalse((target / ".env").exists())
            self.assertFalse((target / "lake-manifest.json").exists())
            self.assertIn(
                "b" * 40, (target / "lakefile.toml").read_text(encoding="utf-8")
            )
            self.assertIn(
                '[[lean_lib]]\nname = "Demo"',
                (target / "lakefile.toml").read_text(encoding="utf-8"),
            )
            with self.assertRaises(ValueError):
                UPGRADE.prepare(source, target, "leanprover/lean4:v4.30.0", "b" * 40)


if __name__ == "__main__":
    unittest.main()
