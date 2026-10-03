"""Refresh the reviewed publication manifest; never called by verification."""

import hashlib
import json
import subprocess

from .paths import ROOT


def main() -> None:
    """Bind public tracked and non-ignored files, excluding the manifest itself."""
    paths = (
        subprocess.check_output(
            ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
            cwd=ROOT,
        )
        .decode()
        .split("\0")
    )
    files = {}
    for name in sorted(set(filter(None, paths))):
        path = ROOT / name
        if name == "metadata/artifact-manifest.json" or not path.is_file():
            continue
        if not path.resolve().is_relative_to(ROOT):
            raise ValueError(f"File escapes the publication root: {name}")
        files[name] = hashlib.sha256(path.read_bytes()).hexdigest()
    result = {"schema": "lift.artifact-manifest.v1", "files": files}
    (ROOT / "metadata/artifact-manifest.json").write_text(
        json.dumps(result, indent=2) + "\n", encoding="utf-8"
    )
    print(f"Bound {len(files)} reviewed publication files")


if __name__ == "__main__":
    main()
