"""Prepare a separate Lean upgrade candidate and compare compiler snapshots."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

IGNORED = {
    ".git",
    ".lake",
    ".venv",
    "__pycache__",
    "_runs",
    "_build",
    ".runtime",
    "node_modules",
}


def source_files(root: Path) -> list[Path]:
    """Copy an explicit mathematical project surface, not machine configuration."""
    paths = []
    for path in sorted(root.rglob("*")):
        relative = path.relative_to(root)
        if IGNORED.intersection(relative.parts) or not path.is_file():
            continue
        if (
            path.name not in {"lean-toolchain", "lakefile.toml", "LICENSE", "NOTICE"}
            and path.suffix != ".lean"
        ):
            continue
        if path.is_symlink() or not path.resolve().is_relative_to(root):
            raise ValueError(f"Source symlink is not copied: {relative}")
        paths.append(path)
    return paths


def prepare(
    source: Path, destination: Path, target: str, mathlib_rev: str | None
) -> dict:
    """Preserve original inputs and require explicit target dependency pins."""
    source = source.resolve(strict=True)
    destination = destination.resolve()
    if destination.exists() or destination.is_relative_to(source):
        raise ValueError("Destination must be a new directory outside the source")
    if not re.fullmatch(r"leanprover/lean4:v\d+\.\d+\.\d+", target):
        raise ValueError("Target must be an explicit stable leanprover/lean4:vX.Y.Z")
    original = (source / "lean-toolchain").read_text().strip()
    if (source / "lakefile.lean").exists():
        raise ValueError(
            "lakefile.lean requires manual dependency adaptation; only TOML is supported"
        )
    config = (source / "lakefile.toml").read_text()
    sections = re.split(r"(?=^\[\[require\]\])", config, flags=re.MULTILINE)
    mathlib_count = 0
    for index, section in enumerate(sections):
        if not section.startswith("[[require]]"):
            continue
        block, *tail = re.split(
            r"(?=^\[)", section[len("[[require]]") :], maxsplit=1, flags=re.MULTILINE
        )
        if not re.search(r'^name\s*=\s*"mathlib"\s*$', block, re.MULTILINE):
            continue
        mathlib_count += 1
        if not mathlib_rev or not re.fullmatch(r"[0-9a-f]{40}", mathlib_rev):
            raise ValueError(
                "Mathlib projects require --mathlib-rev with a full commit SHA"
            )
        if not re.search(r"^git\s*=", block, re.MULTILINE):
            raise ValueError("Only explicit Git Mathlib dependencies are supported")
        block, changes = re.subn(
            r"^rev\s*=.*$", f'rev = "{mathlib_rev}"', block, flags=re.MULTILINE
        )
        if changes != 1:
            raise ValueError("Mathlib must have exactly one explicit rev")
        sections[index] = "[[require]]" + block + "".join(tail)
    if mathlib_rev and mathlib_count != 1:
        raise ValueError("--mathlib-rev requires exactly one Mathlib dependency")
    files = source_files(source)
    before = {
        p.relative_to(source).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
        for p in files
    }
    destination.mkdir(parents=True)
    for path in files:
        out = destination / path.relative_to(source)
        out.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(path, out)
    (destination / "lean-toolchain").write_text(target + "\n")
    (destination / "lakefile.toml").write_text("".join(sections))
    report = {
        "schema": "lift.toolchain-preparation.v1",
        "original_toolchain": original,
        "target_toolchain": target,
        "target_mathlib_commit": mathlib_rev,
        "original_source_sha256": before,
        "original_lock_sha256": hashlib.sha256(
            (source / "lake-manifest.json").read_bytes()
        ).hexdigest()
        if (source / "lake-manifest.json").exists()
        else None,
        "status": "prepared_not_built",
        "interface_preservation": "not_checked",
        "notes": [
            "Old Lake lock and build products were not copied.",
            "Non-Mathlib dependencies retain their existing declarations.",
            "Extra project resources must be copied explicitly if required.",
        ],
    }
    (destination / "upgrade-plan.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


def compare(before: dict, after: dict) -> dict:
    """Textual fact comparison detects drift; it does not prove equivalence."""

    def index(bundle: dict) -> dict:
        if bundle.get("schema") != "lift.compiler-facts.v1":
            raise ValueError("Expected a LIFT compiler-fact export")
        entries = {r["declaration_key"]: r for r in bundle["records"]}
        if len(entries) != len(bundle["records"]):
            raise ValueError("Duplicate declaration identities")
        return entries

    old, new = index(before), index(after)
    fields = (
        "type",
        "definition_value",
        "axioms",
        "is_unsafe",
        "is_partial",
        "constructors",
        "structure_fields",
    )
    changed = [
        {
            "declaration": key,
            "fields": [f for f in fields if old[key][f] != new[key][f]],
        }
        for key in sorted(old.keys() & new.keys())
        if any(old[key][f] != new[key][f] for f in fields)
    ]
    missing = sorted(old.keys() - new.keys())
    return {
        "schema": "lift.toolchain-comparison.v1",
        "missing": missing,
        "added": sorted(new.keys() - old.keys()),
        "changed": changed,
        "status": "review_required"
        if missing or changed
        else "selected_facts_unchanged",
        "semantic_equivalence": "not_established_by_textual_comparison",
        "client_preservation": "run_original_clients_separately",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    setup = commands.add_parser("prepare")
    setup.add_argument("source", type=Path)
    setup.add_argument("destination", type=Path)
    setup.add_argument("--target", required=True)
    setup.add_argument("--mathlib-rev")
    build = commands.add_parser("build")
    build.add_argument("project", type=Path)
    diff = commands.add_parser("compare")
    diff.add_argument("before", type=Path)
    diff.add_argument("after", type=Path)
    args = parser.parse_args()
    if args.command == "prepare":
        report = prepare(args.source, args.destination, args.target, args.mathlib_rev)
    elif args.command == "build":
        result = subprocess.run(["lake", "build"], cwd=args.project, check=False)
        return result.returncode
    else:
        report = compare(
            json.loads(args.before.read_text()), json.loads(args.after.read_text())
        )
    print(json.dumps(report, indent=2))
    return 1 if report.get("status") == "review_required" else 0


if __name__ == "__main__":
    raise SystemExit(main())
