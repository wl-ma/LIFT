"""Reconstruct accepted Lean artifacts from the public deduplicated dataset."""

import argparse
import hashlib
import json
from pathlib import Path


def materialize(dataset: Path, destination: Path) -> int:
    blobs = {}
    for line in (dataset / "lean-sources.jsonl").read_text().splitlines():
        row = json.loads(line)
        assert hashlib.sha256(row["content"].encode()).hexdigest() == row["sha256"]
        blobs[row["sha256"]] = row["content"]
    count = 0
    for item in json.loads((dataset / "admissions.json").read_text()):
        if not item["accepted"]:
            continue
        task = Path(item["task"])
        assert len(task.parts) == 1 and task.name not in {".", ".."}
        for source in item["source_files"]:
            relative = Path(source["path"])
            assert not relative.is_absolute() and ".." not in relative.parts
            path = destination / task / relative
            assert not path.exists(), "Refuse to overwrite an existing file"
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(blobs[source["public_sha256"]])
            count += 1
    return count


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("dataset", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    print(materialize(args.dataset, args.destination))
