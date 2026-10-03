"""Build and audit the complete released three-source ReasLib project."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import time
from pathlib import Path, PurePosixPath

from .check_case import audit_output
from .paths import ROOT
from .serial_demo import validate


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verify_files(project: Path, files: dict[str, str]) -> None:
    """Check every registered source and reject traversal or linked inputs."""
    if not files:
        raise ValueError("The package source inventory is empty")
    for name, expected in files.items():
        relative = PurePosixPath(name)
        if relative.is_absolute() or ".." in relative.parts or "\\" in name:
            raise ValueError("Unsafe package path")
        path = project
        for part in relative.parts:
            path /= part
            if path.is_symlink():
                raise ValueError("A registered source cannot be a symbolic link")
        if not path.is_file() or digest(path) != expected:
            raise ValueError(f"Package source changed: {name}")


def axiom_command(name: str) -> str:
    """Construct Lean names so private numeric components remain numeric."""
    expression = "Lean.Name.anonymous"
    for part in name.split("."):
        if part.isdecimal():
            expression = f"(Lean.Name.num {expression} {int(part)})"
        else:
            expression = (
                f"(Lean.Name.str {expression} {json.dumps(part, ensure_ascii=False)})"
            )
    return (
        "run_cmd Lean.Elab.Command.elabCommand (← `(command| #print axioms "
        + "$(Lean.mkIdent "
        + expression
        + ")))\n"
    )


def check(project: Path, data: Path, package: Path, output: Path) -> dict:
    """Require the pinned environment, source identities and full axiom coverage."""
    dataset = json.loads(data.read_text(encoding="utf-8"))
    config = json.loads(package.read_text(encoding="utf-8"))
    validate(dataset)
    verify_files(project, config["files"])
    names = config["library_declarations"]
    latest = dataset["releases"][-1]
    if set(names) != {row["name"] for row in latest["declarations"]} or len(
        names
    ) != len(set(names)):
        raise ValueError("The complete library declaration inventories disagree")
    if config["accepted_source_identity"] != latest["result"]["source_identity"]:
        raise ValueError("The package does not bind the accepted release")
    lock = json.loads((project / "lake-manifest.json").read_text(encoding="utf-8"))
    if (
        next(row["rev"] for row in lock["packages"] if row["name"] == "mathlib")
        != config["mathlib_revision"]
    ):
        raise ValueError("The Mathlib dependency pin changed")
    output.mkdir(parents=True, exist_ok=False)
    started = time.monotonic()
    runs = []

    def execute(label: str, arguments: list[str]) -> str:
        result = subprocess.run(
            arguments,
            cwd=project,
            capture_output=True,
            text=True,
            timeout=1800,
            check=False,
        )
        (output / (label + ".log")).write_text(
            result.stdout + result.stderr, encoding="utf-8"
        )
        runs.append({"check": label, "returncode": result.returncode})
        if result.returncode:
            raise ValueError(f"Lean check failed: {label}; inspect its output log")
        return result.stdout

    version = execute("version", ["lake", "env", "lean", "--version"])
    if f"version {config['lean_version']}," not in version:
        raise ValueError("The active Lean compiler differs from the release pin")
    execute("build", ["lake", "build", *config.get("source_modules", [])])
    audit = output / "LibraryAudit.lean"
    audit.write_text(
        "".join(
            f"import {module}\n"
            for module in config.get("library_modules", ["ReasLib"])
        )
        + "import Lean\n\n"
        + "".join(axiom_command(name) for name in names),
        encoding="utf-8",
    )
    library_axioms = audit_output(
        execute("library-axioms", ["lake", "env", "lean", str(audit.resolve())]), names
    )
    clients = {}
    compile_only_clients = 0
    for index, (name, expected) in enumerate(config["clients"].items()):
        if name not in config["files"]:
            raise ValueError("Client source is not bound by the package manifest")
        stdout = execute(f"clients-{index}", ["lake", "env", "lean", name])
        if "declaration uses 'sorry'" in stdout or "sorryAx" in stdout:
            raise ValueError(f"An unfinished client proof was accepted: {name}")
        if expected:
            clients[name] = audit_output(stdout, expected)
        else:
            compile_only_clients += 1
            clients[name] = {"compiled": True}
    verify_files(project, config["files"])
    report = {
        "schema_version": 1,
        "passed": True,
        "accepted_source_identity": config["accepted_source_identity"],
        "package_source_identity": config["package_source_identity"],
        "dataset_sha256": digest(data),
        "package_manifest_sha256": digest(package),
        "lean_version": version.strip(),
        "mathlib_revision": config["mathlib_revision"],
        "library_axioms": library_axioms,
        "clients": clients,
        "compile_only_client_files": compile_only_clients,
        "fixed_source_client_checks": config.get("fixed_source_client_checks", 0),
        "extension_boundary_examples": config.get("extension_boundary_examples", 0),
        "checks": runs,
        "elapsed_seconds": time.monotonic() - started,
        "model_calls": 0,
    }
    (output / "report.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8"
    )
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--project", type=Path, default=ROOT / "examples/reaslib-serial"
    )
    parser.add_argument(
        "--data",
        type=Path,
        default=ROOT / "experiments/serial-library-growth/results/demo.json",
    )
    parser.add_argument(
        "--package",
        type=Path,
        default=ROOT / "experiments/serial-library-growth/results/package.json",
    )
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    report = check(
        args.project.resolve(),
        args.data.resolve(),
        args.package.resolve(),
        args.output.resolve(),
    )
    print(
        f"ReasLib verified: {len(report['library_axioms'])} library declarations; {sum(len(rows) for rows in report['clients'].values())} registered client checks."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
