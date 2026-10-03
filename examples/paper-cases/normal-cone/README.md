# Normal-cone interface and research-proof reuse

This is the normal-cone case in the paper’s interface and recovery study. The 60 original
ReasLib modules form the complete local import closure of the actual caller
Lorentz.exists_seedCounterexample. Their mathematical bodies match the recorded source snapshot.
Apache-2.0 attribution headers credit LIFT contributors;
[publication bindings](../../../metadata/source-publication.json) connect original
source hashes to the distributed files.

The public theorem is DualPairing.maximalMonotone_normalConeGraph_closedBall.
C0Seq.coordinateDualPairing_surjective supplies its representation hypothesis.
[SourceRecovery.lean](SourceRecovery.lean) checks the original radius 1/2 with an
explicit full type. The [actual caller](ReasLib/FunctionalAnalysis/SequenceSpace/RationalTimeOperator/Parametrization/SeedCounterexample.lean)
uses radius 12. [The retained source](historical/Theorem_7_12.lean.txt) remains
historical evidence, with its historical import paths; it is not silently rewritten.

The four unchanged core modules, integration manifest, and source snapshot bindings
are in [case provenance](../../../experiments/downstream-reuse/data/normal-cone.json) and
[INF-044 projection](../../../experiments/downstream-reuse/data/normal-cone-integration.json).
The [upstream Comparator report](../../../experiments/downstream-reuse/data/normal-cone-comparator-upstream.md)
concerns three exported interfaces at a separately recorded source snapshot. This release
does not claim to have rerun Comparator. Its own [compilation and five-declaration
axiom audit](../../../experiments/downstream-reuse/results/package-checks.json) is separate from the paper's
original five files / nine declarations.

From this directory, run 'lake update' and 'lake exe cache get'. From repository root:

~~~sh
python3 scripts/check_case.py normal-cone --output _runs/normal-cone-check
~~~

The checker preserves the original maxSynthPendingDepth = 3 and other Lean
options. It compiles project modules sequentially, checks exact axiom identities,
and admits only propext, Classical.choice, and Quot.sound.
