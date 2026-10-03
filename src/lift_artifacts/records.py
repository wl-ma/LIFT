"""Write a uniform evidence envelope for generated tables and figures."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path


def write_record(output: Path, inputs: dict[str, Path], details: dict) -> None:
    """Bind successful generated products without changing historical records."""

    def digest(path: Path) -> str:
        return hashlib.sha256(path.read_bytes()).hexdigest()

    record = {
        "schema": "lift.reproduction.v1",
        "evidence_kind": "reproduction_check",
        "status": "passed",
        "model_calls": 0,
        "inputs": {name: digest(path) for name, path in inputs.items()},
        "outputs": {
            path.name: digest(path)
            for path in sorted(output.iterdir())
            if path.is_file() and path.name != "reproduction.json"
        },
        "details": details,
    }
    (output / "reproduction.json").write_text(json.dumps(record, indent=2) + "\n")
