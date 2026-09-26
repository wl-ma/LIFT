# Method overview

LIFT starts from fixed formal source specifications. Its output combines a public library, source correspondences, and evidence recovering the sources. For theorems, recovery supplies the original conclusion under the original hypotheses. For definitions and structures, it supplies prescribed data, defining equations, and required operation laws.

## Interface and recovery are one design problem

If a reusable theorem needs an assumption the source cannot justify, it cannot recover that source. If a representation map forgets a required operation, a value of the desired output type is still insufficient. The public statement and its source adaptation must therefore be chosen together.

The examples illustrate three choices. An existing derivative theorem can already match a first-order optimality result. A Taylor theorem can expose a general normed-space interface while retaining a finite-dimensional specialization. Product fundamental groups need concrete homomorphisms and inverse laws, which support actual use of the equivalence.

In the Taylor example, a generalized interface is observed, but the case does not establish that two independent sources jointly induced a common abstraction. The release preserves what the artifacts demonstrate.

## Parallel candidates, coordinated incorporation

Multiple producers build candidate interfaces and recoveries using a visible library context. One consumer checks and reconciles candidates with the current library. An overlapping or invalid candidate can return for repair; later revisions may use content accepted while their earlier attempts were pending.

The Beck trace makes this concrete: congruence for strong convexity is accepted first; a later revision uses that new interface to reconcile two presentations of half the squared norm. The event log and the changed proof together support this interpretation.

## Construction and release

Intermediate construction can settle statements and adaptations while proof obligations remain. A verified release requires completed proofs, permitted dependencies, recovered source specifications, and the relevant fixed-client checks. Successful integration records do not by themselves establish those release conditions.

The public data covers project-level construction records, linked proof work, selected declaration checks, and a source checkpoint. The full distributed orchestration backend and a unified verified 20-project release are not packaged here.

## Input preparation

Lean-to-JSON extraction preserves identities and formal types before a model supplies natural-language descriptions. Module imports describe file context; elaborated declaration references identify mathematical dependencies. The current public extractor exports the latter directly from Lean.

Version alignment belongs to preparation. A separate copy is built under a target compiler/dependency environment; types, prescribed definitions, axioms and original applications remain preservation targets. A successful build is one signal, while interface recovery requires additional checks.
