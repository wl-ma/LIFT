"""Translate and semantically review compiled declarations."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "src"))
from lift_tools.natural import main  # noqa: E402

if __name__ == "__main__":
    raise SystemExit(main())
