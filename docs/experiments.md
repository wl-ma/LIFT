# Paper experiments and artifacts

This index maps the paper's experimental questions and stable table/figure labels to the released evidence. The [experiment registry](../metadata/experiments.json) supplies the same organization in machine-readable form.

| Paper section / label | Evidence and command |
| --- | --- |
| Construction across domains; `tab:construction-full`, `tab:mainresults`, `tab:library-full`, `tab:corpus-scope` | [Corpus inputs and outputs](../experiments/corpus-construction/README.md); `python3 scripts/reproduce_tables.py --check` |
| Declaration decisions; `tab:actions-full`, `fig:action-profile` | [Action table](../experiments/corpus-construction/results/declaration-actions.csv); `python3 scripts/plot_results.py --output _runs/figures` |
| Interfaces and source recovery; `tab:interfaces`, `tab:checked-declarations` | [Pinned Lean cases](../examples/paper-cases/reaslib/README.md); `python3 scripts/check_lean.py --output _runs/source-recovery` |
| Proof completion; `tab:proof-handoff`, `tab:handoff-detail` | [Batches, obligations, and task links](../experiments/source-recovery/README.md); `python3 scripts/reproduce_tables.py --check` |
| Normal-cone research-proof reuse; `tab:normal-cone-recovery` | [Public interface and actual caller](../experiments/downstream-reuse/README.md); `python3 scripts/check_case.py normal-cone --output _runs/downstream-reuse` |
| Online revision; `tab:online-revision`, `tab:revision-events`, `fig:growth-evaluation` | [Trace, patch, and checkpoint](../experiments/online-revision/README.md); `python3 scripts/check_case.py beck --output _runs/online-revision` |

Compiler checks require the pinned dependencies described in [reproduction](reproducibility.md). [Supporting-tool tests](../experiments/tool-validation/README.md) are package validation, separate from the paper's model experiments.

## Follow a Taylor recovery

1. [Obligations 0001–0003](../experiments/source-recovery/results/proof-obligations.csv) name `Taylor.existsFirstOrder`, `Taylor.fderivAddEqIntegral`, and `Taylor.existsSecondOrder`.
2. [Task links](../experiments/source-recovery/results/proof-task-links.csv) associate all three with `proof-task-0001`.
3. [Taylor.lean](../examples/paper-cases/reaslib/ReasLib/Analysis/Calculus/Taylor.lean) implements the public statements in real normed spaces.
4. [Theorem_2_1.lean](../examples/paper-cases/reaslib/NocedalNumericalOptimization/Chapter02/Theorem_2_1.lean) specializes them to Euclidean coordinates and checks the full source types.
5. [Audit.lean](../examples/paper-cases/reaslib/Audit.lean) checks the named declarations' axiom dependencies.

## Counting units

The construction table contains 20 developments with 10,922 catalogue items and 5,061 accepted integrations. Public modules contribute 15,716 occurrences, including inherited content and unfinished proofs. Action counts measure recorded decisions rather than unique declarations.

The seven selected batches contain 118 successful integration items and 135 successful proof tasks. There are 249 linked obligations, 258 obligation–task edges, and 72 distinct linked task aliases. These cardinalities measure different objects. The selected five-file case bundle additionally checks nine declarations in Lean.

The normal-cone bundle supplies separate downstream evidence. The Beck 20-declaration/22-client result describes a working-state checkpoint. The broader first run failed final public-manifest validation; the second run accepted no mathematical update. Both outcomes remain in the records.

[Complete data dictionary](../experiments/README.md) · [Sources and licenses](provenance-and-reuse.md)

[Paper correspondence verification](../metadata/paper-correspondence-check.json) binds the manuscript identity, all experiment labels, and 175 unchanged paper data and mathematical source files. The serial library demonstration and supplementary cases retain separate selections and accounting.
