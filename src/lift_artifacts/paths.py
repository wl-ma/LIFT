"""Resolve repository artifacts without depending on the current directory."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def artifact(name: str) -> Path:
    """Look up a stable evidence name in the publication registry."""
    entries = json.loads((ROOT / "metadata/artifacts.json").read_text(encoding="utf-8"))
    path = (ROOT / entries[name]).resolve()
    if not path.is_relative_to(ROOT):
        raise ValueError(f"Artifact escapes the repository: {name}")
    return path
