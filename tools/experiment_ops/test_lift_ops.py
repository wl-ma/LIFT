"""Offline safety regressions; no model calls or real service changes."""

import json
import os
import tempfile
import time
import unittest
from pathlib import Path
from unittest.mock import patch

import lift_ops


class SafetyTests(unittest.TestCase):
    def test_atomic_json(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "index.json"
            lift_ops.atomic_json(path, {"complete": True})
            self.assertEqual(json.loads(path.read_text()), {"complete": True})
            self.assertEqual(list(Path(folder).glob("*.tmp")), [])

    def test_guard_rejects_wrong_disk_before_state_access(self):
        config = {
            "root": "/unused",
            "data_target": "/unused-data",
            "data_mount": "/unused-mount",
            "expected_uuid": "expected",
        }
        with (
            patch("subprocess.check_output", return_value="wrong\n"),
            self.assertRaisesRegex(RuntimeError, "storage_identity"),
        ):
            lift_ops.guard(config)

    def test_strip_nested_comments_and_preserve_strings(self):
        source = '/- outer /- inner -/ end -/\ndef value := "-- text /- text" -- tail\n'
        result = lift_ops.strip_lean_comments(source)
        self.assertIn('def value := "-- text /- text"', result)
        self.assertNotIn("outer", result)
        self.assertNotIn("tail", result)

    def test_unterminated_comment_rejected(self):
        with self.assertRaises(ValueError):
            lift_ops.strip_lean_comments("/- unfinished")

    def test_token_rejected(self):
        value = "gh" + "p_" + "A" * 36
        self.assertIn("access-token", lift_ops.sensitive_findings(value))

    def test_machine_path_rejected(self):
        value = "/" + "root" + "/private/file"
        self.assertIn("machine-path", lift_ops.sensitive_findings(value))

    def test_summary_safe(self):
        self.assertEqual(
            lift_ops.sensitive_findings(
                '{"accepted": 102, "sha256": "' + "a" * 64 + '"}'
            ),
            [],
        )

    def test_usage_dedup_unknown_and_cached_not_added(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "ledger.jsonl"
            rows = [
                {"phase": "started", "attempt_id": "one", "started_at": 2},
                {
                    "phase": "finished",
                    "attempt_id": "one",
                    "usage": {
                        "prompt_tokens": 10,
                        "completion_tokens": 2,
                        "total_tokens": 12,
                        "prompt_tokens_details": {"cached_tokens": 8},
                    },
                },
                {
                    "phase": "finished",
                    "attempt_id": "one",
                    "usage": {
                        "prompt_tokens": 10,
                        "completion_tokens": 2,
                        "total_tokens": 12,
                        "prompt_tokens_details": {"cached_tokens": 8},
                    },
                },
                {"phase": "started", "attempt_id": "two", "started_at": 2},
                {"phase": "finished", "attempt_id": "two", "usage": None},
                {"phase": "started", "attempt_id": "three", "started_at": 2},
            ]
            path.write_text("\n".join(json.dumps(row) for row in rows))
            result = lift_ops.usage_summary(path, 1)
            self.assertEqual(result["finished"], 2)
            self.assertEqual(result["unknown_usage"], 1)
            self.assertEqual(result["inflight"], 1)
            self.assertEqual(result["known_token_lower_bound"]["total_tokens"], 12)
            self.assertEqual(result["known_token_lower_bound"]["cached_tokens"], 8)

    def make_cache(self, base):
        root = Path(base) / "experiment"
        cache = root / "legacy/.lake/build"
        cache.mkdir(parents=True)
        config = {
            "root": str(root),
            "cache_roots": ["legacy/.lake/build"],
            "cache_min_age_days": 14,
            "cache_download_min_age_days": 7,
        }
        return root, cache, config

    def test_cache_rejects_external_symlink_root(self):
        with tempfile.TemporaryDirectory() as folder:
            _root, cache, config = self.make_cache(folder)
            cache.rmdir()
            cache.symlink_to(folder, target_is_directory=True)
            with self.assertRaisesRegex(RuntimeError, "symlink"):
                lift_ops.cache_files(config, time.time())

    def test_cache_retains_hardlinks_and_recent_files(self):
        with tempfile.TemporaryDirectory() as folder:
            root, cache, config = self.make_cache(folder)
            file = cache / "one.olean"
            file.write_text("compiled")
            self.assertEqual(lift_ops.cache_files(config, time.time()), [])
            old = time.time() - 20 * 86400
            os.utime(file, (old, old))
            os.link(file, root / "retained.olean")
            self.assertEqual(lift_ops.cache_files(config, time.time()), [])

    def test_cache_skips_in_use_root(self):
        with tempfile.TemporaryDirectory() as folder:
            _, cache, config = self.make_cache(folder)
            file = cache / "one.olean"
            file.write_text("compiled")
            old = time.time() - 20 * 86400
            os.utime(file, (old, old))
            with patch("lift_ops.process_references", return_value=True):
                self.assertEqual(lift_ops.cache_files(config, time.time()), [])

    def test_cache_only_accepts_registered_regenerable_root(self):
        with tempfile.TemporaryDirectory() as folder:
            root, _, config = self.make_cache(folder)
            (root / "checkpoints").mkdir()
            config["cache_roots"] = ["checkpoints"]
            with self.assertRaisesRegex(RuntimeError, "not_regenerable"):
                lift_ops.cache_files(config, time.time())

    def test_recovery_refuses_uncertain_inflight_request(self):
        with tempfile.TemporaryDirectory() as folder:
            ops = Path(folder)
            (ops / "state").mkdir()
            lift_ops.atomic_json(
                ops / "state/checkpoint-latest.json",
                {"at": 1, "active_tasks": [], "usage": {"inflight": 1}, "files": []},
            )
            with (
                patch("lift_ops.guard"),
                patch("lift_ops.layout", return_value=(ops, ops, ops, ops)),
                self.assertRaisesRegex(RuntimeError, "reconciliation"),
            ):
                lift_ops.recovery_check({})


if __name__ == "__main__":
    unittest.main()
