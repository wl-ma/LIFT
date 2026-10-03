"""Exercise real Lean extraction and a labelled scripted semantic workflow."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
from lift_tools.common import digest, save  # noqa: E402


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    provider = [sys.executable, "-B", str(ROOT / "tests/fixtures/semantic_provider.py")]
    subprocess.run(
        [
            sys.executable,
            "-B",
            str(ROOT / "tools/lean_json/translate.py"),
            str(ROOT / "examples/lean-json"),
            "--module",
            "Fixture",
            "--name",
            "LIFTExample.twice_eq",
            "--model-command",
            json.dumps(provider),
            "--output",
            str(output / "natural"),
        ],
        check=True,
    )
    result = json.loads((output / "natural/translation/result.json").read_text())
    validation = json.loads((output / "natural/validation.json").read_text())
    assert result["status"] == "accepted" and result["records"][0]["repairs"] == 1
    assert result["accounting"]["command_calls"] == 4 and validation["source_unchanged"]
    save(
        output / "report.json",
        {
            "schema": "lift.workflow-validation.v1",
            "passed": True,
            "real_compiler": True,
            "provider": "deterministic_test_double",
            "semantic_quality_evaluated": False,
            "external_model_calls": 0,
            "result_hash": digest(result),
            "validation_hash": digest(validation),
        },
    )
    print(
        "Passed: real compiler, scripted rejection, repair and full review; no external model calls."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
