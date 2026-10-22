"""Task-scoped checkpoint indexing, cache maintenance, and public export."""

from __future__ import annotations

import argparse
import fcntl
import hashlib
import json
import os
import re
import shutil
import stat
import subprocess
import sys
import time
from pathlib import Path

DOMAINS = (
    "AnalysisOptimization",
    "Algebra",
    "Topology",
    "GraphDiscrete",
    "LinearMatrix",
    "Probability",
)
FORBIDDEN = (
    ("private-key", r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
    (
        "access-token",
        r"\b(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|AKIA[A-Z0-9]{16})\b",
    ),
    (
        "credential",
        r"(?i)(?:authorization\s*:\s*bearer\s+|(?:api[_-]?key|password|client_secret)\s*[=:]\s*[\"'])[A-Za-z0-9_./+=-]{12,}",
    ),
    ("machine-path", r"(?:/\x72oot/|/\x6dnt/data/|[A-Z]:\\Users\\)"),
    ("network-address", r"\b(?:\d{1,3}\.){3}\d{1,3}\b"),
    ("personal-email", r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"),
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(4 * 1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def atomic_json(path: Path, value: object) -> None:
    """Durably replace a report, including its directory entry."""
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + f".{os.getpid()}.tmp")
    with temporary.open("w") as handle:
        json.dump(value, handle, indent=2, sort_keys=True)
        handle.write("\n")
        handle.flush()
        os.fsync(handle.fileno())
    temporary.replace(path)
    fd = os.open(path.parent, os.O_DIRECTORY)
    try:
        os.fsync(fd)
    finally:
        os.close(fd)


def read(path: Path) -> dict:
    return json.loads(path.read_text())


def guard(config: dict) -> None:
    """Check mount identity without mounting or changing any filesystem."""
    root = Path(config["root"])
    data = Path(config["data_target"])
    uuid = subprocess.check_output(
        ["findmnt", "-n", "-o", "UUID", "--mountpoint", config["data_mount"]],
        text=True,
        timeout=10,
    ).strip()
    if uuid != config["expected_uuid"] or not os.path.ismount(root):
        raise RuntimeError("storage_identity_invalid")
    if (
        root.stat().st_dev != data.stat().st_dev
        or root.stat().st_ino != data.stat().st_ino
    ):
        raise RuntimeError("storage_binding_invalid")
    if os.statvfs(root).f_flag & os.ST_RDONLY:
        raise RuntimeError("storage_read_only")
    if not (root / config["state_relative"]).is_file():
        raise RuntimeError("experiment_state_missing")


def layout(config: dict) -> tuple[Path, Path, Path, Path]:
    root = Path(config["root"])
    q = root / config["q_relative"]
    f = root / config["f_relative"]
    ops = root / "operations"
    return root, q, f, ops


def usage_summary(ledger: Path, cutoff: float) -> dict:
    starts = {}
    ends = {}
    with ledger.open() as handle:
        for line in handle:
            row = json.loads(line)
            key = row.get("attempt_id")
            if not key:
                continue
            if row.get("phase") == "started" and row.get("started_at", 0) >= cutoff:
                starts[key] = row
            elif row.get("phase") == "finished":
                ends[key] = row
    finished = {key: ends[key] for key in starts if key in ends}
    totals = dict.fromkeys(
        (
            "input_tokens",
            "output_tokens",
            "cached_tokens",
            "reasoning_tokens",
            "total_tokens",
        ),
        0,
    )
    unknown = 0
    for row in finished.values():
        usage = row.get("usage") or {}
        total = usage.get("total_tokens")
        unknown += type(total) is not int
        normalized = {
            "input_tokens": usage.get("input_tokens", usage.get("prompt_tokens")),
            "output_tokens": usage.get("output_tokens", usage.get("completion_tokens")),
            "cached_tokens": (
                usage.get("input_tokens_details")
                or usage.get("prompt_tokens_details")
                or {}
            ).get("cached_tokens"),
            "reasoning_tokens": (
                usage.get("output_tokens_details")
                or usage.get("completion_tokens_details")
                or {}
            ).get("reasoning_tokens"),
            "total_tokens": total,
        }
        for name in totals:
            value = normalized[name]
            if type(value) is int:
                totals[name] += value
    return {
        "started": len(starts),
        "finished": len(finished),
        "inflight": len(starts.keys() - ends.keys()),
        "unknown_usage": unknown,
        "known_token_lower_bound": totals,
        "cache_and_reasoning_included_in_total": True,
    }


def checkpoint(config: dict) -> dict:
    guard(config)
    root, q, f, ops = layout(config)
    state = read(f / "continuous-r08/state.json")
    launch = read(root / config["launch_relative"])
    usage = usage_summary(q / "provider-ledger.jsonl", launch["at"])
    previous = ops / "state/checkpoint-latest.json"
    cache = (
        {row["path"]: row for row in read(previous).get("files", [])}
        if previous.exists()
        else {}
    )
    paths = {f / "continuous-r08/state.json", q / "provider-ledger.jsonl"}
    hold = q / "runtime/material-validation-hold.json"
    if hold.exists():
        paths.add(hold)
    for session in (f / "continuous-r08/source-sessions").glob("*/session.json"):
        paths.add(session)
        paths.update(
            p
            for p in session.parent.rglob("*")
            if p.is_file() and p.suffix in {".json", ".jsonl"}
        )
        project = Path(read(session)["project"])
        if not project.resolve().is_relative_to(root.resolve()):
            raise RuntimeError("session_project_outside_experiment")
        baselines = project / ".m2f_responsibility_baselines"
        if baselines.is_dir():
            paths.update(
                p
                for p in baselines.rglob("*")
                if p.is_file() and p.suffix in {".json", ".jsonl"}
            )
    records = []
    for path in sorted(paths):
        relative = str(path.relative_to(root))
        before = path.stat()
        prior = cache.get(relative, {})
        if (
            prior.get("mtime_ns") == before.st_mtime_ns
            and prior.get("size") == before.st_size
        ):
            digest = prior["sha256"]
        else:
            digest = sha256(path)
            with path.open("rb") as handle:
                os.fsync(handle.fileno())
        after = path.stat()
        if (before.st_size, before.st_mtime_ns) != (after.st_size, after.st_mtime_ns):
            raise RuntimeError("checkpoint_changed_during_read")
        records.append(
            {
                "path": relative,
                "size": after.st_size,
                "mtime_ns": after.st_mtime_ns,
                "sha256": digest,
            }
        )
    result = {
        "at": time.time(),
        "active_tasks": state.get("active_tasks", []),
        "usage": usage,
        "files": records,
        "native_checkpoints_referenced_not_recreated": True,
        "hold_present": hold.exists(),
    }
    atomic_json(previous, result)
    versions = ops / "state/checkpoint-index-history"
    atomic_json(versions / (str(time.time_ns()) + ".json"), result)
    for old in sorted(versions.glob("*.json"))[:-12]:
        old.unlink()
    return {
        "indexed_files": len(records),
        "active_tasks": len(result["active_tasks"]),
        "inflight": usage["inflight"],
    }


def recovery_check(config: dict) -> dict:
    guard(config)
    root, _, _, ops = layout(config)
    index = read(ops / "state/checkpoint-latest.json")
    if index["active_tasks"] or index["usage"]["inflight"]:
        raise RuntimeError("interrupted_work_requires_request_reconciliation")
    for row in index["files"]:
        if sha256(root / row["path"]) != row["sha256"]:
            raise RuntimeError("checkpoint_reconciliation_required")
    return {"eligible": True, "index_at": index["at"], "existing_sessions_only": True}


def strip_lean_comments(text: str) -> str:
    """Remove comments while retaining newlines and quoted Lean strings."""
    out = []
    index = 0
    depth = 0
    quoted = False
    while index < len(text):
        pair = text[index : index + 2]
        char = text[index]
        if depth:
            if pair == "/-":
                depth += 1
                index += 2
            elif pair == "-/":
                depth -= 1
                index += 2
                out.append(" ")
            else:
                out.append("\n" if char == "\n" else " ")
                index += 1
        elif quoted:
            out.append(char)
            index += 1
            if char == "\\" and index < len(text):
                out.append(text[index])
                index += 1
            elif char == '"':
                quoted = False
        elif pair == "/-":
            depth = 1
            out.append(" ")
            index += 2
        elif pair == "--":
            end = text.find("\n", index)
            index = len(text) if end == -1 else end
            out.append(" ")
        else:
            out.append(char)
            quoted = char == '"'
            index += 1
    if depth or quoted:
        raise ValueError("unterminated_lean_comment_or_string")
    return "\n".join(line.rstrip() for line in "".join(out).splitlines()) + "\n"


def sensitive_findings(text: str) -> list[str]:
    return [name for name, pattern in FORBIDDEN if re.search(pattern, text)]


def scan_public(directory: Path, scanner: str, report: Path) -> None:
    findings = []
    files = [p for p in directory.rglob("*") if p.is_file()]
    for path in files:
        if path.is_symlink() or path.suffix not in {".py", ".md", ".json", ".jsonl"}:
            findings.append(
                {
                    "file": str(path.relative_to(directory)),
                    "rules": ["unapproved_file_type"],
                }
            )
            continue
        if path.stat().st_size > 8 * 1024 * 1024:
            raise RuntimeError("public_file_too_large")
        rules = sensitive_findings(path.read_text())
        if rules:
            findings.append({"file": str(path.relative_to(directory)), "rules": rules})
    atomic_json(report, {"passed": not findings, "findings": findings})
    if findings:
        raise RuntimeError("public_sensitive_information_detected")
    gitleaks_report = report.with_name("gitleaks-redacted.json")
    with report.with_name("gitleaks.stdout").open("w") as out:
        result = subprocess.run(
            [
                scanner,
                "dir",
                "--no-banner",
                "--redact=100",
                "--report-format=json",
                "--report-path=" + str(gitleaks_report),
                str(directory),
            ],
            stdout=out,
            stderr=subprocess.STDOUT,
            timeout=180,
            check=False,
        )
    if result.returncode:
        raise RuntimeError("gitleaks_public_export_rejected")
    atomic_json(
        report,
        {
            "passed": True,
            "files": len(files),
            "gitleaks_passed": True,
            "at": time.time(),
        },
    )


def native_success_tasks(state: dict) -> set[str]:
    """Count completed proof receipts, including an unfinished current batch."""
    successful = set()
    tasks = set(state["tasks"]) | set(state.get("active_tasks", []))
    for task in tasks:
        task_state = state["tasks"].get(task, {})
        runs = {task_state.get("last_run"), state.get("active_run")}
        for run in filter(None, runs):
            result = Path(run) / "items" / task / "proof-result.json"
            if result.is_file() and read(result).get("status") == "success":
                successful.add(task)
    return successful


def export_public(config: dict) -> dict:
    guard(config)
    root, q, f, ops = layout(config)
    stage = ops / "public-stage"
    if stage.exists():
        shutil.rmtree(stage)
    code_target = stage / "tools/experiment_ops"
    code_target.mkdir(parents=True)
    for name in (
        "lift_ops.py",
        "test_lift_ops.py",
        "README.md",
        "materialize_sources.py",
    ):
        shutil.copy2(ops / "code" / name, code_target / name)
    published = stage / "experiments/six-domain-preparation"
    published.mkdir(parents=True)
    domains = {
        domain: {
            "complete": 0,
            "accepted": 0,
            "rejected": 0,
            "pending": 0,
            "denominator": 80,
        }
        for domain in DOMAINS
    }
    records = []
    blobs = {}
    for admission in sorted((f / "independent-admissions").glob("*.json")):
        data = read(admission)
        task = data["source_key"]
        domain = next(d for d in DOMAINS if d in task)
        domains[domain]["complete"] += 1
        domains[domain]["accepted" if data["accepted"] else "rejected"] += 1
        record = {
            "task": task,
            "domain": domain,
            "accepted": data["accepted"],
            "source_files": [],
        }
        if data["accepted"]:
            project = Path(data["project"])
            if not project.resolve().is_relative_to(root.resolve()):
                raise RuntimeError("public_source_outside_experiment")
            for item in data["source_files"]:
                relative = Path(item["path"])
                if (
                    relative.is_absolute()
                    or ".." in relative.parts
                    or relative.suffix != ".lean"
                ):
                    raise RuntimeError("public_source_path_rejected")
                source = project / relative
                if sha256(source) != item["sha256"]:
                    raise RuntimeError("accepted_source_digest_changed")
                content = strip_lean_comments(source.read_text())
                digest = hashlib.sha256(content.encode()).hexdigest()
                blobs[digest] = content
                record["source_files"].append(
                    {
                        "path": str(relative),
                        "original_sha256": item["sha256"],
                        "public_sha256": digest,
                    }
                )
        records.append(record)
    usage = usage_summary(
        q / "provider-ledger.jsonl", read(root / config["launch_relative"])["at"]
    )
    summary = {
        "phase": "native_statement_proof_material_preparation",
        "formal_generic_lift_comparison_started": False,
        "denominator": 480,
        "held_out": 60,
        "debug": 48,
        "domains": domains,
        "complete": sum(d["complete"] for d in domains.values()),
        "accepted": sum(d["accepted"] for d in domains.values()),
        "rejected": sum(d["rejected"] for d in domains.values()),
        "pending": 0,
        "usage": usage,
        "usage_is_lower_bound": True,
        "provider_dispatch_waiting": (
            q / "runtime/material-validation-hold.json"
        ).exists(),
    }
    state = read(f / "continuous-r08/state.json")
    admission_tasks = {row["task"] for row in records}
    for task in sorted(native_success_tasks(state) - admission_tasks):
        domain = next(d for d in DOMAINS if d in task)
        domains[domain]["complete"] += 1
        domains[domain]["pending"] += 1
        summary["complete"] += 1
        summary["pending"] += 1
    atomic_json(published / "summary.json", summary)
    atomic_json(published / "admissions.json", records)
    with (published / "lean-sources.jsonl").open("w") as handle:
        for digest, content in sorted(blobs.items()):
            handle.write(json.dumps({"sha256": digest, "content": content}) + "\n")
    (published / "README.md").write_text(
        "# Six-domain material preparation\n\n"
        "These are native statement-to-proof material preparation results, not a completed Generic/LIFT comparison. "
        "Each domain has 80 registered items; 60 held-out and 48 debugging items are separate. "
        "Native completion and independent mathematical acceptance are distinct. "
        "Historical failures and unknown token usage remain in accounting.\n\n"
        "Only independently accepted generated Lean files are included. Comments are removed to exclude private source excerpts; "
        "original and public hashes are both recorded. Original experiment files are unchanged. "
        "This export excludes original book text, private inputs, machine configuration, credentials, model conversations, "
        "provider responses, and private native recovery sessions. It is not a full disaster-recovery backup.\n\n"
        "Use `tools/experiment_ops/materialize_sources.py` to reconstruct the per-item Lean files from the public dataset.\n"
    )
    package_files = {
        str(path.relative_to(stage)): sha256(path)
        for path in sorted(stage.rglob("*"))
        if path.is_file()
    }
    atomic_json(
        published / "publication-manifest.json",
        {
            "schema": "lift.six-domain-publication.v1",
            "files": package_files,
            "private_recovery_material_included": False,
        },
    )
    report = ops / "state/public-scan.json"
    scan_public(stage, config["scanner"], report)
    files = [
        {
            "path": str(path.relative_to(stage)),
            "sha256": sha256(path),
            "bytes": path.stat().st_size,
        }
        for path in sorted(stage.rglob("*"))
        if path.is_file()
    ]
    digest = hashlib.sha256(json.dumps(files, sort_keys=True).encode()).hexdigest()
    acknowledgement = ops / "state/remote-publication.json"
    remote_synced = (
        acknowledgement.exists()
        and read(acknowledgement).get("content_digest") == digest
    )
    result = {
        "prepared_at": time.time(),
        "content_digest": digest,
        "files": files,
        "sensitive_scan_passed": True,
        "remote_synced": remote_synced,
    }
    atomic_json(ops / "state/public-export.json", result)
    return {
        "prepared_files": len(files),
        "content_digest": digest,
        "remote_synced": remote_synced,
    }


def process_references(paths: list[Path]) -> bool:
    prefixes = [str(path.resolve()) for path in paths]
    for process in Path("/proc").iterdir():
        if not process.name.isdecimal() or int(process.name) == os.getpid():
            continue
        try:
            entries = [process / "cwd", *(process / "fd").iterdir()]
            arguments = (process / "cmdline").read_bytes().decode(errors="replace")
        except OSError:
            continue
        if any(prefix in arguments for prefix in prefixes):
            return True
        for entry in entries:
            try:
                value = os.readlink(entry)
                resolved = (
                    str(Path(value).resolve()) if value.startswith("/") else value
                )
            except OSError:
                continue
            if any(
                resolved == prefix or resolved.startswith(prefix + "/")
                for prefix in prefixes
            ):
                return True
    return False


def publication_bundle(config: dict) -> dict:
    """Pin a scanned allowlist for a separately authorized connected publisher."""
    guard(config)
    _, _, _, ops = layout(config)
    stage = ops / "public-stage"
    manifest = read(ops / "state/public-export.json")
    scan_public(stage, config["scanner"], ops / "state/public-scan.json")
    files = []
    for record in manifest["files"]:
        relative = Path(record["path"])
        if relative.is_absolute() or ".." in relative.parts:
            raise RuntimeError("publication_path_invalid")
        if not record["path"].startswith(
            ("tools/experiment_ops/", "experiments/six-domain-preparation/")
        ):
            raise RuntimeError("publication_scope_invalid")
        path = stage / relative
        if path.is_symlink() or sha256(path) != record["sha256"]:
            raise RuntimeError("publication_content_changed")
        files.append(
            {
                "path": record["path"],
                "sha256": record["sha256"],
                "content": path.read_text(),
            }
        )
    bundle = {
        "repository": config["public_repository"],
        "branch": "main",
        "content_digest": manifest["content_digest"],
        "sensitive_scan_passed": True,
        "files": files,
    }
    path = ops / "state/publication-bundle.json"
    atomic_json(path, bundle)
    return {
        "bundle_path": str(path),
        "content_digest": manifest["content_digest"],
        "files": len(files),
    }


def cache_files(config: dict, now: float) -> list[Path]:
    """Only recognize explicitly registered historical regenerable caches."""
    root = Path(config["root"]).resolve()
    candidates = []
    for relative in config["cache_roots"]:
        path = root / relative
        if not path.exists():
            continue
        if path.is_symlink() or not path.resolve().is_relative_to(root):
            raise RuntimeError("cache_symlink_escape")
        if "/.lake/build" not in str(path) and not str(path).endswith("/.elan/tmp"):
            raise RuntimeError("cache_root_not_regenerable")
        if process_references([path]):
            continue
        entries = [p for p in path.rglob("*") if p.is_file() and not p.is_symlink()]
        age_days = (
            config["cache_download_min_age_days"]
            if str(path).endswith("/.elan/tmp")
            else config["cache_min_age_days"]
        )
        if any(now - p.stat().st_mtime < age_days * 86400 for p in entries):
            continue
        for entry in entries:
            info = entry.lstat()
            if stat.S_ISREG(info.st_mode) and info.st_nlink == 1:
                candidates.append(entry)
    return sorted(candidates)


def cleanup(config: dict, apply: bool) -> dict:
    guard(config)
    root, _, _, ops = layout(config)
    started = time.monotonic()
    candidates = cache_files(config, time.time())
    removed = []
    allocated = 0
    for path in candidates:
        if (
            len(removed) >= config["cleanup_max_files"]
            or time.monotonic() - started > config["cleanup_max_seconds"]
        ):
            break
        info = path.lstat()
        if allocated + info.st_blocks * 512 > config["cleanup_max_bytes"]:
            break
        if (
            path.is_symlink()
            or info.st_nlink != 1
            or not path.resolve().is_relative_to(root.resolve())
        ):
            raise RuntimeError("cache_identity_changed")
        if apply:
            path.unlink()
        allocated += info.st_blocks * 512
        removed.append(str(path.relative_to(root)))
    result = {
        "at": time.time(),
        "applied": apply,
        "candidate_files": len(candidates),
        "processed_files": len(removed),
        "allocated_bytes": allocated,
        "paths": removed,
    }
    atomic_json(ops / "state/cache-cleanup-latest.json", result)
    history = ops / "state/cache-cleanup-history"
    atomic_json(history / (str(time.time_ns()) + ".json"), result)
    for old in sorted(history.glob("*.json"))[:-12]:
        old.unlink()
    return {key: value for key, value in result.items() if key != "paths"}


def recover(config: dict) -> dict:
    result = recovery_check(config)
    for unit in reversed(config["services"]):
        subprocess.run(["systemctl", "start", unit], check=True, timeout=60)
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "command",
        choices=[
            "guard",
            "checkpoint",
            "recover",
            "recovery-check",
            "export",
            "bundle",
            "cleanup",
            "watchdog",
        ],
    )
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    config = read(args.config)
    status = Path(config["system_status"])
    if args.command == "guard":
        try:
            guard(config)
            return 0
        except (
            OSError,
            ValueError,
            RuntimeError,
            KeyError,
            subprocess.SubprocessError,
        ):
            return 1
    lock = Path(config["lock_file"])
    if args.command == "watchdog":
        lock = lock.with_name(lock.name + ".watchdog")
    lock.parent.mkdir(parents=True, exist_ok=True)
    with lock.open("a") as handle:
        try:
            fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return 0
        try:
            if args.command in {"guard", "watchdog"}:
                guard(config)
                result = {"storage_healthy": True}
            elif args.command == "checkpoint":
                result = checkpoint(config)
            elif args.command == "recover":
                result = recover(config)
            elif args.command == "recovery-check":
                result = recovery_check(config)
            elif args.command == "export":
                result = export_public(config)
            elif args.command == "bundle":
                result = publication_bundle(config)
            else:
                result = cleanup(config, args.apply)
            atomic_json(
                status,
                {
                    "at": time.time(),
                    "command": args.command,
                    "ok": True,
                    "result": result,
                },
            )
            print(json.dumps(result))
            return 0
        except (
            OSError,
            ValueError,
            RuntimeError,
            KeyError,
            subprocess.SubprocessError,
        ) as error:
            # Store only a category; never echo raw provider errors or credentials.
            category = (
                str(error) if isinstance(error, RuntimeError) else type(error).__name__
            )
            atomic_json(
                status,
                {
                    "at": time.time(),
                    "command": args.command,
                    "ok": False,
                    "category": category,
                },
            )
            if args.command == "watchdog":
                for unit in config["services"]:
                    subprocess.run(["systemctl", "stop", unit], check=False, timeout=60)
            print(json.dumps({"ok": False, "category": category}))
            return 1


if __name__ == "__main__":
    sys.exit(main())
