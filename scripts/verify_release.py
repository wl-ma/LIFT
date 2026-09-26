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
    history = json.loads((ROOT / "data/lean-checks-historical.json").read_text())
    for case in history["cases"]:
        assert not case["axioms"]["sorry_axiom_present"]
        for module in case["modules"]:
            assert (
                hashlib.sha256((ROOT / module["source"]).read_bytes()).hexdigest()
                == module["source_sha256"]
            )
    checkpoint = json.loads((ROOT / "data/online-checkpoint.json").read_text())
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
        for link in re.findall(r"\]\(([^)]+)\)", document.read_text()):
            if "://" in link or link.startswith(("#", "mailto:")):
                continue
            target = link.split("#", 1)[0]
            assert (document.parent / target).exists(), (
                f"Broken link: {document}: {link}"
            )
    print(
        "Passed: corpus, action totals, 249 obligation links, five source hashes, Markdown links."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
