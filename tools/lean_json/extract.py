"""Export compiler-derived Lean declarations without a model or remote service."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import tempfile
from pathlib import Path

SUPPORTED = {"4.26.0", "4.30.0", "4.32.0"}
EXTRACTOR = Path(__file__).with_name("HarnessFacts.lean")
EXCLUDED = {".git", ".lake", ".venv", "_build", "_runs", "__pycache__"}


def snapshot(project: Path) -> dict[str, str]:
    """Fingerprint mathematical inputs and environment files, excluding caches."""
    result = {}
    for path in sorted(project.rglob("*")):
        relative = path.relative_to(project)
        if EXCLUDED.intersection(relative.parts) or not path.is_file():
            continue
        if path.suffix != ".lean" and relative.as_posix() not in {
            "lean-toolchain",
            "lakefile.toml",
            "lake-manifest.json",
        }:
            continue
        if not path.resolve().is_relative_to(project):
            raise ValueError(f"Input escapes project: {relative}")
        result[relative.as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    return result


def run(command: list[str], project: Path) -> str:
    """Keep compiler failures distinct from successful empty extraction."""
    result = subprocess.run(
        command, cwd=project, text=True, capture_output=True, timeout=600, check=False
    )
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)
    return result.stdout


def extract(
    project: Path, modules: list[str], names: list[str], *, skip_build: bool = False
) -> dict:
    """Extract exact target identities; never infer types from source text."""
    project = project.resolve(strict=True)
    declared = (project / "lean-toolchain").read_text(encoding="utf-8").strip()
    version = declared.removeprefix("leanprover/lean4:").removeprefix("v")
    if version not in SUPPORTED:
        raise ValueError(
            f"Unsupported toolchain {declared}; supported: {sorted(SUPPORTED)}"
        )
    if names and len(modules) != 1:
        raise ValueError("--name requires exactly one --module")
    if any(not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_'.]*", m) for m in modules):
        raise ValueError("Unsupported module spelling")
    if any(not n or "\n" in n for n in names):
        raise ValueError("Invalid declaration identity")
    actual = run(["lake", "env", "lean", "--version"], project).strip()
    if not re.search(r"version " + re.escape(version) + r"(?:,|\s|\))", actual):
        raise ValueError("Active compiler differs from lean-toolchain")
    if not skip_build:
        run(["lake", "build", *modules], project)
    before = snapshot(project)
    records = []
    with tempfile.TemporaryDirectory(prefix="lift-facts-") as directory:
        for number, module in enumerate(modules):
            driver = Path(directory) / f"Inspect{number}.lean"
            requested = "\n".join(names) if names else "*"
            driver.write_text(
                f"import {module}\n"
                + EXTRACTOR.read_text(encoding="utf-8")
                + "\nset_option maxRecDepth 100000\nset_option maxHeartbeats 0\n"
                + "#harness_dump_module "
                + json.dumps(module)
                + " "
                + json.dumps(requested, ensure_ascii=False)
                + "\n",
                encoding="utf-8",
            )
            stdout = run(["lake", "env", "lean", str(driver)], project)
            facts = [
                json.loads(line) for line in stdout.splitlines() if line.startswith("{")
            ]
            if names:
                facts = [f for f in facts if f["name"] in names]
                missing = set(names) - {f["name"] for f in facts}
                if missing:
                    raise ValueError(
                        f"Missing exact declarations in {module}: {sorted(missing)}"
                    )
            if not facts or any(f["module"] != module for f in facts):
                raise ValueError(f"No unambiguous declarations from {module}")
            for fact in facts:
                fact["declaration_key"] = fact["module"] + "::" + fact["name"]
            records.extend(facts)
    if snapshot(project) != before:
        raise ValueError("Source or dependency lock changed during extraction")
    keys = [f["declaration_key"] for f in records]
    if len(keys) != len(set(keys)):
        raise ValueError("Duplicate declaration identities")
    return {
        "schema": "lift.compiler-facts.v1",
        "lean_version": actual,
        "declared_toolchain": declared,
        "modules": modules,
        "extractor_sha256": hashlib.sha256(EXTRACTOR.read_bytes()).hexdigest(),
        "source_sha256": before,
        "scope": "Selected compiled modules; references may point outside this export.",
        "natural_language_generated": False,
        "records": sorted(records, key=lambda f: f["declaration_key"]),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project", type=Path)
    parser.add_argument("--module", action="append", required=True)
    parser.add_argument("--name", action="append", default=[])
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--skip-build", action="store_true")
    args = parser.parse_args()
    if args.output.exists():
        parser.error("Output already exists; choose a new path")
    if args.output.resolve().is_relative_to(args.project.resolve()):
        parser.error("Output must be outside the source project")
    result = extract(args.project, args.module, args.name, skip_build=args.skip_build)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("x", encoding="utf-8") as stream:
        json.dump(result, stream, ensure_ascii=False, indent=2)
        stream.write("\n")
    print(f"Exported {len(result['records'])} declarations to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
