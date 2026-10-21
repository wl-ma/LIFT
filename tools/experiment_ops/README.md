# Experiment operations

This task-scoped sidecar indexes existing native checkpoints, checks storage identity,
maintains an explicit cache allowlist, and exports portable public evidence.
It does not implement mathematical stages, recreate responsibility baselines, or call a model.

## Recovery

Native statement and proof stages keep their existing immediate checkpoints. A five-minute
timer and task-state/admission events additionally save a durable recovery index.
The index references original sessions, baselines, handoffs, and native histories; it is not
a full backup of the experiment. Twelve index generations are retained on the experiment disk.
Files are flushed before the index is committed, and the index directory is synchronized.

The startup preflight verifies the expected disk UUID, original-path binding, read/write
filesystem status, checkpoint hashes, and unfinished request accounting. It only starts
the existing controller/provider when safe. Interrupted work or uncertain HTTP requests
remain pending reconciliation; they are not silently replayed as new sessions.

A task-specific watchdog stops only the configured experiment services on a storage fault.
No disk mount configuration, unrelated service, global cache, or host restart is changed.
The watchdog checks once per minute; it does not provide instantaneous hardware-failure
detection. Existing server mount policy remains an administrator concern.

## Public synchronization

The public export is an allowlist, not a copy of the runtime directory. It contains:

- These operational scripts, tests, and instructions.
- Six-domain aggregate counts and lower-bound token accounting.
- Admission identifiers and independently accepted generated Lean files.

Original book text, private inputs, model messages, provider responses, authentication,
machine paths, and private recovery sessions are excluded. Lean comments are removed
from the exported copy; both original and public hashes are recorded. Local sources
and their checkpoint identities remain unchanged.

Every export passes custom privacy checks and Gitleaks. A publication manifest pins
the exact file hashes. A publisher must recheck the manifest and scan result immediately
before creating a commit, then record the remote commit separately from local preparation.
No successful remote backup is claimed when export or push fails.

The server prepares exports every thirty minutes and after admission changes. An authorized
connected publisher can submit them to this repository. If the publisher is offline or lacks
write access, the bundle remains pending; the server does not acquire broader credentials.

## Cache maintenance

Only explicitly registered historical build caches and old isolated download temporaries
are eligible. Build caches require fourteen days without modification; download temporaries
require seven. Active references, symlink escapes, and hardlinks are retained. Each run has
file, byte, and time limits and preserves an audit list. Source files, checkpoints, baselines,
ledgers, provider receipts, and unreviewed runtime folders are never cleanup targets.

Cleanup audit lists retain twelve runs, and checkpoint indices retain twelve generations;
the export staging directory is replaced rather than accumulated. No full experiment backup
is placed on the system disk.

## Offline verification

```bash
python3 -m unittest discover -s tools/experiment_ops -p 'test_*.py'
```

Restore public accepted Lean sources with:

```bash
python3 tools/experiment_ops/materialize_sources.py experiments/six-domain-preparation restored-lean
```

The restored sources retain their recorded imports and toolchain requirements. Materializing
files is not itself a fresh Lean compilation or independent mathematical admission.
