"""Regenerate released numerical tables from portable retained evidence records."""

from __future__ import annotations

import argparse
import csv
import io
import json
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
RECORDS = DATA / "records"


def read(path: Path) -> list[dict]:
    with path.open(encoding="utf-8", newline="") as stream:
        return list(csv.DictReader(stream))


def text(rows: list[dict], fields: list[str]) -> str:
    stream = io.StringIO(newline="")
    writer = csv.DictWriter(stream, fieldnames=fields, lineterminator="\n")
    writer.writeheader()
    writer.writerows(rows)
    return stream.getvalue()


def tables() -> dict[str, list[dict]]:
    metadata = json.loads((RECORDS / "project-metadata.json").read_text())
    stages = {(r["project"], r["stage"]): r for r in read(RECORDS / "stage-counts.csv")}
    manifests = Counter(
        r["project"] for r in read(RECORDS / "integration-manifests.csv")
    )
    modules = read(RECORDS / "modules.csv")
    module_counts = Counter(r["project"] for r in modules)
    unfinished = Counter(
        r["project"] for r in modules if int(r["sorry_admit_tokens"]) > 0
    )
    corpus = []
    for project in metadata:
        key = project["project"]
        stage = stages[(key, "library_integration")]
        corpus.append(
            {
                **project,
                "catalogue_items": stage["total"],
                "integrated_items": stage["success"],
                "public_module_occurrences": module_counts[key],
                "modules_with_sorry_text": unfinished[key],
                "integration_manifests": manifests[key],
            }
        )
    counts = Counter((r["project"], r["action"]) for r in read(RECORDS / "actions.csv"))
    actions = []
    for row in read(DATA / "declaration-actions.csv"):
        key = row["project"]
        actions.append(
            {
                field: key if field == "project" else counts[(key, field)]
                for field in row
            }
        )
    profile = Counter()
    for module in modules:
        parts = Path(module["path"]).parts
        profile[(module["project"], parts[1] if len(parts) > 2 else "Root")] += 1
    profiles = [
        {"project": p, "area": a, "module_occurrences": n}
        for (p, a), n in sorted(profile.items())
    ]
    all_tasks = json.loads((RECORDS / "proof-stages.json").read_text())
    identities = json.loads((RECORDS / "obligation-identities.json").read_text())
    obligations, links, batches = [], [], []
    for unit in identities:
        tasks = [
            r
            for r in all_tasks
            if r["project"] == unit["project"] and r["stage"] == "proof"
        ]
        exact = [r for r in tasks if unit["proof_unit_id"] in r["proof_unit_ids"]]
        fallback = [
            r
            for r in tasks
            if r["declaration"] == unit["declaration"]
            and r["owner_file"] == unit["owner_file"]
        ]
        matched = exact or fallback
        kind = (
            "proof_unit_id"
            if exact
            else "declaration_and_owner"
            if fallback
            else "unmatched"
        )
        success = any(r["status"] == "success" for r in matched)
        row = {k: v for k, v in unit.items() if k != "proof_unit_id"}
        row.update(match_kind=kind, proof_stage_success=str(success))
        obligations.append(row)
        for task in matched:
            links.append(
                {
                    "obligation": row["obligation"],
                    "project": row["project"],
                    "proof_task": task["task"],
                    "declaration": row["declaration"],
                    "match_kind": kind,
                    "proof_stage_success": str(success),
                }
            )
    for original in read(DATA / "proof-handoff.csv"):
        project = original["project"]
        tasks = [r for r in all_tasks if r["project"] == project]
        units = [r for r in obligations if r["project"] == project]
        batches.append(
            {
                "project": project,
                **{
                    f"{stage}_success"
                    if stage != "proof"
                    else "proof_work_success": sum(
                        r["stage"] == stage and r["status"] == "success" for r in tasks
                    )
                    for stage in ("statement", "integration", "proof")
                },
                "pending_units_after_integration": len(units),
                "exact_id_success_links": sum(
                    r["match_kind"] == "proof_unit_id"
                    and r["proof_stage_success"] == "True"
                    for r in units
                ),
                "declaration_owner_success_links": sum(
                    r["match_kind"] == "declaration_and_owner"
                    and r["proof_stage_success"] == "True"
                    for r in units
                ),
                "unresolved_links": sum(
                    r["proof_stage_success"] != "True" for r in units
                ),
            }
        )
    return {
        "construction.csv": corpus,
        "declaration-actions.csv": actions,
        "module-profile.csv": profiles,
        "proof-handoff.csv": batches,
        "proof-obligations.csv": obligations,
        "proof-task-links.csv": links,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--output", type=Path, default=ROOT / "_runs/reproduced-tables")
    args = parser.parse_args()
    selection = read(RECORDS / "selection.csv")
    counts = Counter(r["selection"] for r in selection)
    if len(selection) != 61 or counts["representative_mathematical_project"] != 20:
        raise ValueError("Selection does not preserve the 61-to-20 corpus")
    products = tables()
    for name, rows in products.items():
        original = read(DATA / name)
        fields = list(original[0])
        rendered = text(rows, fields)
        expected = text(original, fields)
        if sorted(rendered.splitlines()) != sorted(expected.splitlines()):
            raise ValueError(
                f"Recomputed table differs from the released table: {name}"
            )
        if not args.check:
            args.output.mkdir(parents=True, exist_ok=True)
            (args.output / name).write_text(rendered, encoding="utf-8")
    report = {
        "schema": "lift.table-reproduction.v1",
        "tables": list(products),
        "selection": dict(counts),
        "model_calls": 0,
        "scope": "Recorded stage aggregates; individual actions, module occurrences and recomputed proof matching. Not kernel verification of every obligation.",
    }
    if not args.check:
        (args.output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
        latex = []
        for name, rows in products.items():
            if name in {
                "proof-obligations.csv",
                "proof-task-links.csv",
                "module-profile.csv",
            }:
                continue
            fields = list(read(DATA / name)[0])

            def esc(value: object) -> str:
                return (
                    str(value)
                    .replace("_", r"\_")
                    .replace("%", r"\%")
                    .replace("&", r"\&")
                )

            latex += [
                "% " + name,
                r"\begin{tabular}{" + "l" * len(fields) + "}",
                " & ".join(map(esc, fields)) + r" \\",
            ]
            latex += [" & ".join(esc(row[f]) for f in fields) + r" \\" for row in rows]
            latex += [r"\end{tabular}", ""]
        (args.output / "tables.tex").write_text(
            "\n".join(latex) + "\n", encoding="utf-8"
        )
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
