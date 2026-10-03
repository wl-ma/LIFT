"""Check evidence-derived rendering and rejection of misleading release data."""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from lift_artifacts.serial_demo import render, validate  # noqa: E402


def fixture() -> dict:
    return {
        "schema_version": 1,
        "sources": {
            "books": [
                {
                    "batch": f"B{i}",
                    "title": f"Book {i}",
                    "year": 2017,
                    "pages": "1-2",
                    "items": [{"label": "Definition"}, {"label": "Theorem"}],
                }
                for i in range(3)
            ]
        },
        "releases": [
            {
                "mathematical_review_accepted": True,
                "inventory_complete": True,
                "result": {
                    "release": "R0",
                    "source_preservation": [
                        {"batch": "B0", "clients_passed": True, "source_interfaces": 2}
                    ],
                    "failed_attempt_costs_retained": True,
                    "batch_settled_usage": {
                        "tokens": 120,
                        "logical_model_calls": 2,
                        "provider_retries": 0,
                    },
                },
                "declarations": [
                    {
                        "name": "demo",
                        "module": "ReasLib.Example",
                        "trusted": True,
                        "type": "∀ n : Nat, n = n",
                        "controlled_value_dependencies": [],
                    }
                ],
                "execution_components": [
                    {
                        "tokens": 120,
                        "model_calls": 2,
                        "provider_retries": 0,
                        "execution_seconds": 12.0,
                        "failed_attempt_costs_retained": True,
                        "stage_attempts": [
                            {
                                "stage": "proof",
                                "source_item": "example",
                                "attempt": 1,
                                "native_status": "failed",
                                "failure_code": "protocol_error",
                                "tokens": 20,
                                "model_calls": 1,
                                "elapsed_seconds": 2.0,
                            },
                            {
                                "stage": "proof",
                                "source_item": "example",
                                "attempt": 2,
                                "native_status": "success",
                                "failure_code": None,
                                "tokens": 100,
                                "model_calls": 1,
                                "elapsed_seconds": 10.0,
                            },
                        ],
                    }
                ],
            }
        ],
    }


class SerialDemoTests(unittest.TestCase):
    def test_failure_and_original_denominator_visible(self):
        page = render(fixture())
        for text in ("1 / 3", "2 / 6", "protocol_error", "failed", "success", "120"):
            self.assertIn(text, page)
        self.assertNotIn("<script src=", page)

    def test_representation_obligations_are_displayed_separately(self):
        data = fixture()
        row = data["releases"][0]["result"]["source_preservation"][0]
        row["representation_obligations"] = 2
        page = render(data)
        self.assertIn("2 original source interfaces restored", page)
        self.assertIn("2 representation obligations verified", page)
        self.assertNotIn("4 original source interfaces restored", page)
        row["representation_obligations"] = -1
        with self.assertRaises(ValueError):
            validate(data)

    def test_extended_batches_preserve_denominator_and_costs(self):
        data = fixture()
        data["schema_version"] = 2
        data["sources"]["books"].extend(
            {**data["sources"]["books"][0], "batch": f"B{i}"} for i in range(3, 6)
        )
        page = render(data)
        self.assertIn("1 / 6", page)
        self.assertIn("2 / 12", page)
        self.assertIn("120", page)
        # Presentation omits diagnostics; accounting still binds both attempts.
        self.assertNotIn("protocol_error", page)
        data["releases"][0]["execution_components"][0]["stage_attempts"].pop(0)
        with self.assertRaisesRegex(ValueError, "Stage-attempt costs"):
            validate(data)

    def test_native_success_without_review_rejected(self):
        data = fixture()
        data["releases"][0]["mathematical_review_accepted"] = False
        with self.assertRaisesRegex(ValueError, "reviewed release"):
            render(data)

    def test_cost_mismatch_rejected(self):
        data = fixture()
        data["releases"][0]["result"]["batch_settled_usage"]["tokens"] = 100
        with self.assertRaisesRegex(ValueError, "cost disagrees"):
            render(data)

    def test_unknown_cost_not_replaced_by_zero(self):
        data = fixture()
        release = data["releases"][0]
        release["result"]["batch_settled_usage"]["tokens"] = None
        release["execution_components"][0]["tokens"] = None
        release["execution_components"][0]["stage_attempts"][0]["tokens"] = None
        self.assertIn("Not measured", render(data))

    def test_hidden_failed_attempt_rejected(self):
        data = fixture()
        data["releases"][0]["execution_components"][0]["stage_attempts"].pop(0)
        with self.assertRaisesRegex(ValueError, "Stage-attempt costs"):
            validate(data)

    def test_private_payload_ignored_and_html_escaped(self):
        data = fixture()
        data["private_log"] = "PRIVATE_PAYLOAD"
        data["releases"][0]["declarations"][0]["type"] = (
            "</pre><script>alert(1)</script>"
        )
        page = render(data)
        self.assertNotIn("PRIVATE_PAYLOAD", page)
        self.assertNotIn("<script>alert(1)</script>", page)
        self.assertIn("&lt;script&gt;", page)

    def test_incomplete_inventory_and_failed_clients_rejected(self):
        for field in ("inventory_complete", "clients_passed"):
            data = fixture()
            if field == "inventory_complete":
                data["releases"][0][field] = False
            else:
                data["releases"][0]["result"]["source_preservation"][0][field] = False
            with self.assertRaises(ValueError):
                validate(data)

    def test_release_gap_and_duplicate_declaration_rejected(self):
        data = fixture()
        data["releases"][0]["result"]["release"] = "R2"
        with self.assertRaises(ValueError):
            validate(data)
        data = fixture()
        data["releases"][0]["declarations"] *= 2
        with self.assertRaises(ValueError):
            validate(data)

    def test_missing_source_and_negative_cost_rejected(self):
        data = fixture()
        data["sources"]["books"].pop()
        with self.assertRaises(ValueError):
            validate(data)
        data = fixture()
        data["releases"][0]["execution_components"][0]["tokens"] = -1
        with self.assertRaises(ValueError):
            validate(data)

    def test_interrupted_attempt_and_known_subtotal_are_visible(self):
        data = fixture()
        release = data["releases"][0]
        component = release["execution_components"][0]
        component.update(
            tokens=None,
            model_calls=None,
            provider_retries=None,
            actual_usage_complete=False,
            unsettled_interrupted_attempts=1,
            settled_usage={"tokens": 100, "model_calls": 1, "provider_retries": 0},
        )
        row = component["stage_attempts"][0]
        row.update(
            native_status="interrupted",
            failure_code="user_pause_provider_outage",
            tokens=None,
            model_calls=None,
            provider_retries=None,
            settled_usage={"tokens": 0, "model_calls": 0, "provider_retries": 0},
        )
        release["result"]["batch_usage"] = {
            "tokens": None,
            "logical_model_calls": None,
            "provider_retries": None,
        }
        release["result"]["batch_settled_usage"] = {
            "tokens": 100,
            "logical_model_calls": 1,
            "provider_retries": 0,
        }
        page = render(data)
        self.assertIn("interrupted", page)
        self.assertIn("Settled subtotal: 100 tokens", page)
        self.assertIn("Not measured", page)
        row["tokens"] = 0
        with self.assertRaises(ValueError):
            validate(data)
        row["tokens"] = None
        component["unsettled_interrupted_attempts"] = 0
        with self.assertRaisesRegex(ValueError, "incomplete accounting"):
            validate(data)


if __name__ == "__main__":
    unittest.main()
