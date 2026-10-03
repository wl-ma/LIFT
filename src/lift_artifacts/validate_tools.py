"""Exercise compiler extraction and a real Mathlib 4.30-to-4.32 migration."""

from __future__ import annotations

import argparse
import importlib.util
import json
import shutil
import subprocess
from pathlib import Path

from .paths import ROOT


def module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


EXTRACT = module("extract", ROOT / "tools/lean_json/extract.py")
UPGRADE = module("upgrade", ROOT / "tools/toolchain/upgrade.py")


def command(args: list[str], cwd: Path) -> str:
    result = subprocess.run(
        args, cwd=cwd, text=True, capture_output=True, timeout=1200, check=False
    )
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)
    return result.stdout


def dependencies(project: Path, packages: Path | None, pin: str, lock: Path) -> None:
    if packages:
        packages = packages.resolve(strict=True)
        if (
            command(
                ["git", "-C", str(packages / "mathlib"), "rev-parse", "HEAD"], ROOT
            ).strip()
            != pin
        ):
            raise ValueError("Dependency cache revision mismatch")
        (project / ".lake").mkdir(exist_ok=True)
        (project / ".lake/packages").symlink_to(packages, target_is_directory=True)
        shutil.copyfile(lock, project / "lake-manifest.json")
    else:
        command(["lake", "update"], project)
        command(["lake", "exe", "cache", "get"], project)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--packages-430", type=Path)
    parser.add_argument("--packages-432", type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    out = args.output.resolve()
    report = {
        "schema": "lift.tool-validation.v1",
        "fixture": [],
        "migration": {},
        "passed": False,
        "model_calls": 0,
    }
    try:
        for version in ("4.26.0", "4.30.0", "4.32.0"):
            project = out / ("fixture-" + version)
            shutil.copytree(
                ROOT / "examples/lean-json",
                project,
                ignore=shutil.ignore_patterns(".lake"),
            )
            (project / "lean-toolchain").write_text(f"leanprover/lean4:v{version}\n")
            facts = EXTRACT.extract(project, ["Fixture", "Structures", "Consumer"], [])
            records = facts["records"]
            by_name = {r["name"]: r for r in records}
            assert any(
                n.startswith("_private.") and n.endswith(".hidden") for n in by_name
            )
            assert "LIFTFixture.Box.mk" in by_name
            assert by_name["LIFTFixture.Box"]["structure_fields"] == [
                "LIFTFixture.Box.value"
            ]
            assert (
                "LIFTFixture.usesPrivate"
                in by_name["LIFTFixture.importedDependency"]["value_dependencies"]
            )
            assert (
                by_name["LIFTFixture.importedDependency"]["dependency_modules"][
                    "LIFTFixture.usesPrivate"
                ]
                == "Structures"
            )
            assert any(r["kind"] == "recursor" for r in records)
            assert by_name["LIFTFixture.Box"]["type"]
            (out / f"facts-{version}.json").write_text(
                json.dumps(facts, indent=2) + "\n"
            )
            try:
                EXTRACT.extract(project, ["Fixture"], ["Unknown.missing"])
            except ValueError:
                pass
            else:
                raise AssertionError("Missing declaration was accepted")
            report["fixture"].append(
                {
                    "version": version,
                    "declarations": len(records),
                    "private_and_generated": True,
                    "cross_module_dependencies": True,
                    "missing_name_rejected": True,
                }
            )
        baseline = out / "mathlib-430"
        shutil.copytree(
            ROOT / "examples/mathlib-migration",
            baseline,
            ignore=shutil.ignore_patterns(".lake"),
        )
        dependencies(
            baseline,
            args.packages_430,
            "c5ea00351c28e24afc9f0f84379aa41082b1188f",
            ROOT / "examples/paper-cases/beck/checkpoint/lake-manifest.json",
        )
        candidate = out / "mathlib-432"
        UPGRADE.prepare(
            baseline,
            candidate,
            "leanprover/lean4:v4.32.0",
            "81a5d257c8e410db227a6665ed08f64fea08e997",
        )
        dependencies(
            candidate,
            args.packages_432,
            "81a5d257c8e410db227a6665ed08f64fea08e997",
            ROOT / "examples/paper-cases/normal-cone/lake-manifest.json",
        )
        pair = []
        for project in (baseline, candidate):
            # Compile project sources only, using immutable prebuilt external dependencies.
            build = project / ".lake/build/lib/lean"
            build.mkdir(parents=True, exist_ok=True)
            command(
                [
                    "lake",
                    "env",
                    "lean",
                    "-j",
                    "1",
                    "-o",
                    str(build / "NormInterface.olean"),
                    "NormInterface.lean",
                ],
                project,
            )
            facts = EXTRACT.extract(
                project, ["NormInterface"], ["LIFTNorm.scale_norm"], skip_build=True
            )
            (out / (project.name + "-facts.json")).write_text(
                json.dumps(facts, indent=2) + "\n"
            )
            pair.append(facts)
            clients = UPGRADE.check_clients(
                project, baseline / "clients.json", out / (project.name + "-clients")
            )
            assert clients["status"] == "clients_passed"
        comparison = UPGRADE.compare(*pair)
        (out / "comparison.json").write_text(json.dumps(comparison, indent=2) + "\n")
        report["migration"] = {
            "comparison": comparison,
            "original_clients_per_version": 2,
            "source_unchanged": EXTRACT.snapshot(baseline)["NormInterface.lean"]
            == EXTRACT.snapshot(candidate)["NormInterface.lean"],
        }
        if comparison["status"] != "selected_facts_unchanged":
            raise ValueError("Migration requires declaration drift review")
        report["passed"] = True
    except Exception as exc:
        report["error"] = str(exc)
    (out / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
