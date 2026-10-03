"""Compatibility command-line entry point for standalone LIFT tools."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "src"))
from lift_tools.migration import *  # noqa: F403,E402
from lift_tools.migration import main  # noqa: E402

if __name__ == "__main__":
    raise SystemExit(main())
