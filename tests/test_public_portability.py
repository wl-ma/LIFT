"""Keep public executable tools independent of private backends and host paths."""

import ast
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRIVATE_IMPORTS = {"m2f", "m2f_private", "m2f_sdk", "orchestrator", "leantegrate"}
HOST_PATH = re.compile(
    r"/(?:home|Users)/[^/\s]+/|/root/workspace/|[A-Z]:[/\\](?:MA|Users)[/\\]"
)


class PublicPortabilityTests(unittest.TestCase):
    def test_all_public_python_entrypoints_are_portable(self):
        for directory in ("src", "tools", "scripts"):
            for path in (ROOT / directory).rglob("*.py"):
                with self.subTest(path=str(path.relative_to(ROOT))):
                    text = path.read_text(encoding="utf-8")
                    self.assertIsNone(HOST_PATH.search(text))
                    for node in ast.walk(ast.parse(text)):
                        names = (
                            [alias.name for alias in node.names]
                            if isinstance(node, ast.Import)
                            else [node.module or ""]
                            if isinstance(node, ast.ImportFrom)
                            else []
                        )
                        for name in names:
                            self.assertNotIn(
                                name.split(".")[0].lower(), PRIVATE_IMPORTS
                            )


if __name__ == "__main__":
    unittest.main()
