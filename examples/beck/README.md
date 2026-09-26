# Replay the retained Beck source checkpoint

before/ and checkpoint/ contain unchanged mathematical files from the two
recorded library states. [Source hashes](sources.json) bind the snapshots and the
22 original [clients](clients.json). Lean 4.30.0 and Mathlib are pinned.

From checkpoint/, run 'lake update' and 'lake exe cache get'. From repository root:

~~~sh
python3 scripts/check_case.py beck --output _runs/beck-check
~~~

The checker compiles the checkpoint from source, checks the 15 named theorem
axiom sets, then recompiles every original full-type/application client. The
[retained 20 full-type hashes](../../data/online-checkpoint.json) and the
[new release check](../../data/validation/beck.json) remain distinct evidence.
The client checks establish compatibility at the original complete types.

[All ordered events](../../data/online-events.json) are a redacted projection:
original event hashes refer to original records, not to modified JSON rows.
[Selected events](../../data/online-trace.csv) and the
[actual patch](../../data/online-revision.patch) locate the accepted congruence
interface and its use in Proposition 5.13.

This is a source-local working-state checkpoint. The broader first run later
failed its final public-manifest check; the second run accepted no mathematical
update. Those outcomes are retained and are not converted into successful releases.
No model invocation, supervisor, remote server, or experiment restart is needed.
