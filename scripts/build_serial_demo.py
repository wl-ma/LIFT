"""Build the serial ReasLib result page from its reviewed public dataset."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from lift_artifacts.serial_demo import main  # noqa: E402

if __name__ == "__main__":
    raise SystemExit(main())
