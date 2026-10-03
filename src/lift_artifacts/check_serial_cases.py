"""Recompile reviewed supplementary goals and compare complete formal evidence."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
from pathlib import Path

from lift_tools.compiler import extract

from .check_case import ALLOWED
from .check_serial_demo import digest, verify_files
from .paths import ROOT


def check_cases(root: Path, output: Path) -> dict:
    """Check each immutable source snapshot, including every private declaration."""
    output.mkdir(parents=True, exist_ok=False)
    reports = []
    for folder in sorted(root.iterdir()):
        if not folder.is_dir():
            continue
        review = json.loads((folder / "review.json").read_text())
        project = folder / "project"
        verify_files(project, review["files"])
        if review["accepted"] is not True or review["exact_original_type"] is not True:
            raise ValueError("A supplementary case requires the original reviewed goal")
        result = subprocess.run(
            ["lake", "build", "Downstream"],
            cwd=project,
            text=True,
            capture_output=True,
            timeout=1800,
            env={**os.environ, "LEAN_NUM_THREADS": "1"},
            check=False,
        )
        (output / (folder.name + "-build.log")).write_text(
            result.stdout + result.stderr
        )
        if result.returncode:
            raise ValueError(f"Supplementary project did not compile: {folder.name}")
        fresh = extract(
            project, review["modules"], [], skip_build=True, fully_explicit=True
        )
        (output / (folder.name + "-fresh-facts.json")).write_text(
            json.dumps(fresh, ensure_ascii=False, indent=2) + "\n"
        )
        recorded = json.loads((folder / "facts.json").read_text())["declarations"]
        before = {row["name"]: row for row in recorded}
        after = {row["name"]: row for row in fresh["records"]}
        if set(before) != set(after) or set(before) != set(review["axiom_inventory"]):
            raise ValueError("The complete owned declaration inventory changed")
        for name, original in before.items():
            current = after[name]
            # Pretty-printer line wrapping is irrelevant; all formal tokens remain required.
            if re.sub(r"\s+", "", original["type"]) != re.sub(
                r"\s+", "", current["type"]
            ):
                raise ValueError(f"The original complete type changed: {name}")
            for key in ("value_dependencies", "type_dependencies", "axioms"):
                observed = (
                    current["expression_type_dependencies"]
                    if key == "type_dependencies"
                    else current[key]
                )
                if set(original[key]) != set(observed):
                    raise ValueError(
                        f"Formal dependency evidence changed: {name}: {key}"
                    )
            if (
                set(current["axioms"]) - ALLOWED
                or current["is_unsafe"]
                or current["is_partial"]
            ):
                raise ValueError(f"Untrusted owned declaration: {name}")
        verify_files(project, review["files"])
        reports.append(
            {
                "case": folder.name,
                "passed": True,
                "goal": review["goal"],
                "exact_original_type": True,
                "owned_declarations": len(after),
                "review_sha256": digest(folder / "review.json"),
                "facts_sha256": digest(folder / "facts.json"),
                "reuse_classification": review["reuse_classification"],
                "actual_upstream_dependencies": review["actual_upstream_dependencies"],
            }
        )
    if len(reports) != 4:
        raise ValueError("All four registered supplementary cases must be checked")
    report = {
        "schema": "lift.supplementary-package-check.v1",
        "passed": True,
        "model_calls": 0,
        "cases": reports,
    }
    (output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--cases",
        type=Path,
        default=ROOT / "experiments/serial-library-growth/supplementary",
    )
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    report = check_cases(args.cases.resolve(), args.output.resolve())
    print(f"Supplementary cases verified: {len(report['cases'])} exact original goals")
    return 0
