"""Deterministic hashes and immutable run records."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path


def digest(value: object) -> str:
    return hashlib.sha256(
        json.dumps(
            value, sort_keys=True, separators=(",", ":"), ensure_ascii=True
        ).encode()
    ).hexdigest()


def save(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("x", encoding="utf-8") as stream:
        json.dump(value, stream, ensure_ascii=False, indent=2)
        stream.write("\n")


def read(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))
