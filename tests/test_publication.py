"""Check attribution projections without weakening mathematical evidence."""

import hashlib
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from lift_artifacts.publication import (  # noqa: E402
    HEADER,
    matches_record,
    validate_source,
)


class PublicationTests(unittest.TestCase):
    def setUp(self):
        self.body = b"theorem identity (n : Nat) : n = n := rfl\n"
        self.data = HEADER + self.body
        self.entry = {
            "transformation": "attribution_header_only",
            "source_sha256": "a" * 64,
            "published_sha256": hashlib.sha256(self.data).hexdigest(),
            "body_sha256": hashlib.sha256(self.body).hexdigest(),
        }

    def test_bound_historical_check_matches_published_source(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "Fixture.lean"
            path.write_bytes(self.data)
            bindings = {"Fixture.lean": self.entry}
            self.assertTrue(matches_record(path, "a" * 64, root, bindings))
            self.assertFalse(matches_record(path, "b" * 64, root, bindings))

    def test_changed_proof_rejected_even_with_new_file_digest(self):
        modified = self.data.replace(b"rfl", b"by sorry")
        self.entry["published_sha256"] = hashlib.sha256(modified).hexdigest()
        with self.assertRaisesRegex(ValueError, "body differs"):
            validate_source(modified, self.entry)

    def test_unrecorded_header_change_rejected(self):
        modified = self.data.replace(b"LIFT contributors", b"Other contributors")
        self.entry["published_sha256"] = hashlib.sha256(modified).hexdigest()
        with self.assertRaisesRegex(ValueError, "attribution header"):
            validate_source(modified, self.entry)

    def test_unlisted_source_requires_exact_digest(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "Fixture.lean"
            path.write_bytes(self.data)
            self.assertFalse(matches_record(path, "a" * 64, root, {}))


if __name__ == "__main__":
    unittest.main()
