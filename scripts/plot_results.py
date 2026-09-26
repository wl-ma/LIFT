"""Plot reproducible corpus decisions and the recorded online revision."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]


def read(name: str) -> list[dict]:
    with (ROOT / "data" / name).open(encoding="utf-8", newline="") as stream:
        return list(csv.DictReader(stream))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "_runs/figures")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    rows = read("declaration-actions.csv")
    fields = ["reuse_existing", "promote", "retention", "remove"]
    for row in rows:
        row["retention"] = int(row["keep_source"]) + int(row["keep_item_local"])
    totals = [sum(int(row[field]) for field in fields) for row in rows]
    plt.rcParams.update({"svg.hashsalt": "lift-v13", "font.family": "DejaVu Sans"})
    fig, ax = plt.subplots(figsize=(10, 8))
    bottom = [0] * len(rows)
    for field in fields:
        values = [100 * int(row[field]) / total for row, total in zip(rows, totals)]
        ax.barh(
            [r["project"] for r in rows],
            values,
            left=bottom,
            label=field.replace("_", " "),
        )
        bottom = [x + y for x, y in zip(bottom, values)]
    ax.set_xlim(0, 100)
    ax.set_xlabel("Share of recorded declaration actions (%)")
    ax.legend(loc="lower center", bbox_to_anchor=(0.5, 1.01), ncol=4)
    fig.tight_layout()
    for ext in ("svg", "pdf", "png"):
        fig.savefig(
            args.output / f"action-profile.{ext}",
            metadata={"Date": None} if ext == "svg" else None,
        )
    plt.close(fig)
    rows = read("online-trace.csv")
    fig, ax = plt.subplots(figsize=(10, 4))
    for i, row in enumerate(rows):
        x = int(row["sequence"])
        ax.scatter(x, 0, color="#166e85", s=50)
        ax.annotate(
            row["event"].replace("_", "\n"),
            (x, 0),
            xytext=(0, 35 if i % 2 == 0 else -65),
            textcoords="offset points",
            ha="center",
            fontsize=8,
        )
    ax.plot([int(r["sequence"]) for r in rows], [0] * len(rows), color="#166e85")
    ax.set_ylim(-1, 1)
    ax.set_yticks([])
    ax.set_xlabel("Original event sequence")
    ax.set_title("Beck revision: updated context followed by source checkpoint")
    fig.tight_layout()
    for ext in ("svg", "pdf", "png"):
        fig.savefig(
            args.output / f"online-trace.{ext}",
            metadata={"Date": None} if ext == "svg" else None,
        )
    plt.close(fig)
    report = {
        "inputs": {
            n: hashlib.sha256((ROOT / "data" / n).read_bytes()).hexdigest()
            for n in ("declaration-actions.csv", "online-trace.csv")
        },
        "scope": "Recomputed figures from the paper data; publication typography may differ.",
        "matplotlib_version": matplotlib.__version__,
    }
    (args.output / "manifest.json").write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
