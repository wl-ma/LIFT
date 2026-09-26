"""Check published table totals, obligation links, source hashes and local links."""

from __future__ import annotations

import csv
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def rows(name: str) -> list[dict[str, str]]:
    with (ROOT / "data" / name).open(newline="") as stream:
        return list(csv.DictReader(stream))


def main() -> int:
    corpus = rows("construction.csv")
    assert len(corpus) == 20
    assert sum(int(r["catalogue_items"]) for r in corpus) == 10922
    assert sum(int(r["integrated_items"]) for r in corpus) == 5061
    assert sum(int(r["public_module_occurrences"]) for r in corpus) == 15716
    actions = rows("declaration-actions.csv")
    for key, expected in {
        "reuse_existing": 8854,
        "promote": 19253,
        "remove": 3283,
        "keep_source": 2001,
        "keep_item_local": 567,
    }.items():
        assert sum(int(r[key]) for r in actions) == expected, key
    handoff = rows("proof-handoff.csv")
    obligations = rows("proof-obligations.csv")
    assert len(handoff) == 7 and len(obligations) == 249
    assert sum(int(r["integration_success"]) for r in handoff) == 118
    assert sum(int(r["proof_work_success"]) for r in handoff) == 135
    assert (
        sum(
            int(r["exact_id_success_links"]) + int(r["declaration_owner_success_links"])
            for r in handoff
        )
        == 249
    )
    for batch in handoff:
        linked = [o for o in obligations if o["project"] == batch["project"]]
        assert len(linked) == int(batch["pending_units_after_integration"])
        assert all(o["proof_stage_success"] == "True" for o in linked)
    task_links = rows("proof-task-links.csv")
    obligation_index = {o["obligation"]: o for o in obligations}
    assert len(obligation_index) == 249
    assert {r["obligation"] for r in task_links} == set(obligation_index)
    assert len(task_links) == 258
    assert len({r["proof_task"] for r in task_links}) == 72
    for link in task_links:
        source = obligation_index[link["obligation"]]
        for key in ("project", "declaration", "match_kind", "proof_stage_success"):
            assert link[key] == source[key], (link["obligation"], key)
    taylor = [r for r in task_links if r["declaration"].startswith("Taylor.")]
    assert len(taylor) == 3
    assert {r["proof_task"] for r in taylor} == {"proof-task-0001"}
    provenance = json.loads(
        (ROOT / "data/release-provenance.json").read_text(encoding="utf-8")
    )
    for entry in provenance["files"]:
        assert (
            hashlib.sha256((ROOT / entry["path"]).read_bytes()).hexdigest()
            == entry["sha256"]
        ), entry["path"]
    summary = json.loads((ROOT / "data/summary.json").read_text(encoding="utf-8"))
    assert summary["paper_snapshot"] == "version10"
    assert summary["projects"] == len(corpus)
    assert summary["linked_obligations"] == len(obligations)
    assert summary["declaration_actions"] == {
        key: sum(int(r[key]) for r in actions) for key in summary["declaration_actions"]
    }
    demo_data = json.dumps(
        {"corpus": corpus, "trace": rows("online-trace.csv")}, ensure_ascii=False
    ).replace("<", "\\u003c")
    expected_demo = (
        (ROOT / "demo/template.html")
        .read_text(encoding="utf-8")
        .replace("/* RELEASE_DATA */ null", demo_data)
    )
    assert (ROOT / "demo/index.html").read_text(encoding="utf-8") == expected_demo, (
        "Regenerate the demo"
    )
    history = json.loads(
        (ROOT / "data/lean-checks-historical.json").read_text(encoding="utf-8")
    )
    for case in history["cases"]:
        assert not case["axioms"]["sorry_axiom_present"]
        for module in case["modules"]:
            assert (
                hashlib.sha256((ROOT / module["source"]).read_bytes()).hexdigest()
                == module["source_sha256"]
            )
    checkpoint = json.loads(
        (ROOT / "data/online-checkpoint.json").read_text(encoding="utf-8")
    )
    assert len(checkpoint["declarations"]) == 20
    assert all(d["original_type_preserved"] for d in checkpoint["declarations"])
    assert (
        sum(
            d["kind"] == "theorem" and d["trusted_proof"]
            for d in checkpoint["declarations"]
        )
        == 15
    )
    assert len(checkpoint["clients"]) == 22
    assert all(c["passed"] for c in checkpoint["clients"])
    for document in ROOT.rglob("*.md"):
        if any(p in {".git", ".lake", "_runs", "_build"} for p in document.parts):
            continue
        for link in re.findall(r"\]\(([^)]+)\)", document.read_text(encoding="utf-8")):
            if "://" in link or link.startswith(("#", "mailto:")):
                continue
            target = link.split("#", 1)[0]
            assert (document.parent / target).exists(), (
                f"Broken link: {document}: {link}"
            )
    print(
        "Passed: corpus, action totals, 249 obligations, 258 task links, provenance hashes, demo freshness, Markdown links."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
