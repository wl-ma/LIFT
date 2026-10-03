"""JSON model-command transport with per-call accounting and no implicit retries."""

from __future__ import annotations

import json
import os
import re
import signal
import subprocess
import time
from pathlib import Path

from .common import digest, save


class ModelCommand:
    """The executable receives one JSON request and returns response/model/usage.

    Credentials belong in the executable's runtime environment. They must never
    be command arguments or part of this protocol. Each call has a fresh context.
    """

    def __init__(self, command: list[str], directory: Path, timeout: int = 300):
        if not command or not all(isinstance(x, str) and x for x in command):
            raise ValueError("A nonempty argv command is required")
        if timeout <= 0:
            raise ValueError("Timeout must be positive")
        self.command, self.directory, self.timeout = command, directory, timeout
        directory.mkdir(parents=True, exist_ok=False)
        self.records: list[dict] = []

    def call(self, request: dict) -> dict:
        number = len(self.records)
        started = time.monotonic()
        record = {
            "call": number,
            "role": request["role"],
            "request_hash": digest(request),
            "command_hash": digest(self.command),
            "usage": None,
            "model": None,
            "status": "outcome_unknown",
        }
        save(self.directory / f"{number:04d}-request.json", request)
        try:
            process = subprocess.Popen(
                self.command,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                start_new_session=(os.name == "posix"),
            )
            try:
                stdout, stderr = process.communicate(
                    json.dumps(request), timeout=self.timeout
                )
            except subprocess.TimeoutExpired:
                if os.name == "posix":
                    os.killpg(process.pid, signal.SIGKILL)
                else:
                    process.kill()
                process.communicate()
                raise RuntimeError(
                    "Model command timed out; provider usage is unknown"
                ) from None
            if process.returncode:
                record["returncode"] = process.returncode
                match = re.search(r"Provider HTTP ([0-9]{3})", stderr)
                if match:
                    record["failure_http_status"] = int(match[1])
                match = re.search(
                    r"Provider response unavailable \(([A-Za-z0-9_]+)\)", stderr
                )
                if match:
                    record["failure_exception_type"] = match[1]
                raise RuntimeError(
                    f"Model command exited with code {process.returncode}; inspect provider locally"
                )
            envelope = json.loads(stdout)
            if not isinstance(envelope, dict):
                raise ValueError("Expected model-command envelope object")
            if not isinstance(envelope.get("model"), str) or not envelope["model"]:
                raise ValueError("Model command must identify its model")
            usage = envelope.get("usage")
            if usage is not None and (
                not isinstance(usage, dict)
                or type(usage.get("total_tokens")) is not int
                or usage["total_tokens"] < 0
            ):
                raise ValueError(
                    "Usage must be null or contain nonnegative integer total_tokens"
                )
            record.update(
                model=envelope["model"], usage=usage, status="invalid_response"
            )
            if not isinstance(envelope.get("response"), dict):
                save(
                    self.directory / f"{number:04d}-invalid-response.json",
                    {
                        "completion_status": envelope.get("completion_status"),
                        "response_text": envelope.get("response_text"),
                    },
                )
                raise ValueError("Expected a response object in model-command envelope")
            record.update(
                model=envelope["model"],
                usage=usage,
                status="returned",
                response_hash=digest(envelope["response"]),
            )
            save(self.directory / f"{number:04d}-response.json", envelope["response"])
            return envelope["response"]
        finally:
            record["elapsed_seconds"] = time.monotonic() - started
            self.records.append(record)
            save(self.directory / f"{number:04d}-receipt.json", record)

    def accounting(self) -> dict:
        known = [
            r["usage"]["total_tokens"] for r in self.records if r["usage"] is not None
        ]
        unknown = sum(r["usage"] is None for r in self.records)
        return {
            "command_calls": len(self.records),
            "settled_tokens": sum(known),
            "unknown_usage_calls": unknown,
            "actual_total_tokens": None if unknown else sum(known),
            "automatic_transport_retries": 0,
        }
