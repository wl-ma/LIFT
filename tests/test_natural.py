"""Semantic workflow contracts using explicit, deterministic test doubles."""

from __future__ import annotations

import copy
import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from lift_tools.common import digest
from lift_tools.natural import (
    CHECKS,
    run_translation,
    structural_context,
    validate_draft,
    validate_review,
    validated_call,
)
from lift_tools.provider import ModelCommand


def fact():
    return {
        "declaration_key": "Demo::positive",
        "name": "positive",
        "module": "Demo",
        "kind": "thm",
        "type": "∀ (n : Nat), 0 < n → n ≠ 0",
        "definition_value": None,
        "dependency_modules": {"Nat.ne_of_gt": "Init.Data.Nat.Basic"},
    }


def draft(correct=True):
    return {
        "statement": "Every positive natural number is nonzero."
        if correct
        else "Every natural number is nonzero.",
        "objects": ["n is a natural number"],
        "assumptions": ["n > 0"] if correct else [],
        "quantifiers": ["for every n"],
        "definition": "",
        "uncertainties": [],
    }


def review(d, context, passed=True):
    evidence = {
        "declaration_key": context[0]["declaration_key"],
        "field": "type",
        "excerpt": context[0]["type"],
    }
    return {
        "draft_hash": digest(d),
        "context_hash": digest(context),
        "status": "passed" if passed else "rejected",
        "checks": {
            key: {
                "verdict": "passed" if passed else "failed",
                "reason": "Check the positive-natural hypothesis and nonzero conclusion.",
                "evidence": evidence,
            }
            for key in CHECKS
        },
        "issues": []
        if passed
        else [
            {
                "category": "missing_hypothesis",
                "message": "The n > 0 hypothesis is missing.",
                "evidence": evidence,
            }
        ],
        "context_requests": [],
    }


class ScriptedReviewer:
    """Test double, not a language model or mathematical quality evaluation."""

    def __init__(self, never_pass=False):
        self.calls = 0
        self.never_pass = never_pass

    def call(self, request):
        self.calls += 1
        if request["role"] == "translator":
            return draft(bool(request.get("previous_review")) and not self.never_pass)
        return review(
            request["draft"],
            request["compiler_context"],
            bool(request["draft"]["assumptions"]),
        )

    def accounting(self):
        return {"test_double_calls": self.calls, "actual_model_calls": 0}


