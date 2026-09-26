"""Compile the five released case files and inspect nine declaration axioms."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "examples/reaslib"
MODULES = [
    "ReasLib.Analysis.Calculus.Taylor",
    "NocedalNumericalOptimization.Chapter02.Theorem_2_1",
    "NocedalNumericalOptimization.Chapter02.Theorem_2_2",
    "ReasLib.AlgebraicTopology.FundamentalGroup.Product",
    "RiemannSurfaces.Chapter1.Exercise_3_2",
]
ALLOWED = {"propext", "Classical.choice", "Quot.sound"}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lean", default="lean")
    parser.add_argument(
        "--packages",
        type=Path,
        help="Existing Lake packages for the pinned Lean/Mathlib",
    )
    parser.add_argument("--output", type=Path, default=ROOT / "_runs/lean-check")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    build = args.output.resolve() / "build"
    build.mkdir()
    env = os.environ.copy()
    if args.packages:
        manifest = json.loads((ROOT / "data/lean-checks-historical.json").read_text())
        revision = subprocess.run(
            ["git", "-C", str(args.packages / "mathlib"), "rev-parse", "HEAD"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
        if revision != manifest["mathlib_commit"]:
            raise ValueError("Mathlib cache revision differs from the recorded pin")
        paths = [
            str(p / ".lake/build/lib/lean")
            for p in args.packages.iterdir()
            if p.is_dir()
        ]
        lean = [args.lean]
        env["LEAN_PATH"] = os.pathsep.join([str(build), *paths])
    else:
        lean = ["lake", "env", "lean"]
        lake_path = subprocess.run(
            ["lake", "env", "printenv", "LEAN_PATH"],
            cwd=PROJECT,
            text=True,
            capture_output=True,
            check=True,
        ).stdout.strip()
        env["LEAN_PATH"] = str(build) + os.pathsep + lake_path
        lean = [args.lean]
    version = subprocess.run(
        lean + ["--version"],
        cwd=PROJECT,
        env=env,
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    if not re.search(r"version 4\.32\.0(?:,|\s|\))", version):
        raise ValueError("The ReasLib demo requires Lean 4.32.0")
    records = []
    for module in MODULES:
        source = PROJECT / (module.replace(".", "/") + ".lean")
        output = build / (module.replace(".", "/") + ".olean")
        output.parent.mkdir(parents=True, exist_ok=True)
        result = subprocess.run(
            lean
            + [
                "-j",
                "1",
                "-M",
                "2048",
                "--root=" + str(PROJECT),
                "-o",
                str(output),
                str(source),
            ],
            cwd=PROJECT,
            env=env,
            text=True,
            capture_output=True,
            timeout=180,
            check=False,
        )
        (args.output / (module + ".log")).write_text(result.stdout + result.stderr)
        records.append(
            {
                "module": module,
                "returncode": result.returncode,
                "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
            }
        )
        print(
            f"{module}: {'passed' if result.returncode == 0 else 'failed'}", flush=True
        )
        if result.returncode:
            return result.returncode
    audit = subprocess.run(
        lean + ["-j", "1", "Audit.lean"],
        cwd=PROJECT,
        env=env,
        text=True,
        capture_output=True,
        timeout=180,
        check=False,
    )
    outputs = re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]", audit.stdout)
    valid = audit.returncode == 0 and len(outputs) == 9
    for _, values in outputs:
        valid = (
            valid
            and set(filter(None, (v.strip() for v in values.split(",")))) <= ALLOWED
        )
    report = {
        "lean_version": version,
        "modules": records,
        "axioms": audit.stdout,
        "audit_returncode": audit.returncode,
        "checked_declarations": len(outputs),
        "passed": valid,
    }
    (args.output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(
        json.dumps(
            {
                "compiled_files": len(records),
                "axiom_checks": len(outputs),
                "passed": valid,
            }
        )
    )
    return 0 if valid else 1


if __name__ == "__main__":
    raise SystemExit(main())
