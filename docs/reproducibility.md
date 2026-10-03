# Reproducing the artifacts

Run commands from the repository root unless a command explicitly changes directory. Output directories under `_runs/` hold new checks; the committed historical records stay in `experiments/`.

## Data and integrity

Requires Python 3.10 or later; no external Python packages are needed for these commands.

```bash
python3 scripts/verify_release.py
python3 scripts/verify_artifacts.py
python3 scripts/reproduce_tables.py --check
python3 scripts/reproduce_tables.py --output _runs/tables
python3 -m unittest discover -s tests -v
```

The six numerical tables regenerate from released selection, stage, action, module, and proof-link records. The output includes CSV tables, LaTeX rows, and a report. Integrity verification checks file hashes, numerical invariants, case identities, event order, and documentation links. [Experiment definitions](../experiments/README.md).

## Figures and browser

```bash
python3 -m pip install -r requirements-plots.txt
python3 scripts/plot_results.py --output _runs/figures
python3 scripts/build_demo.py
```

Figure outputs include SVG, PDF, and PNG plus input hashes. The action plot combines source and item-local retention and normalizes within each project. The timeline retains original event sequence numbers. The method illustration is the paper's original exported figure. Generated [action](assets/reproduced-action-profile.svg) and [timeline](assets/reproduced-online-trace.svg) examples accompany the original artwork.

Open `demo/index.html` directly in a browser. Its search, case selection, and timeline work offline.

## Lean environment

Install [Elan](https://github.com/leanprover/elan) and Git. Each case includes a `lean-toolchain`, Lake configuration, and dependency lock. Download its fixed dependencies before the first check:

```bash
(cd examples/paper-cases/reaslib && lake update && lake exe cache get)
(cd examples/paper-cases/normal-cone && lake update && lake exe cache get)
(cd examples/paper-cases/beck/checkpoint && lake update && lake exe cache get)
```

Run the checks sequentially:

```bash
python3 scripts/check_lean.py --output _runs/source-recovery
python3 scripts/check_case.py normal-cone --output _runs/downstream-reuse
python3 scripts/check_case.py beck --output _runs/online-revision
```

The first check compiles the five selected source files and audits nine declarations. Normal-cone compiles its 60 original modules, source-recovery application, and audit; five declaration identities are checked. Beck compiles the checkpoint, audits 15 theorem identities, and executes all 22 original clients. Reports preserve source hashes, compiler results, and the exact checked identities. Only `propext`, `Classical.choice`, and `Quot.sound` are allowed in the named audits.

The drivers use a single Lean worker per compile. Beck permits up to 8 GiB for its compiler process. Run only one case driver at a time. Existing output directories are refused to keep each run independent.

To reuse an installed dependency cache, add `--packages /path/to/.lake/packages`. The driver checks the Mathlib revision before use. For the first command, `--lean /path/to/lean-4.32.0/bin/lean` may also select the compiler. These paths are supplied locally and do not belong in published reports.

## Supporting tools

```bash
python3 tools/lean_json/extract.py examples/lean-json --module Fixture --output _runs/fixture.json
python3 scripts/validate_tools.py --output _runs/tool-validation
```

[Extraction options](../tools/lean_json/README.md) · [Migration options](../tools/toolchain/README.md). Tool validation exercises 36 fixture declarations on Lean 4.26.0, 4.30.0, and 4.32.0 and a Mathlib norm-interface migration from 4.30 to 4.32 with original scalar and pair clients.

## Run records

Table and figure generation emit a [common reproduction record](run-records.md), binding inputs and outputs by file hash.

## Continuous integration and maintenance

[The workflow](../.github/workflows/artifact.yml) runs data regeneration, figures, Python tests and Ruff, then separate Lean and tool checks. It downloads dependencies in a fresh checkout. The Lean case matrix runs sequentially.

```bash
ruff check src scripts tools tests
ruff format --check src scripts tools tests
```

After reviewing an intentional public-file update, maintainers run `python3 scripts/refresh_manifest.py` and both verifiers. Manifest refresh is separate from verification: a verification command never accepts changed files by updating their expected hashes.

The commands here analyze retained evidence and compile supplied Lean artifacts. They make no model calls. Historical integrations and proof searches are represented by their saved results; [validation coverage](validation.md) states the evidence for each check.


## Serial ReasLib construction demo

The [three-source project](../examples/reaslib-serial/README.md) pins Lean 4.30.0. Install its dependencies and run the complete released-package check:

```bash
cd examples/reaslib-serial
lake update
lake exe cache get
cd ../..
python3 scripts/check_serial_demo.py --output _runs/reaslib-serial
python3 scripts/build_serial_demo.py --data experiments/serial-library-growth/results/demo.json --output _runs/reaslib-serial.html
```

The check verifies all 180 library declarations, 69 fixed exact-type clients, 25 extension boundary examples, the original 21 independent checks, and the exact public source hashes. Supplementary goals have their own command and environments in the [case guide](../experiments/serial-library-growth/supplementary/README.md). Structured records retain all source-batch and recovery attempts. The build and checks make no model calls.
