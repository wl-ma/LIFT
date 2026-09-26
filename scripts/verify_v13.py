"""Validate version13 evidence bindings, exact case coverage and recorded event order."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    manifest = json.loads((ROOT / "data/artifact-manifest.json").read_text())
    for relative, expected in manifest["files"].items():
        path = ROOT / relative
        if not path.resolve().is_relative_to(ROOT) or sha(path) != expected:
            raise ValueError(f"Artifact changed or missing: {relative}")
    normal = json.loads((ROOT / "data/normal-cone.json").read_text())
    for module in normal["packaged_modules"]:
        path = module.replace(".", "/") + ".lean"
        if sha(ROOT / "examples/normal-cone" / path) != normal["files"][path]:
            raise ValueError(f"Upstream source changed: {path}")
    for path, expected in normal["unchanged_core"].items():
        if sha(ROOT / "examples/normal-cone" / path) != expected:
            raise ValueError(f"Core source changed: {path}")
    beck = ROOT / "examples/beck"
    for path, expected in json.loads((beck / "sources.json").read_text())[
        "files"
    ].items():
        if sha(beck / path) != expected:
            raise ValueError(f"Beck historical source changed: {path}")
    for case, expected_axioms, expected_clients in (
        ("normal-cone", 5, 0),
        ("beck", 15, 22),
    ):
        report = json.loads((ROOT / "data/validation" / (case + ".json")).read_text())
        config = json.loads((ROOT / "examples" / case / "check.json").read_text())
        if (
            not report["passed"]
            or len(report["axioms"]) != expected_axioms
            or len(report["clients"]) != expected_clients
        ):
            raise ValueError("Case coverage differs from its declared scope")
        if set(report["axioms"]) != set(config["axiom_names"]):
            raise ValueError("Wrong checked declaration identities")
        project = ROOT / "examples" / case / config["project"]
        for entry in report["modules"]:
            path = project / (entry["name"].replace(".", "/") + ".lean")
            if entry["returncode"] != 0 or sha(path) != entry["sha256"]:
                raise ValueError("Compiled source differs from current case source")
    events = json.loads((ROOT / "data/online-events.json").read_text())["events"]
    if [e["sequence"] for e in events] != list(range(len(events))):
        raise ValueError("Event projection is incomplete or reordered")
    for left, right in zip(events, events[1:]):
        if right["previous"] != left["sha256"]:
            raise ValueError("Original event hash references do not form a chain")
    report = json.loads((ROOT / "data/validation/tools.json").read_text())
    if not report["passed"] or len(report["fixture"]) != 3:
        raise ValueError("Tool validation did not pass")
    print(
        f"Version13 bindings passed: {len(manifest['files'])} files, four unchanged normal-cone cores, 22 Beck clients."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
