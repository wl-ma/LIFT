"""Ensure public imports and executable payloads do not depend on an engine checkout."""

import ast
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class BoundaryTests(unittest.TestCase):
    def test_public_packages_have_no_private_engine_import(self):
        for file in (ROOT / "src").rglob("*.py"):
            for node in ast.walk(ast.parse(file.read_text())):
                names = (
                    [x.name for x in node.names]
                    if isinstance(node, ast.Import)
                    else [node.module or ""]
                    if isinstance(node, ast.ImportFrom)
                    else []
                )
                for name in names:
                    self.assertNotIn(
                        name.split(".")[0].lower(),
                        {
                            "m2f",
                            "m2f_private",
                            "m2f_sdk",
                            "orchestrator",
                            "leantegrate",
                        },
                        str(file),
                    )

    def test_imports_work_in_isolated_python_without_engine(self):
        code = "import sys; sys.path.insert(0, sys.argv[1]); from lift_tools import compiler, natural, migration, repair, provider, http_model; assert not any(n.split('.')[0].lower() in {'m2f', 'm2f_private', 'm2f_sdk', 'orchestrator', 'leantegrate'} for n in sys.modules)"
        subprocess.run(
            [sys.executable, "-I", "-B", "-c", code, str(ROOT / "src")],
            check=True,
            cwd=ROOT,
        )

    def test_extractor_compatibility_copy_matches_package(self):
        self.assertEqual(
            (ROOT / "tools/lean_json/HarnessFacts.lean").read_bytes(),
            (ROOT / "src/lift_tools/HarnessFacts.lean").read_bytes(),
        )


if __name__ == "__main__":
    unittest.main()
