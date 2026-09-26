"""Build a self-contained offline browser from the released evidence tables."""

from __future__ import annotations

import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    with (ROOT / "data/construction.csv").open(newline="") as stream:
        corpus = list(csv.DictReader(stream))
    with (ROOT / "data/online-trace.csv").open(newline="") as stream:
        trace = list(csv.DictReader(stream))
    payload = json.dumps(
        {"corpus": corpus, "trace": trace}, ensure_ascii=False
    ).replace("<", "\\u003c")
    template = (ROOT / "demo/template.html").read_text()
    (ROOT / "demo/index.html").write_text(
        template.replace("/* RELEASE_DATA */ null", payload)
    )
    print("Built demo/index.html from the released construction and event tables.")


if __name__ == "__main__":
    main()
