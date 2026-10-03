# Validation coverage

Historical experiments, recorded package checks, and new local checks are separate evidence. A successful hash check binds a file to a record; a Lean check additionally tests the supplied declaration or client in its pinned environment.

| Check | Retained evidence | Scope |
| --- | --- | --- |
| Corpus and decisions | [Construction results](../experiments/corpus-construction/results) | Six tables regenerate from portable records, preserving the original counting units |
| Proof handoffs | [Obligations and task links](../experiments/source-recovery/results) | 249 obligations, 258 links, 72 linked task aliases; selected batches contain 135 successful proof tasks |
| Calculus and topology | [Package checks](../experiments/source-recovery/results/package-checks.json) | Five source files and nine exact declaration axiom checks |
| Normal-cone reuse | [Package checks](../experiments/downstream-reuse/results/package-checks.json) | 60-module import closure, full-type source application, five named axiom checks |
| Beck checkpoint | [Package checks](../experiments/online-revision/results/package-checks.json) | Checkpoint compilation, 15 named theorem axiom sets, all 22 original clients |
| Lean extraction and alignment | [Tool checks](../experiments/tool-validation/results/package-checks.json) | 36 fixture declarations per compiler and a pinned Mathlib migration with original clients |
| Hosted package validation | [Historical CI summary](../metadata/validation-ci.json) | Five completed jobs on the original publication package |

The Beck historical record also retains 20 full-type hashes. The package check recompiles its original clients; it does not replace that historical type-hash evidence. Original failed run outcomes remain in the online-revision records.

[Run the current checks](reproducibility.md) to produce a new output directory. The historical CI summary describes its original package, while the checked-in workflow validates the current checkout. Neither supplies a new model-experiment result.

## Layout and entry-point checks

[The layout verification record](../metadata/layout-validation.json) checks 151 unchanged mathematical/data files, six regenerated CSV tables, 12 Python regression tests, a fresh five-file/nine-declaration compilation with matching dependencies, and a real three-declaration compiler extraction. It records only the checks performed for the reorganized package.

## Source publication checks

[Publication bindings](../metadata/source-publication.json) cover 60 Lean modules and one historical source excerpt. Each entry binds the original source hash, distributed file hash and the exact mathematical body after its attribution header. The original compilation reports retain their original hashes. Verification checks both the distributed bytes and unchanged body; this publication check does not claim a new Lean compilation.

## Serial ReasLib and supplementary goals

[The current ReasLib package check](../experiments/serial-library-growth/results/package-checks.json) recompiles all 180 public-library declarations and checks their axiom sets, 69 frozen source clients, 25 boundary examples, and 21 independent demonstration checks. The six reviewed releases preserve 18 original source interfaces and 51 representation obligations. These construction and consumer checks are supplementary artifacts with their own source selection and accounting.

[The supplementary case check](../experiments/serial-library-growth/results/supplementary-package-checks.json) rebuilds four exact original goals and compares the complete compiled inventories, including private and automatically generated declarations. Full types use the historical fully explicit printer. Expression dependencies are compared separately from constructor and structure-field navigation edges; both are preserved in compiler exports.

[Current release validation](../metadata/current-validation.json) records the 70 Python tests, source and artifact integrity, clean public export, serial library, supplementary goals, three compiler versions and two migration clients per version. [The current tool check](../experiments/tool-validation/results/current-package-checks.json) is separate from the historical package report. These checks made no new model calls.
