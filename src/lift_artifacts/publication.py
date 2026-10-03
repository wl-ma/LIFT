"""Bind historical source checks to attribution-only publication edits."""

from __future__ import annotations

import hashlib
from pathlib import Path

HEADER = (
    b"/-\n"
    b"Copyright (c) 2026 LIFT contributors. All rights reserved.\n"
    b"Released under Apache 2.0 license as described in the file LICENSE.\n"
    b"Authors: LIFT contributors\n"
    b"-/\n"
)


def validate_source(data: bytes, entry: dict[str, str]) -> None:
    """Require the recorded public bytes, exact attribution header and body."""
    if entry["transformation"] != "attribution_header_only":
        raise ValueError("Unsupported source publication transformation")
    if hashlib.sha256(data).hexdigest() != entry["published_sha256"]:
        raise ValueError("Published source digest differs")
    if not data.startswith(HEADER):
        raise ValueError("Unexpected source attribution header")
    if hashlib.sha256(data[len(HEADER) :]).hexdigest() != entry["body_sha256"]:
        raise ValueError("Mathematical source body differs")


def matches_record(
    path: Path,
    expected: str,
    root: Path,
    bindings: dict[str, dict[str, str]],
) -> bool:
    """Accept exact historical bytes or an explicitly bound publication edit."""
    data = path.read_bytes()
    entry = bindings.get(path.relative_to(root).as_posix())
    if entry is not None:
        validate_source(data, entry)
        return expected in {entry["source_sha256"], entry["published_sha256"]}
    return hashlib.sha256(data).hexdigest() == expected
