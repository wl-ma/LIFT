# Checked toolchain migration

The tool prepares an isolated project for an exact Lean/Mathlib target, repairs diagnosed identifier or import changes, then checks the original declaration interfaces and clients. Rule-based repair needs no model. An optional JSON model command proposes diagnostic-bound substitutions; neither mode imports a construction backend.

## Automatic repair

The supplied example exercises an actual Mathlib change: `Mathlib.Analysis.NormedSpace.Extr` exists in the 4.30 environment and is removed in the 4.32 environment. Its norm interface needs `Mathlib.Analysis.Normed.Group.Basic`, which the version-bound rule supplies.

Prepare the original project's dependencies:

```bash
cd examples/toolchain-repair
lake update
lake exe cache get
lake build
cd ../..
```

Then run:

```bash
python3 tools/toolchain/repair.py examples/toolchain-repair \
  --output _runs/norm-repair \
  --target leanprover/lean4:v4.32.0 \
  --mathlib-rev 81a5d257c8e410db227a6665ed08f64fea08e997 \
  --module NormProof --clients examples/toolchain-repair/clients.json \
  --rules examples/toolchain-repair/rules.json --max-rounds 3
```

The target build resolves its pinned dependencies and may download them. For an existing target cache, supply both `--packages` and `--dependency-lock`; the tool verifies the Mathlib commit, lock revision and toolchain before use.

The loop first builds the unchanged target candidate. It applies a rule only if the old identifier appears in the failed build's diagnostics. Whole Lean identifiers are replaced in the selected modules; strings, quoted identifiers and nested comments remain untouched. Every attempt records the failing build, source hashes, triggered rules and original file bytes. No matching repair or exhausted rounds yields `unrepaired`.

A successful build triggers complete compiler inventory extraction for the selected modules. Existing declaration identities, kinds, full types, definition values, constructors, fields and mutual families must remain unchanged. Nonstandard axioms, unsafe/partial content and changed interfaces prevent acceptance. Proof dependency changes are explicitly reported. Original hash-bound clients compile both before and after migration. `accepted` requires all gates and an unchanged original project.

The rules are explicit, auditable input, not a general theorem prover. They repair renamed identifiers and moved imports; arbitrary changed theorem signatures, tactic failures or mathematical rewrites remain for review. Selected module inventories and client scope are recorded in the result; whole-library semantic equivalence is not inferred from textual equality.

## Model-proposed repairs

Omit `--rules` and provide the same independent model interface used by translation:

```bash
python3 tools/toolchain/repair.py examples/toolchain-repair \
  --output _runs/model-norm-repair \
  --target leanprover/lean4:v4.32.0 \
  --mathlib-rev 81a5d257c8e410db227a6665ed08f64fea08e997 \
  --module NormProof --clients examples/toolchain-repair/clients.json \
  --model-command '["python3", "tools/lean_json/model.py"]' --max-rounds 3
```

After an actual failed build, the model receives the complete selected source files,
exact version pins and diagnostics. It returns whole identifier/import replacements
with reasons. The old name must occur in those diagnostics; arbitrary code patches,
configuration edits and new proof assumptions are outside this interface. The tool
applies the proposal, rebuilds, and requires the same full original declaration and
client checks as rule-based repair. A model reply cannot approve its own repair.
All calls, proposals, build failures and provider-reported usage are retained. If no
safe substitution exists, the model can return an empty replacement list and the
run remains `unrepaired`. If both rules and a model command are supplied, matching
rules take precedence; the model is consulted only when no rule matches.

## Prepare and inspect separately

```bash
python3 tools/lean_json/extract.py examples/lean-json \
  --module Fixture --output _runs/before.json
python3 tools/toolchain/upgrade.py prepare examples/lean-json _runs/upgrade-demo \
  --target leanprover/lean4:v4.30.0
python3 tools/toolchain/upgrade.py build _runs/upgrade-demo
python3 tools/lean_json/extract.py _runs/upgrade-demo \
  --module Fixture --output _runs/after.json
python3 tools/toolchain/upgrade.py compare _runs/before.json _runs/after.json
```

Original-client checks are also available through `upgrade.py clients PROJECT --manifest CLIENTS_JSON --output NEW_DIRECTORY`.

## Project contract

Python 3.10+, Elan/Lake, supported compiler extraction versions (4.26, 4.30, 4.32) and `lakefile.toml` are required. Mathlib dependencies use a full Git revision. Output is a new directory outside the source. The copied surface contains Lean files, the TOML project configuration, toolchain and licensing files. Old locks, caches, Git state, environment files and execution directories are excluded. Projects using `lakefile.lean` or extra resources require explicit adaptation.

Each result directory retains `before.json`, `after.json` when compiled, `preservation.json`, original and target client reports, all attempt records and `report.json`. Compilation timeouts stop automatic repair. [Validation records](../../experiments/tool-validation/README.md).