class NaturalTests(unittest.TestCase):
    def test_referenced_structure_includes_complete_constructor_and_field_facts(self):
        energy = {
            "declaration_key": "Demo::energy",
            "name": "energy",
            "dependency_modules": {"Box": "Demo"},
        }
        box = {
            "declaration_key": "Demo::Box",
            "name": "Box",
            "constructors": ["Box.mk"],
            "structure_fields": ["Box.positive"],
            "dependency_modules": {"Box.mk": "Demo", "Box.positive": "Demo"},
        }
        constructor = {"declaration_key": "Demo::Box.mk", "name": "Box.mk"}
        positive = {"declaration_key": "Demo::Box.positive", "name": "Box.positive"}
        unrelated = {"declaration_key": "Demo::Other", "name": "Other"}
        result = structural_context(
            [energy, box], [energy, box, constructor, positive, unrelated]
        )
        self.assertEqual(
            {r["name"] for r in result}, {"energy", "Box", "Box.mk", "Box.positive"}
        )
        self.assertEqual(
            result,
            structural_context(result, [energy, box, constructor, positive, unrelated]),
        )

    def test_expanded_context_limit_is_checked_before_any_revision_call(self):
        class NeedsLargeContext(ScriptedReviewer):
            def call(self, request):
                self.calls += 1
                if request["role"] == "translator":
                    return draft()
                value = review(request["draft"], request["compiler_context"], False)
                value["context_requests"] = [
                    {"module": "Init.Data.Nat.Basic", "name": "Nat.ne_of_gt"}
                ]
                return value

        provider = NeedsLargeContext()
        extra = {
            "declaration_key": "Init.Data.Nat.Basic::Nat.ne_of_gt",
            "name": "Nat.ne_of_gt",
            "module": "Init.Data.Nat.Basic",
            "type": "x" * 5000,
        }
        with tempfile.TemporaryDirectory() as directory, self.assertRaises(ValueError):
            run_translation(
                {"schema": "lift.compiler-facts.v1", "records": [fact()]},
                [fact()["declaration_key"]],
                provider,
                Path(directory) / "run",
                resolver=lambda *_: extra,
                context_bytes=1000,
            )
        self.assertEqual(provider.calls, 2)

    def test_missing_hypothesis_is_repaired_and_entire_draft_rechecked(self):
        with tempfile.TemporaryDirectory() as directory:
            provider = ScriptedReviewer()
            result = run_translation(
                {"schema": "lift.compiler-facts.v1", "records": [fact()]},
                [fact()["declaration_key"]],
                provider,
                Path(directory) / "run",
            )
            self.assertEqual(result["status"], "accepted")
            self.assertEqual(provider.calls, 4)
            self.assertEqual(result["records"][0]["repairs"], 1)
            self.assertEqual(result["records"][0]["compiler"], fact())
            self.assertFalse(result["semantic_equivalence_formally_proved"])
            self.assertEqual(
                len(list((Path(directory) / "run").glob("*.review.json"))), 2
            )

    def test_repair_limit_retains_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            provider = ScriptedReviewer(never_pass=True)
            result = run_translation(
                {"schema": "lift.compiler-facts.v1", "records": [fact()]},
                [fact()["declaration_key"]],
                provider,
                Path(directory) / "run",
                max_repairs=1,
            )
            self.assertEqual(result["status"], "needs_review")
            self.assertEqual(provider.calls, 4)

    def test_wrong_hash_and_fabricated_or_empty_evidence_fail_closed(self):
        original = review(draft(), [fact()])
        changes = [
            lambda r: r.update(draft_hash="another"),
            lambda r: r.update(context_hash="another"),
            lambda r: r["checks"]["hypotheses_and_domains"]["evidence"].update(
                excerpt="false claim"
            ),
            lambda r: r["checks"]["hypotheses_and_domains"]["evidence"].update(
                excerpt=""
            ),
        ]
        for change in changes:
            with self.subTest(change=change):
                value = copy.deepcopy(original)
                change(value)
                with self.assertRaises(ValueError):
                    validate_review(value, draft(), [fact()])

    def test_uncertainty_cannot_pass(self):
        d = draft()
        d["uncertainties"] = ["Is n allowed to be zero?"]
        with self.assertRaises(ValueError):
            validate_review(review(d, [fact()]), d, [fact()])

    def test_definition_requires_defining_data(self):
        f = fact()
        f["definition_value"] = "fun n => n + 1"
        with self.assertRaises(ValueError):
            validate_draft(draft(), f)

    def test_type_echo_is_not_prose(self):
        d = draft()
        d["statement"] = fact()["type"]
        with self.assertRaises(ValueError):
            validate_draft(d, fact())

    def test_context_limit_does_not_truncate(self):
        with tempfile.TemporaryDirectory() as directory:
            out = Path(directory) / "run"
            with self.assertRaises(ValueError):
                run_translation(
                    {"schema": "lift.compiler-facts.v1", "records": [fact()]},
                    [fact()["declaration_key"]],
                    ScriptedReviewer(),
                    out,
                    context_bytes=1,
                )
            self.assertEqual(
                json.loads((out / "result.json").read_text())["status"], "failed"
            )
            self.assertEqual(
                json.loads((out / "facts.json").read_text())["records"], [fact()]
            )

    def test_unknown_targets_rejected_before_calls(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                run_translation(
                    {"schema": "lift.compiler-facts.v1", "records": [fact()]},
                    ["Demo::unknown"],
                    ScriptedReviewer(),
                    Path(directory) / "run",
                )

    def test_non_dependency_context_is_rejected(self):
        class BadContext(ScriptedReviewer):
            def call(self, request):
                result = super().call(request)
                if request["role"] == "verifier":
                    result["context_requests"] = [
                        {"module": "Secret", "name": "answer"}
                    ]
                return result

        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                run_translation(
                    {"schema": "lift.compiler-facts.v1", "records": [fact()]},
                    [fact()["declaration_key"]],
                    BadContext(),
                    Path(directory) / "run",
                    resolver=lambda *_: None,
                )

    def test_requested_compiler_context_is_bound_and_reviewed(self):
        extra = dict(
            fact(),
            declaration_key="Init.Data.Nat.Basic::Nat.ne_of_gt",
            name="Nat.ne_of_gt",
            module="Init.Data.Nat.Basic",
            dependency_modules={},
        )

        class ContextReviewer(ScriptedReviewer):
            def call(self, request):
                result = super().call(request)
                if (
                    request["role"] == "verifier"
                    and len(request["compiler_context"]) == 1
                ):
                    result["context_requests"] = [
                        {"module": "Init.Data.Nat.Basic", "name": "Nat.ne_of_gt"}
                    ]
                return result

        with tempfile.TemporaryDirectory() as directory:
            result = run_translation(
                {"schema": "lift.compiler-facts.v1", "records": [fact()]},
                [fact()["declaration_key"]],
                ContextReviewer(),
                Path(directory) / "run",
                resolver=lambda *_: extra,
            )
            self.assertEqual(result["status"], "accepted")
            self.assertEqual(result["records"][0]["context_expansions"], 1)
            self.assertEqual(len(result["records"][0]["compiler_context"]), 2)

    def test_erasing_uncertainty_alone_fails(self):
        class Eraser(ScriptedReviewer):
            def call(self, request):
                if request["role"] == "translator":
                    d = draft(False)
                    d["uncertainties"] = (
                        [] if request.get("previous_review") else ["Missing hypothesis"]
                    )
                    return d
                return review(request["draft"], request["compiler_context"], False)

        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                run_translation(
                    {"schema": "lift.compiler-facts.v1", "records": [fact()]},
                    [fact()["declaration_key"]],
                    Eraser(),
                    Path(directory) / "run",
                )


class CommandTests(unittest.TestCase):
    def test_real_subprocess_transport_and_unknown_accounting(self):
        code = 'import json,sys; r=json.load(sys.stdin); print(json.dumps({"response":{"echo":r["role"]},"model":"test-double","usage":None}))'
        with tempfile.TemporaryDirectory() as directory:
            model = ModelCommand(
                [sys.executable, "-c", code], Path(directory) / "calls"
            )
            self.assertEqual(model.call({"role": "translator"}), {"echo": "translator"})
            self.assertIsNone(model.accounting()["actual_total_tokens"])
            self.assertEqual(model.accounting()["unknown_usage_calls"], 1)

    def test_failed_call_keeps_receipt(self):
        with tempfile.TemporaryDirectory() as directory:
            model = ModelCommand(
                [sys.executable, "-c", "raise SystemExit(3)"], Path(directory) / "calls"
            )
            with self.assertRaises(RuntimeError):
                model.call({"role": "translator"})
            self.assertEqual(model.accounting()["command_calls"], 1)
            self.assertTrue((Path(directory) / "calls/0000-receipt.json").exists())


class ProtocolRepairTests(unittest.TestCase):
    def test_schema_repair_is_explicit_and_bounded(self):
        class Malformed:
            def __init__(self):
                self.requests = []

            def call(self, request):
                self.requests.append(request)
                return (
                    {"objects/assumptions/quantifiers": []}
                    if len(self.requests) < 3
                    else draft()
                )

        provider = Malformed()
        value = validated_call(
            provider,
            {"role": "translator", "instructions": "six fields"},
            lambda value: validate_draft(value, fact()),
        )
        self.assertEqual(value, draft())
        self.assertEqual(len(provider.requests), 3)
        self.assertIn("previous_invalid_response", provider.requests[1])
        provider = Malformed()
        with self.assertRaises(ValueError):
            validated_call(
                provider,
                {"role": "translator"},
                lambda value: validate_draft(value, fact()),
                max_schema_repairs=1,
            )
        self.assertEqual(len(provider.requests), 2)

    def test_invalid_answer_keeps_known_provider_usage(self):
        with tempfile.TemporaryDirectory() as directory:
            envelope = {
                "response": None,
                "model": "test-double",
                "usage": {"total_tokens": 17},
                "completion_status": "incomplete",
            }
            provider = ModelCommand(
                [
                    sys.executable,
                    "-c",
                    "import json; print(" + repr(json.dumps(envelope)) + ")",
                ],
                Path(directory) / "calls",
            )
            with self.assertRaises(ValueError):
                provider.call({"role": "translator"})
            self.assertEqual(provider.accounting()["actual_total_tokens"], 17)
            self.assertEqual(provider.accounting()["unknown_usage_calls"], 0)
            self.assertTrue(
                (Path(directory) / "calls/0000-invalid-response.json").is_file()
            )


if __name__ == "__main__":
    unittest.main()
