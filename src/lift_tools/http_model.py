"""Stateless Responses/Chat Completions adapter configured only by runtime environment."""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def read_response_stream(response) -> dict:
    """Require a terminal Responses event; never accept partial text deltas."""
    data = []
    for raw in response:
        line = raw.decode("utf-8") if isinstance(raw, bytes) else raw
        line = line.rstrip("\r\n")
        if line.startswith("data:"):
            data.append(line[5:].lstrip())
        elif not line and data:
            payload = "\n".join(data)
            data = []
            if payload == "[DONE]":
                break
            event = json.loads(payload)
            if event.get("type") in {
                "response.completed",
                "response.incomplete",
                "response.failed",
            }:
                return event["response"]
            if event.get("type") == "error":
                raise ValueError("Provider stream error event")
    raise ValueError("Provider stream ended without a terminal response")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Read one model request from stdin and return a JSON response envelope.",
        epilog="Configure LIFT_MODEL_ENDPOINT, LIFT_MODEL and LIFT_MODEL_API_KEY in the runtime environment.",
    )
    parser.parse_args(argv)
    endpoint = os.environ.get("LIFT_MODEL_ENDPOINT", "")
    key = os.environ.get("LIFT_MODEL_API_KEY", "")
    model = os.environ.get("LIFT_MODEL", "")
    url = urllib.parse.urlsplit(endpoint)
    if (
        not key
        or not model
        or url.scheme != "https"
        or not url.hostname
        or url.username
        or url.password
        or url.query
        or url.fragment
    ):
        print(
            "Set LIFT_MODEL_ENDPOINT (HTTPS inference URL), LIFT_MODEL and LIFT_MODEL_API_KEY in the runtime environment.",
            file=sys.stderr,
        )
        return 2
    style = os.environ.get("LIFT_MODEL_API_STYLE", "chat_completions")
    if style not in {"responses", "chat_completions"}:
        print("Unsupported LIFT_MODEL_API_STYLE", file=sys.stderr)
        return 2
    try:
        timeout = float(os.environ.get("LIFT_MODEL_TIMEOUT_SECONDS", "240"))
        if timeout <= 0:
            raise ValueError
    except ValueError:
        print("LIFT_MODEL_TIMEOUT_SECONDS must be positive", file=sys.stderr)
        return 2
    streaming = style == "responses" and os.environ.get("LIFT_MODEL_STREAM", "0") == "1"
    request = json.load(sys.stdin)
    payload = {
        "model": model,
        "stream": False,
        "response_format": {"type": "json_object"},
        "messages": [
            {"role": "system", "content": request["instructions"]},
            {"role": "user", "content": json.dumps(request, ensure_ascii=False)},
        ],
    }
    if style == "responses":
        payload = {
            "model": model,
            "stream": streaming,
            "store": False,
            "instructions": request["instructions"],
            "input": json.dumps(request, ensure_ascii=False),
            "text": {"format": {"type": "json_object"}},
        }
    req = urllib.request.Request(
        endpoint,
        data=json.dumps(payload).encode(),
        method="POST",
        headers={"Content-Type": "application/json", "Authorization": "Bearer " + key},
    )
    try:
        with urllib.request.build_opener(NoRedirect).open(
            req, timeout=timeout
        ) as response:
            value = read_response_stream(response) if streaming else json.load(response)
        complete = False
        if style == "responses":
            complete = value.get("status") == "completed"
            content = "".join(
                part["text"]
                for item in value.get("output", [])
                if item.get("type") == "message" and item.get("role") == "assistant"
                for part in item.get("content", [])
                if part.get("type") == "output_text"
            )
        else:
            choices = value.get("choices", [])
            choice = choices[0] if choices else {}
            complete = choice.get("finish_reason") == "stop"
            content = choice.get("message", {}).get("content", "")
        try:
            answer = json.loads(content) if complete else None
        except (ValueError, TypeError):
            answer = None
        usage = value.get("usage")
        if not isinstance(usage, dict) or type(usage.get("total_tokens")) is not int:
            usage = None
        print(
            json.dumps(
                {
                    "response": answer,
                    "model": value.get("model", model),
                    "usage": usage,
                    "completion_status": "complete" if complete else "incomplete",
                    "response_text": content,
                }
            )
        )
        return 0
    except urllib.error.HTTPError as exc:
        print(
            f"Provider HTTP {exc.code}; no automatic retry; usage unknown.",
            file=sys.stderr,
        )
    except Exception as exc:  # noqa: BLE001 - Do not expose provider diagnostics or credentials.
        print(
            f"Provider response unavailable ({type(exc).__name__}); usage unknown.",
            file=sys.stderr,
        )
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
