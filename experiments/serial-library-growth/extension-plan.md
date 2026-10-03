# Serial ReasLib extension sources

The completed construction sequence connects strong convexity, subgradient monotonicity and resolvent contraction. Six source items from three books and one explicitly labelled synthesis bridge are selected in the [machine-readable selection](data/extension-selection.json). All three batches have accepted releases; [results and exact compiler checks](README.md) accompany the selection.

## Sources and exact scope

| Batch | Source | Item and printed page | Mathematical role |
| --- | --- | --- | --- |
| 1 | Beck, *First-Order Methods in Optimization* (2017) | Lemma 5.20; Example 5.21, p.119 | Addition and constrained quadratic functions |
| 2 | Nesterov, *Lectures on Convex Optimization*, second edition (2018) | Lemma 2.1.6; Theorem 2.1.8, p.74 | Weighted curvature and stationary quadratic growth |
| 3 | Bauschke–Combettes, *Convex Analysis and Monotone Operator Theory in Hilbert Spaces*, second edition (2017) | Example 22.4(iv), pp.384–385; Proposition 23.13, p.397 | Subgradient strong monotonicity and resolvent contraction |

Publication records: [Beck](https://doi.org/10.1137/1.9781611974997), [Nesterov](https://link.springer.com/book/10.1007/978-3-319-91578-4), [Bauschke–Combettes](https://link.springer.com/book/10.1007/978-3-319-48311-5). The selection binds the inspected PDFs by SHA256 and records both printed and PDF page numbers. All descriptions here are original paraphrases.

## Why these items

The existing library has extended-real `StrongConvex`, real-valued `StrongConvexC1On`, a quadratic shift interface, and a shared squared-norm identity. The addition lemma supplies a reusable operation; the constrained quadratic is a concrete consumer. Nesterov's weighted sum connects curvature arithmetic with differentiable functions. Its stationary-point result supplies an optimization consumer. Bauschke's subgradient result transports the same curvature to an operator, and the resolvent result then uses that operator property.

The Nesterov bridge is a separate synthesis obligation: connect the real-valued C1 predicate with the extended-real predicate for a real-to-extended-real embedding on a finite-dimensional real inner-product space. Existing `StrongConvexC1On.iff_strongConvexOn` and `strongConvex_iff_strongConvexOn` provide endpoints. The bridge must be proved and then used in a retained compiled proof; an import, a matching name, or a standalone bridge does not count as cross-source proof reuse.

Two distinctions affect the specification. Nesterov permits zero weights and uses the zero-curvature convex class; the current positive-parameter structure alone cannot represent that full lemma. Introduce a nonnegative-curvature interface or prove the zero case separately while preserving the old structure. Bauschke's resolvent is defined on the range of `Id + A`; totality on the entire space needs a separate maximal-monotonicity argument.

## Serial execution and checks

1. Freeze the current accepted project, original clients, exact source statements, selection hash, compiler and dependency pins.
2. Add Beck's two items to that project through statement preparation, library integration and proof. Check source recovery and a nonsmooth indicator client.
3. Add the synthesis bridge and the two Nesterov items to the resulting project through the same full workflow. Check zero weights, nonzero weights and a stationary quadratic client. Retain the original arbitrary-norm source statements; only the bridge has the narrower inner-product scope.
4. Add Bauschke's two items to the same project. First qualify any missing subgradient/resolvent definitions as separately recorded background work. Check the original Hilbert-space statements, both directions of Proposition 23.13 and its contraction bound. A scalar quadratic resolvent provides an independent client; it does not replace the general source theorem.
5. At every accepted release, compile the entire controlled project and unchanged old clients; collect full declaration types, trust closure and actual proof dependencies. For each expected upstream interface, report whether a new downstream proof really uses it. Preserve every rejection and all settled calls.

Use three result columns: source recovery, actual shared proof dependency, and independently compiled use. Record representation bridges separately. No-reuse outcomes stay in the result set. Hand-written selection specifications and evaluation clients are not counted as automatic construction successes.

## Related source goals

[Supplementary cases](supplementary/README.md) contain the completed Beck 5.25(b) quadratic-growth goal and three smoothing goals: uniqueness, stability and existence of maximizers. Each records its exact source type and actual library dependencies separately from the construction releases.
