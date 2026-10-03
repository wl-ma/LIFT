"""Build a self-contained offline browser from the released evidence tables."""

from __future__ import annotations

import csv
import json

from .paths import ROOT


def main() -> None:
    with (ROOT / "experiments/corpus-construction/results/construction.csv").open(
        newline=""
    ) as stream:
        corpus = list(csv.DictReader(stream))
    with (ROOT / "experiments/online-revision/results/online-trace.csv").open(
        newline=""
    ) as stream:
        trace = list(csv.DictReader(stream))
    payload = json.dumps(
        {"corpus": corpus, "trace": trace}, ensure_ascii=False
    ).replace("<", "\\u003c")
    template = (ROOT / "demo/template.html").read_text(encoding="utf-8")
    (ROOT / "demo/index.html").write_text(
        template.replace("/* RELEASE_DATA */ null", payload)
    )
    print("Built demo/index.html from the released construction and event tables.")


if __name__ == "__main__":
    main()
