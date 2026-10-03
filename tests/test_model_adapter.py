"""Offline HTTP contract tests; credentials and responses are synthetic fixtures."""

import contextlib
import io
import json
import sys
import unittest
import urllib.error
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from lift_tools import http_model


class HttpTests(unittest.TestCase):
    def test_help_needs_no_credentials_or_network(self):
        output = io.StringIO()
        with (
            patch.dict("os.environ", {}, clear=True),
            contextlib.redirect_stdout(output),
            patch("urllib.request.build_opener") as opener,
            self.assertRaises(SystemExit) as stopped,
        ):
            http_model.main(["--help"])
        self.assertEqual(stopped.exception.code, 0)
        self.assertIn("LIFT_MODEL_ENDPOINT", output.getvalue())
        opener.assert_not_called()

    def test_unexpected_arguments_fail_before_credentials(self):
        with (
            patch.dict("os.environ", {}, clear=True),
            contextlib.redirect_stderr(io.StringIO()),
            self.assertRaises(SystemExit) as stopped,
        ):
            http_model.main(["--unexpected"])
        self.assertEqual(stopped.exception.code, 2)

    def invoke(
        self,
        value=None,
        error=None,
        configured=True,
        style="chat_completions",
        streaming=False,
    ):
        environment = (
            {
                "LIFT_MODEL_ENDPOINT": "https://example.invalid/v1/chat/completions",
                "LIFT_MODEL": "fixture-model",
                "LIFT_MODEL_API_KEY": "fixture-only-not-a-credential",
                "LIFT_MODEL_API_STYLE": style,
                "LIFT_MODEL_STREAM": "1" if streaming else "0",
            }
            if configured
            else {}
        )
        output, errors = io.StringIO(), io.StringIO()
        with (
            patch.dict("os.environ", environment, clear=True),
            patch(
                "sys.stdin",
                io.StringIO(
                    json.dumps({"role": "translator", "instructions": "Return JSON"})
                ),
            ),
            contextlib.redirect_stdout(output),
            contextlib.redirect_stderr(errors),
            patch("urllib.request.build_opener") as opener,
        ):
            if error:
                opener.return_value.open.side_effect = error
            else:
                opener.return_value.open.return_value.__enter__.return_value = (
                    io.StringIO(value if streaming else json.dumps(value))
                )
            code = http_model.main([])
        return code, output.getvalue(), errors.getvalue(), opener

    def test_valid_json_and_provider_usage(self):
        result = {
            "choices": [
                {
                    "finish_reason": "stop",
                    "message": {"content": '{"statement":"fixture"}'},
                }
            ],
            "model": "fixture-model",
            "usage": {"total_tokens": 7},
        }
        code, output, errors, opener = self.invoke(result)
        self.assertEqual(code, 0)
        self.assertEqual(json.loads(output)["usage"]["total_tokens"], 7)
        self.assertEqual(opener.return_value.open.call_count, 1)
        self.assertNotIn("fixture-only", output + errors)
        request = opener.return_value.open.call_args.args[0]
        self.assertEqual(
            json.loads(request.data)["response_format"], {"type": "json_object"}
        )

    def test_responses_protocol_uses_complete_text_and_usage(self):
        value = {
            "status": "completed",
            "model": "fixture-model",
            "output": [
                {
                    "type": "message",
                    "role": "assistant",
                    "content": [
                        {"type": "output_text", "text": '{"statement":"test"}'}
                    ],
                }
            ],
            "usage": {"total_tokens": 12},
        }
        code, output, _, opener = self.invoke(value, style="responses")
        self.assertEqual(code, 0)
        self.assertEqual(json.loads(output)["usage"]["total_tokens"], 12)
        payload = json.loads(opener.return_value.open.call_args.args[0].data)
        self.assertFalse(payload["store"])
        self.assertNotIn("reasoning", payload)
        self.assertEqual(payload["text"]["format"]["type"], "json_object")

    def test_invalid_json_keeps_settled_usage(self):
        value = {
            "choices": [{"finish_reason": "stop", "message": {"content": "not JSON"}}],
            "model": "fixture-model",
            "usage": {"total_tokens": 8},
        }
        code, output, _, _ = self.invoke(value)
        self.assertEqual(code, 0)
        self.assertIsNone(json.loads(output)["response"])
        self.assertEqual(json.loads(output)["usage"]["total_tokens"], 8)

    def test_missing_environment_never_connects(self):
        code, output, _, opener = self.invoke(configured=False)
        self.assertEqual(code, 2)
        self.assertFalse(opener.called)
        self.assertFalse(output)

    def test_incomplete_response_fails(self):
        code, output, _, _ = self.invoke(
            {"choices": [{"finish_reason": "length", "message": {"content": "{}"}}]}
        )
        self.assertEqual(code, 0)
        self.assertIsNone(json.loads(output)["response"])

    def test_incomplete_response_retains_provider_usage(self):
        value = {
            "status": "incomplete",
            "model": "fixture-model",
            "output": [],
            "usage": {"total_tokens": 17},
        }
        code, output, _, _ = self.invoke(value, style="responses")
        self.assertEqual(code, 0)
        self.assertIsNone(json.loads(output)["response"])
        self.assertEqual(json.loads(output)["usage"]["total_tokens"], 17)

    def test_http_error_is_not_retried_or_dumped(self):
        error = urllib.error.HTTPError(
            "https://example.invalid", 429, "fixture-only-not-a-credential", {}, None
        )
        code, output, errors, opener = self.invoke(error=error)
        self.assertEqual(code, 1)
        self.assertIn("429", errors)
        self.assertNotIn("fixture-only", output + errors)
        self.assertEqual(opener.return_value.open.call_count, 1)

    def test_streaming_main_extracts_only_final_text(self):
        final = {
            "status": "completed",
            "model": "fixture-model",
            "output": [
                {
                    "type": "message",
                    "role": "assistant",
                    "content": [
                        {"type": "output_text", "text": '{"statement":"finished"}'}
                    ],
                }
            ],
            "usage": {"total_tokens": 19},
        }
        data = (
            "data: "
            + json.dumps({"type": "response.completed", "response": final})
            + "\n\n"
        )
        code, output, _, opener = self.invoke(data, style="responses", streaming=True)
        self.assertEqual(code, 0)
        self.assertEqual(json.loads(output)["response"], {"statement": "finished"})
        self.assertTrue(
            json.loads(opener.return_value.open.call_args.args[0].data)["stream"]
        )

    def test_stream_requires_terminal_response_and_keeps_usage(self):
        final = {
            "status": "completed",
            "model": "fixture-model",
            "output": [],
            "usage": {"total_tokens": 31},
        }
        stream = (
            "data: "
            + json.dumps({"type": "response.output_text.delta", "delta": "partial"})
            + "\n\n"
        )
        with self.assertRaises(ValueError):
            http_model.read_response_stream(io.StringIO(stream))
        stream += (
            "data: "
            + json.dumps({"type": "response.completed", "response": final})
            + "\n\n"
        )
        self.assertEqual(
            http_model.read_response_stream(io.BytesIO(stream.encode())), final
        )

    def test_redirects_are_refused(self):
        self.assertIsNone(
            http_model.NoRedirect().redirect_request(
                None, None, 302, "", {}, "https://example.invalid/elsewhere"
            )
        )


if __name__ == "__main__":
    unittest.main()
