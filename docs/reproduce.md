# Reproduction guide

## 1. Check the released evidence package

From the repository root, with Python 3.10+:

```bash
python3 scripts/verify_release.py
python3 -m unittest discover -s tests -v
```

The first command verifies the paper totals, obligation and task-link cardinalities, all provenance-listed source hashes, demo freshness, and Markdown links. The tests check migration isolation, explicit dependency pins, empty/duplicate exports, and drift reporting. Neither command calls a model or backend.

## 2. Browse and regenerate the demo

Open `demo/index.html` directly in a browser. To regenerate it after changing released tables:

```bash
python3 scripts/build_demo.py
```

The generated page embeds only the released tables. Search, area selection, case selection, and the timeline work offline. The page is an evidence browser, not a live Lean prover or a deployed service.

## 3. Compile the ReasLib cases

For a fresh dependency setup:

```bash
cd examples/reaslib
lake update
lake exe cache get
lake build
lake env lean Audit.lean
```

The project pins Lean 4.32.0 and the recorded Mathlib commit. This route requires Internet access for the initial dependencies. The audit checks nine named declarations and should report only the permitted standard axioms.

If the pinned dependencies already exist locally, the repository also provides a sequential cache-based verifier. From the repository root:

```bash
python3 scripts/check_lean.py \
  --lean /path/to/lean-4.32.0/bin/lean \
  --packages /path/to/existing/.lake/packages \
  --output _runs/lean-check-fresh
```

Replace the two paths with the installed compiler and Lake packages directory. The script checks the Mathlib Git revision, compiles the five source files into a new output directory, and runs `Audit.lean`. It does not alter those five source files or download dependencies. Existing output directories are refused.

The release was rechecked through this matching-cache route. The public Lake configuration was parsed and its declared library targets inspected; a new full dependency download was not repeated. This distinction is recorded in [validation](validation.md).

## 4. Exercise compiler extraction and alignment

Follow [Lean-to-JSON](../tools/lean_json/README.md) for the dependency-free fixture and [toolchain alignment](../tools/toolchain/README.md) for the target-version copy. The fixture has three declarations and exercises a definition body, a public equation, and a caller.

Outputs belong in `_runs/`, which Git ignores. Each extraction pins its compiler, hashes its mathematical input, and writes a new JSON file. Baseline and target snapshots must use the same module/name selection for a meaningful comparison. Additional client checks remain necessary for real migrations.

## 5. Reproduce what, exactly?

- Table checks reproduce aggregation from the released curated CSVs. The complete backend archive is not distributed.
- Lean checks reproduce the five-file/nine-declaration case study from the released source bytes.
- The online trace is inspectable historical evidence; this package does not replay the remote multi-agent run.
- Tool smoke checks demonstrate packaging and support-tool behavior. They are not additional LIFT paper experiments.
- A model-generated mathematical description requires its own semantic review. This release's JSON command does not perform that generation.
