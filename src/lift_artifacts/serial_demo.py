"""Render a portable serial-library report from reviewed public records."""

from __future__ import annotations

import argparse
import html
import json
import math
from pathlib import Path


def count(value: object) -> int:
    """Require a measured nonnegative count rather than a truthy substitute."""
    if type(value) is not int or value < 0:
        raise ValueError("Invalid measured count")
    return value


def display(value: int | float | None) -> str:
    """Keep unavailable measurements explicitly unavailable."""
    if value is None:
        return "Not measured"
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValueError("Invalid measurement")
    if not math.isfinite(value) or value < 0:
        raise ValueError("Invalid measurement")
    return f"{value:,.0f}" if isinstance(value, int) else f"{value:,.1f}"


def escape(value: object) -> str:
    return html.escape(str(value), quote=True)


def validate(data: dict) -> None:
    """Cross-check release coverage, declaration trust and execution accounting."""
    if data.get("schema_version") not in {1, 2}:
        raise ValueError("Unknown report schema")
    books = data["sources"]["books"]
    expected_batches = 3 if data["schema_version"] == 1 else 6
    if [book["batch"] for book in books] != [f"B{i}" for i in range(expected_batches)]:
        raise ValueError("All planned source batches must remain visible")
    if any(len(book["items"]) != 2 for book in books):
        raise ValueError("Each frozen source batch must retain its two units")
    releases = data["releases"]
    if not releases or len(releases) > expected_batches:
        raise ValueError(
            "Expected accepted snapshots within the registered batch count"
        )
    for index, release in enumerate(releases):
        if release["result"]["release"] != f"R{index}":
            raise ValueError("Releases must be contiguous and ordered")
        if release.get("mathematical_review_accepted") is not True:
            raise ValueError("A native success is not a reviewed release")
        result = release["result"]
        preservation = result["source_preservation"]
        if [row["batch"] for row in preservation] != [
            f"B{i}" for i in range(index + 1)
        ]:
            raise ValueError("Cumulative source preservation is incomplete")
        for row in preservation:
            count(row.get("representation_obligations", 0))
            if (
                row["clients_passed"] is not True
                or count(row["source_interfaces"]) == 0
            ):
                raise ValueError("Original source clients must pass")
        declarations = release["declarations"]
        if not declarations or len({row["name"] for row in declarations}) != len(
            declarations
        ):
            raise ValueError("Declaration inventory is empty or duplicated")
        if not all(row["trusted"] is True and row["type"] for row in declarations):
            raise ValueError("Complete trusted declarations are required")
        if release["inventory_complete"] is not True:
            raise ValueError("Private and generated declarations must be included")
        executions = release["execution_components"]
        if not executions or not result["failed_attempt_costs_retained"]:
            raise ValueError("Complete attempt accounting is required")
        usage = result.get("batch_usage", result["batch_settled_usage"])
        for public_key, execution_key in [
            ("tokens", "tokens"),
            ("logical_model_calls", "model_calls"),
            ("provider_retries", "provider_retries"),
        ]:
            if usage[public_key] is not None:
                count(usage[public_key])
            values = [component[execution_key] for component in executions]
            for value in values:
                if value is not None:
                    count(value)
            expected = None if any(value is None for value in values) else sum(values)
            if usage[public_key] != expected:
                raise ValueError("Release cost disagrees with execution records")
        for component in executions:
            if not component["failed_attempt_costs_retained"]:
                raise ValueError("Failed execution attempts cannot be omitted")
            display(component["execution_seconds"])
            if not component["stage_attempts"]:
                raise ValueError("Native stage attempts must remain visible")
            for key in ("tokens", "model_calls"):
                values = [row[key] for row in component["stage_attempts"]]
                for value in values:
                    if value is not None:
                        count(value)
                expected = (
                    None if any(value is None for value in values) else sum(values)
                )
                if component[key] != expected:
                    raise ValueError(
                        "Stage-attempt costs disagree with execution totals"
                    )
            for attempt in component["stage_attempts"]:
                if attempt["native_status"] not in {
                    "success",
                    "failed",
                    "blocked",
                    "skipped",
                    "interrupted",
                }:
                    raise ValueError("An execution attempt is not terminal")
                display(attempt["tokens"])
                display(attempt["model_calls"])
                display(attempt["elapsed_seconds"])
            interrupted = [
                row
                for row in component["stage_attempts"]
                if row["native_status"] == "interrupted"
            ]
            if interrupted:
                if (
                    count(component.get("unsettled_interrupted_attempts"))
                    != len(interrupted)
                    or component.get("actual_usage_complete") is not False
                ):
                    raise ValueError(
                        "Interrupted attempts need explicit incomplete accounting"
                    )
                if any(
                    row.get(key) is not None
                    for row in interrupted
                    for key in ("tokens", "model_calls", "provider_retries")
                ):
                    raise ValueError("Interrupted usage cannot be reported as measured")
            if "settled_usage" in component:
                for key in ("tokens", "model_calls"):
                    values = [
                        row.get("settled_usage", row)[key]
                        for row in component["stage_attempts"]
                    ]
                    expected = (
                        None
                        if any(v is None for v in values)
                        else sum(count(v) for v in values)
                    )
                    if data["schema_version"] == 2 and key == "tokens":
                        expected = sum(count(v) for v in values if v is not None)
                    if component["settled_usage"][key] != expected:
                        raise ValueError(
                            "Settled subtotal disagrees with visible attempts"
                        )
        if "batch_usage" in result:
            for public_key, execution_key in (
                ("tokens", "tokens"),
                ("logical_model_calls", "model_calls"),
                ("provider_retries", "provider_retries"),
            ):
                values = [
                    component.get("settled_usage", component)[execution_key]
                    for component in executions
                ]
                expected = (
                    None
                    if any(v is None for v in values)
                    else sum(count(v) for v in values)
                )
                if result["batch_settled_usage"][public_key] != expected:
                    raise ValueError(
                        "Release settled subtotal disagrees with execution records"
                    )


