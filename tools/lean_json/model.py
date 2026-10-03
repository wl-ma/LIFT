"""Run the environment-configured independent JSON model adapter."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "src"))
from lift_tools.http_model import main  # noqa: E402

if __name__ == "__main__":
    raise SystemExit(main())
