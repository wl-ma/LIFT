"""Ensure package checks reject changed and escaping source inputs."""

import hashlib
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from lift_artifacts.check_serial_demo import verify_files


class PackageTests(unittest.TestCase):
    def test_changed_source_is_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "ReasLib.lean"
            source.write_text("import Mathlib\n", encoding="utf-8")
            files = {source.name: hashlib.sha256(source.read_bytes()).hexdigest()}
            verify_files(root, files)
            source.write_text("axiom invented : False\n", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "changed"):
                verify_files(root, files)

    def test_paths_cannot_escape_package(self):
        with tempfile.TemporaryDirectory() as temporary:
            for name in ["../outside.lean", "/outside.lean", "..\\outside.lean"]:
                with (
                    self.subTest(name=name),
                    self.assertRaisesRegex(ValueError, "Unsafe"),
                ):
                    verify_files(Path(temporary), {name: "0" * 64})

    def test_empty_inventory_is_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            with self.assertRaisesRegex(ValueError, "empty"):
                verify_files(Path(temporary), {})


if __name__ == "__main__":
    unittest.main()