def render(data: dict) -> str:
    """Build a self-contained page without remote assets or embedded raw logs."""
    validate(data)
    books = data["sources"]["books"]
    releases = data["releases"]
    parts = [
        '<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>ReasLib · Serial library growth</title>',
        "<style>body{font:16px/1.6 system-ui,sans-serif;color:#172c3a;background:#f4f6f7;margin:0}main{max-width:1120px;margin:auto;padding:36px 24px}h1{font-size:42px;line-height:1.1}h2{margin-top:0}section{background:white;border:1px solid #dce3e7;border-radius:12px;padding:24px;margin:24px 0}.eyebrow{color:#25685b;font-weight:700;letter-spacing:.12em}.summary{display:flex;gap:28px;flex-wrap:wrap}.metric strong{display:block;font-size:28px}table{width:100%;border-collapse:collapse}td,th{padding:10px 8px;border-bottom:1px solid #e3e8eb;text-align:left;vertical-align:top}code{overflow-wrap:anywhere}pre{white-space:pre-wrap;overflow-wrap:anywhere;font-size:13px;padding:14px;background:#f4f6f7}details{border-top:1px solid #e3e8eb;padding:10px 0}summary{cursor:pointer;font-weight:600}small,.muted{color:#526777}input{box-sizing:border-box;width:100%;padding:12px;border:1px solid #aabdc6;border-radius:6px;font:inherit}.table-scroll{overflow-x:auto}.hidden{display:none}@media(max-width:600px){h1{font-size:32px}main{padding:20px 12px}section{padding:16px}}</style><main>",
        '<div class="eyebrow">LIFT / REASLIB</div><h1>One library. Three mathematical sources.</h1><p>Sequential construction, source recovery, and cumulative verification in one Lean project.</p>',
        f'<div class="summary"><div class="metric"><strong>{len(releases)} / {len(books)}</strong>accepted releases</div><div class="metric"><strong>{2 * len(releases)} / {2 * len(books)}</strong>selected source units recovered</div><div class="metric"><strong>{len(releases[-1]["declarations"])}</strong>trusted declarations in the latest release</div></div>',
        "<section><h2>Sources and construction order</h2><ol>",
    ]
    for book in books:
        labels = "; ".join(item["label"] for item in book["items"])
        parts.append(
            f'<li><strong>{escape(book["title"])}</strong> ({escape(book["year"])})<br><span class="muted">{escape(labels)} · pages {escape(book["pages"])}</span></li>'
        )
    parts.append(
        "</ol><p>Each batch runs statement preparation, library integration and proof. A release also restores every earlier source interface and passes the accumulated clients.</p></section>"
    )
    for index, release in enumerate(releases):
        result = release["result"]
        usage = result.get("batch_usage", result["batch_settled_usage"])
        interfaces = sum(
            row["source_interfaces"] for row in result["source_preservation"]
        )
        obligations = sum(
            row.get("representation_obligations", 0)
            for row in result["source_preservation"]
        )
        obligation_note = (
            f" · {obligations} representation obligations verified"
            if obligations
            else ""
        )
        parts.append(
            f'<section id="R{index}"><div class="eyebrow">R{index} · ACCEPTED</div><h2>{escape(books[index]["title"])}</h2><p>{len(release["declarations"])} trusted declarations · {interfaces} original source interfaces restored{obligation_note} · cumulative clients passed</p><div class="summary"><div class="metric"><strong>{display(usage["tokens"])}</strong>batch tokens</div><div class="metric"><strong>{display(usage["logical_model_calls"])}</strong>model calls</div><div class="metric"><strong>{display(usage["provider_retries"])}</strong>provider retries</div></div><p>Batch usage includes failed attempts and source-interface recovery.</p><details><summary>All execution attempts</summary><div class="table-scroll"><table><thead><tr><th>Stage / source item</th><th>Attempt</th><th>Outcome</th><th>Tokens</th><th>Seconds</th></tr></thead><tbody>'
        )
        interrupted = sum(
            component.get("unsettled_interrupted_attempts", 0)
            for component in release["execution_components"]
        )
        if interrupted:
            settled = result["batch_settled_usage"]
            # Keep the summary outside the table so its layout remains accessible.
            parts[-1] = parts[-1].replace(
                "<details><summary>All execution attempts",
                f"<p>Settled subtotal: {display(settled['tokens'])} tokens · {display(settled['logical_model_calls'])} calls. {interrupted} interrupted attempt(s) have unreported usage.</p><details><summary>All execution attempts",
            )
        if data["schema_version"] == 2:
            # Present final releases and accounting, keeping detailed attempt records downloadable.
            parts[-1] = parts[-1].split("<details>")[0]
            settled = result["batch_settled_usage"]
            parts.append(
                f"<p>Known settled usage: {display(settled['tokens'])} tokens; "
                f"{display(settled['logical_model_calls'])} recorded calls. "
                "Construction and interface recovery are included.</p></section>"
            )
            continue
        for number, component in enumerate(release["execution_components"], 1):
            for attempt in component["stage_attempts"]:
                parts.append(
                    f"<tr><td>{escape(attempt['stage'])}<br><small>{escape(attempt['source_item'])}</small></td><td>{number}.{count(attempt['attempt'])}</td><td>{escape(attempt['native_status'])}<br><small>{escape(attempt.get('failure_code') or '')}</small></td><td>{display(attempt['tokens'])}</td><td>{display(attempt['elapsed_seconds'])}</td></tr>"
                )
        parts.append("</tbody></table></div></details></section>")
    parts.append(
        '<section><h2>Latest library interfaces and dependencies</h2><label for="search">Find a declaration</label><input id="search" type="search" placeholder="Name or module"><p class="muted">Complete compiled types and direct dependencies, including private and generated declarations.</p>'
    )
    for row in releases[-1]["declarations"]:
        dependencies = (
            ", ".join(row["controlled_value_dependencies"])
            or "No direct dependency on another declaration in this library."
        )
        parts.append(
            f'<details class="declaration" data-search="{escape(row["name"] + " " + row["module"])}"><summary><code>{escape(row["name"])}</code></summary><p>{escape(row["module"])}</p><pre>{escape(row["type"])}</pre><p><strong>Direct library dependencies</strong><br><code>{escape(dependencies)}</code></p></details>'
        )
    parts.append(
        "</section><p class=\"muted\">Independent clients are evaluator-written checks. Source-unit counts, declaration counts and native proof attempts use separate denominators. Execution outcomes do not by themselves certify a release; release cards require the mathematical review and cumulative preservation evidence.</p></main><script>document.getElementById('search').addEventListener('input',function(){const q=this.value.toLowerCase();document.querySelectorAll('.declaration').forEach(function(item){item.classList.toggle('hidden',!item.dataset.search.toLowerCase().includes(q));});});</script></html>"
    )
    return "\n".join(parts)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists():
        raise ValueError("Use a new output path to preserve an earlier rendering")
    page = render(json.loads(args.data.read_text(encoding="utf-8")))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(page, encoding="utf-8")
    return 0
