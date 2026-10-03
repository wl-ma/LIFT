# Experiments and data dictionary

Experiments are grouped by the question they answer. Each directory contains `data/` inputs and `results/` outputs where applicable. Reproduction uses shared code in `src/lift_artifacts/` through the root command-line scripts.

| Directory | Question | Evidence |
| --- | --- | --- |
| [corpus-construction](corpus-construction/README.md) | What is constructed across mathematical domains? | Selection, stage counts, individual actions, module records, and aggregate tables |
| [source-recovery](source-recovery/README.md) | How do public interfaces recover their sources? | Obligation/task links and selected compiled applications |
| [downstream-reuse](downstream-reuse/README.md) | Does an interface serve a later research proof? | Normal-cone source, general interface, representation, and actual caller |
| [online-revision](online-revision/README.md) | Can a revision use an intervening accepted interface? | Ordered events, source patch, before/checkpoint snapshots, and fixed clients |
| [tool-validation](tool-validation/README.md) | Do the supporting extraction and migration tools work on the supplied examples? | Compiler fixtures and original-client checks |
| [serial-library-growth](serial-library-growth/README.md) | Can three textbook developments grow one library while preserving their interfaces? | Three accepted releases, complete declaration inventories, source recoveries, independent clients, and execution accounting |

[Paper mapping](../docs/experiments.md) · [Machine-readable experiment registry](../metadata/experiments.json) · [Reproduction](../docs/reproducibility.md)

## Construction fields

- `project`: a stable public slug; it is not an internal service repository ID.
- `title`, `domain`: the manuscript's presentation label and mathematical area. A broad label does not resolve unknown original bibliography.
- `catalogue_items`: entries in the recorded project catalogue. This includes entries outside the successful-integration set.
- `integrated_items`: successful source-item integration outcomes in the retained overview.
- `public_module_occurrences`: Lean files in the public component directory of each export; includes inherited content, repeated files, import-only files, and interfaces awaiting proofs. Summing gives occurrences across projects, not globally unique modules.
- `modules_with_sorry_text`: files containing unfinished-proof text under the original textual scan. This is a file-level diagnostic, not a kernel dependency audit.
- `integration_manifests`: retained manifest files. This can differ from historical stage totals when later exports have changed.
- `toolchain`: the original project's recorded Lean toolchain. It is not a claim that the complete project was rebuilt for this release.

## Declaration actions

`reuse_existing` selects an available declaration. `promote` publishes a declaration. `keep_source` retains source-specific content, and `keep_item_local` retains item-local support. `remove` records a removal decision. The paper combines the two retention categories. Counts include repeated decisions and are not unique declaration counts.

The original action-level file is aggregated here by selected project and action. The released table independently reproduces 8,854 reuse, 19,253 publication, 2,568 retention, and 3,283 removal occurrences. The corresponding released action rows are in `corpus-construction/data/actions.csv`.

## Proof handoffs

`statement_success`, `integration_success`, and `proof_work_success` count successful work items/tasks in the selected batches. `pending_units_after_integration` counts individual obligations registered at the integration stage. A proof task may group several obligations or include work outside a one-to-one pairing.

`exact_id_success_links` uses original obligation identifiers. `declaration_owner_success_links` uses the declaration and owner-module pair. The original IDs are replaced by public release-local obligation labels in the detailed table. The selected data contains 246 exact-ID links and 3 declaration/owner links; all 249 point to successful task records. `unresolved_links` is zero in these selected batches.

`integration_time_status=pending` describes when an obligation was handed to proof work, while `proof_stage_success=True` describes its later linked record. `current_owner_exists` concerns file availability in the retained export. Neither field substitutes for current kernel checking; `evidence_level` preserves this qualification explicitly.

`proof-task-links.csv` retains the successful-task grouping behind each released obligation. Its `proof_task` values are release-local aliases, scoped to the original project and proof batch. Multiple rows for one obligation mean multiple linked successful task records. The distinct aliases in this file need not equal the 135 total successful tasks: that total also includes tasks outside the selected obligation links.

There are 258 obligation–task links covering all 249 obligations and 72 distinct linked task aliases. These are separate cardinalities: nine extra links arise because some obligations link to more than one successful record. The first three Taylor obligations all link to `proof-task-0001`.

## Lean checks

The selected source files retain their original SHA-256 hashes. The original check used Lean 4.32.0 and Mathlib commit `81a5d257c8e410db227a6665ed08f64fea08e997`. Its axiom outputs contain only `propext`, `Classical.choice`, and `Quot.sound` for the nine named declarations.

The fresh release check is separate. It recompiles the same files and re-runs the nine checks in the same pinned environment. See [reproduction](../docs/reproducibility.md) for commands. These are declaration-level and source-application checks, not a revalidation of all 249 handoffs or all 20 developments.

## Online checkpoint

The trace records a source-local update under Lean 4.30.0. `context` and `accepted_version` are recorded library-state hashes, not GitHub links. The checkpoint derives from the completed Beck stage, before later work in the broader run. It retains `formal_result=false` and `working_state_checked`: original source checks passed, while whole-library release validation was a separate condition.

The broader first run later failed its final public-manifest check; the second run accepted no mathematical updates. The released successful checkpoint should therefore be used to inspect the particular reuse mechanism, not to compute a general improvement rate or compare complete modes.

## Verification and transformations

From the repository root:

```bash
python3 scripts/verify_release.py
```

The verifier checks totals, batch/obligation cardinalities, successful links, released source hashes, and local Markdown links. It does not contact a backend or rerun proof generation. Public project labels and the exclusion of service identifiers/logs make these tables portable; original input hashes preserve the relation to the retained local evidence. Full raw exports are not part of this release.
