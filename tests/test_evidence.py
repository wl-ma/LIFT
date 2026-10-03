"""Reject incomplete or misleading migration and proof-check evidence."""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

from test_tools import UPGRADE, bundle

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
from lift_artifacts import check_case as CASE  # noqa: E402


class EvidenceTests(unittest.TestCase):
    def test_proof_dependency_change_requires_review(self):
        before, after = bundle(), bundle()
        before["records"][0]["value_dependencies"] = ["Old.answer"]
        after["records"][0]["value_dependencies"] = ["New.shared"]
        result = UPGRADE.compare(before, after)
        self.assertEqual(result["status"], "review_required")
        self.assertIn("value_dependencies", result["changed"][0]["fields"])

    def test_equal_count_wrong_axiom_identity_fails(self):
        with self.assertRaises(ValueError):
            CASE.audit_output("'Wrong' depends on axioms: [propext]", ["Expected"])

    def test_duplicate_axiom_output_fails(self):
        with self.assertRaises(ValueError):
            CASE.audit_output(
                "'A' depends on axioms: [propext]\n'A' depends on axioms: [propext]",
                ["A", "B"],
            )

    def test_custom_axiom_fails(self):
        with self.assertRaises(ValueError):
            CASE.audit_output("'A' depends on axioms: [New.unsound]", ["A"])

    def test_axiom_free_declaration_is_valid(self):
        self.assertEqual(
            CASE.audit_output("'A' does not depend on any axioms", ["A"]), {"A": []}
        )

    def test_empty_clients_do_not_establish_preservation(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            manifest = root / "clients.json"
            manifest.write_text('{"clients":[]}')
            with self.assertRaises(ValueError):
                UPGRADE.check_clients(root, manifest, root / "result")
            self.assertFalse((root / "result").exists())


if __name__ == "__main__":
    unittest.main()
