"""Recompile a pinned released case, audit exact declarations and original clients."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import time
from pathlib import Path

from .paths import ROOT

ALLOWED = {"propext", "Classical.choice", "Quot.sound"}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def module_order(project: Path) -> list[str]:
    """Resolve only project imports; external packages remain pinned dependencies."""
    paths = {
        p.relative_to(project).as_posix()[:-5].replace("/", "."): p
        for p in project.rglob("*.lean")
        if not {".lake", ".git"}.intersection(p.relative_to(project).parts)
        and p.name != "Audit.lean"
    }
    visited, active, result = set(), set(), []

    def visit(module: str) -> None:
        if module in visited:
            return
        if module in active:
            raise ValueError(f"Cyclic project imports: {module}")
        active.add(module)
        for name in re.findall(
            r"^(?:public )?import\s+([A-Za-z0-9_.]+)",
            paths[module].read_text(encoding="utf-8"),
            re.MULTILINE,
        ):
            if name in paths:
                visit(name)
        active.remove(module)
        visited.add(module)
        result.append(module)

    for module in sorted(paths):
        visit(module)
    return result


def audit_output(stdout: str, expected: list[str]) -> dict:
    """Require exact identities, once each, and reject every unapproved axiom."""
    values = re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]", stdout)
    values += [
        (name, "")
        for name in re.findall(r"'([^']+)' does not depend on any axioms", stdout)
    ]
    if len(values) != len(expected) or {name for name, _ in values} != set(expected):
        raise ValueError(
            "Axiom output does not cover exactly the requested declarations"
        )
    result = {
        name: sorted(filter(None, (v.strip() for v in axioms.split(","))))
        for name, axioms in values
    }
    if any(set(axioms) - ALLOWED for axioms in result.values()):
        raise ValueError("Unapproved axiom in a checked declaration")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("case", choices=["beck", "normal-cone"])
    parser.add_argument("--packages", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    case = ROOT / "examples/paper-cases" / args.case
    config = json.loads((case / "check.json").read_text())
    project = (case / config["project"]).resolve()
    args.output.mkdir(parents=True, exist_ok=False)
    output = args.output.resolve()
    build = output / "build"
    build.mkdir()
    env = os.environ.copy()
    if args.packages:
        packages = args.packages.resolve(strict=True)
        actual = subprocess.check_output(
            ["git", "-C", str(packages / "mathlib"), "rev-parse", "HEAD"], text=True
        ).strip()
        if actual != config["mathlib_commit"]:
            raise ValueError("Mathlib cache does not match the fixed case revision")
        paths = [
            str(p / ".lake/build/lib/lean") for p in packages.iterdir() if p.is_dir()
        ]
    else:
        lock = json.loads((project / "lake-manifest.json").read_text())
        if (
            next(p["rev"] for p in lock["packages"] if p["name"] == "mathlib")
            != config["mathlib_commit"]
        ):
            raise ValueError("Dependency lock differs from the case revision")
        paths = [
            subprocess.check_output(
                ["lake", "env", "printenv", "LEAN_PATH"], cwd=project, text=True
            ).strip()
        ]
    env["LEAN_PATH"] = os.pathsep.join([str(build), *paths])
    version = subprocess.check_output(
        ["lean", "--version"], cwd=project, text=True
    ).strip()
    if f"version {config['version']}," not in version:
        raise ValueError("Active Lean version differs from case pin")
    report = {
        "schema": "lift.case-check.v1",
        "case": args.case,
        "lean_version": version,
        "mathlib_commit": config["mathlib_commit"],
        "modules": [],
        "clients": [],
        "passed": False,
        "model_calls": 0,
    }
    started = time.monotonic()

    def run(path: Path, label: str, olean: Path | None = None) -> str:
        command = [
            "lean",
            "-j",
            "1",
            "-M",
            str(config.get("memory_mb", 4096)),
            "--root=" + str(project),
        ]
        command += [
            f"-D{key}={value}" for key, value in config.get("lean_options", {}).items()
        ]
        if olean:
            olean.parent.mkdir(parents=True, exist_ok=True)
            command += ["-o", str(olean)]
        command.append(str(path))
        begin = time.monotonic()
        proc = subprocess.run(
            command,
            cwd=project,
            env=env,
            text=True,
            capture_output=True,
            timeout=900,
            check=False,
        )
        (output / (label.replace("/", "_") + ".log")).write_text(
            proc.stdout + proc.stderr
        )
        record = {
            "name": label,
            "sha256": digest(path),
            "returncode": proc.returncode,
            "seconds": time.monotonic() - begin,
        }
        report["clients" if label.startswith("client-") else "modules"].append(record)
        (output / "progress.json").write_text(json.dumps(report, indent=2) + "\n")
        print(label, proc.returncode, flush=True)
        if proc.returncode:
            raise RuntimeError(f"Compilation failed: {label}; see the local log")
        return proc.stdout

    try:
        for module in module_order(project):
            relative = module.replace(".", "/")
            run(project / (relative + ".lean"), module, build / (relative + ".olean"))
        report["axioms"] = audit_output(
            run(project / "Audit.lean", "Audit"), config["axiom_names"]
        )
        if config["clients_manifest"]:
            manifest = json.loads((case / config["clients_manifest"]).read_text())
            for number, client in enumerate(manifest["clients"]):
                path = case / client["file"]
                if digest(path) != client["sha256"]:
                    raise ValueError("Original client changed")
                run(path, f"client-{number:02d}")
            if len(report["clients"]) != 22:
                raise ValueError("Beck requires all 22 original clients")
        report["passed"] = True
    except Exception as exc:
        report["error"] = str(exc)
    finally:
        report["seconds"] = time.monotonic() - started
        (output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
