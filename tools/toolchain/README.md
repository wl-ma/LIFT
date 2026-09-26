# Toolchain alignment helper

This newly packaged helper supports version-migration preparation and inspection. It does not claim to be an existing fully automatic repair system or a new paper experiment.

## Prepare, build, compare

From the repository root, first export a baseline:

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

Choose new output paths if those already exist. The original source remains unchanged. The preparation report records original hashes, the target version, and whether the original Lake lock existed. It starts with `prepared_not_built` and `interface_preservation=not_checked`.

For a Mathlib project, pass `--mathlib-rev` with the **full target Mathlib commit SHA**. Its Lean toolchain must match the target compiler. No revision is guessed, and no arbitrary latest dependency is substituted.

## Supported surface

- Stable Lean pins of the form `leanprover/lean4:vX.Y.Z`.
- `lakefile.toml` projects; explicit Git Mathlib dependencies with one `rev` field.
- New output directories outside the source.
- Copies of `.lean` files, `lean-toolchain`, `lakefile.toml`, `LICENSE`, and `NOTICE`.

The old `lake-manifest.json`, `.lake` products, Git state, environment files, runtime directories, and credentials are not copied. Other resources and non-Mathlib dependency adaptations require explicit handling. Projects using `lakefile.lean` are rejected for manual adaptation rather than partially rewritten. The build step runs Lake and can download declared dependencies; preparation alone does not run a build or install tools.

## How to interpret comparisons

The comparison indexes records by `Module::name`, reports missing/added declarations, and compares declaration kind, type, definition body, constructors, fields, axioms, and unsafe/partial flags. Empty exports and duplicate identities are rejected. It exits with status 1 when existing declarations are missing or changed. New declarations are reported separately.

`selected_facts_unchanged` means those selected textual fields matched. It is not a semantic-equivalence theorem, does not compare theorem proof bodies, and does not test all callers. Pretty-print changes can require review even when the mathematics is unchanged. Use the original source specifications and run original client files in the target environment before accepting a real migration.

The release checks include a dependency-free 4.26.0 → 4.30.0 migration and a 4.32.0 extraction exercise. No full mathematical-project migration benchmark is claimed.

## Immutable original-client checking

'python3 tools/toolchain/upgrade.py clients PROJECT --manifest CLIENTS_JSON --output NEW_DIRECTORY' compiles each hash-bound original client under PROJECT's actual environment, preserves failures and emits a separate report. The comparison now includes type/value dependencies, dependency modules and mutual families; textual drift requests review. See the [real Mathlib migration](../../examples/mathlib-migration/) and [validation command](../../docs/reproduce-v13.md).
