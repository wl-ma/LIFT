# Manuscript-to-artifact map

This index follows the version10 manuscript (26 September 2026). LaTeX labels identify tables independently of layout-dependent numbering. The paper source hash is in [release provenance](../data/release-provenance.json).

| Paper result or label | Released evidence | Reproduction / interpretation |
| --- | --- | --- |
| Construction corpus, `tab:construction-full` | [20-project table](../data/construction.csv) | Sum catalogue and integrated items: 10,922 and 5,061 |
| Domain aggregation, `tab:mainresults`; public context, `tab:library-full` | [Construction](../data/construction.csv), [module profiles](../data/module-profile.csv) | 15,716 module occurrences, including inherited and unfinished content |
| Declaration decisions, `tab:actions-full`, `fig:action-profile` | [Action counts](../data/declaration-actions.csv), [figure](figures/result-action-profile.svg) | Sum the five action columns; combine both retention categories |
| Interfaces and recovery, `tab:interfaces`, `tab:checked-declarations` | [Lean project](../examples/reaslib/README.md), [historical checks](../data/lean-checks-historical.json) | Five source files compile; nine declarations pass the recorded axiom audit |
| Proof completion, `tab:proof-handoff`, `tab:handoff-detail` | [Batch totals](../data/proof-handoff.csv), [249 obligations](../data/proof-obligations.csv), [task links](../data/proof-task-links.csv) | A proof task can discharge several obligations; record linkage is distinct from kernel checking |
| Online revision, `tab:online-revision`, `tab:revision-events` | [Trace](../data/online-trace.csv), [patch](../data/online-revision.patch), [checkpoint](../data/online-checkpoint.json) | Previously accepted `congr` participates in the revised proof using the newly added `mul_sq_norm` |

## Taylor: follow one concrete evidence chain

1. [Obligations 0001–0003](../data/proof-obligations.csv) identify `Taylor.existsFirstOrder`, `Taylor.fderivAddEqIntegral`, and `Taylor.existsSecondOrder` in the same public module.
2. [Task links](../data/proof-task-links.csv) give all three the same release-local alias, `proof-task-0001`. This preserves their shared successful task identity without publishing internal service identifiers.
3. [Taylor.lean](../examples/reaslib/ReasLib/Analysis/Calculus/Taylor.lean) contains those three implementations. The first and third interfaces have real scalar codomain; the integral identity retains its codomain completeness assumptions.
4. The source application [Theorem_2_1.lean](../examples/reaslib/NocedalNumericalOptimization/Chapter02/Theorem_2_1.lean) specializes all three public interfaces to Euclidean coordinates, with explicit original types in three `#check` commands.
5. [Audit.lean](../examples/reaslib/Audit.lean) checks the public declarations' axioms; compiling the source application checks the specialization at its original type. Run the commands in [reproduction](reproduce.md).

## Coverage boundary

This package contains the curated numerical evidence for all four experimental subsections, the three selected mathematical cases, and the retained online revision. Algorithm pseudocode, illustrative appendix examples, and method diagrams describe the method; they are not additional completed experimental runs. The entire paper PDF, full 20-project exports, orchestration runtime, original textbooks, and raw model logs are not included. The compiler extractor and toolchain helper are support tools, with their own packaging checks rather than new paper results.
