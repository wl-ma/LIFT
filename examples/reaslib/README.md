# ReasLib mathematical examples

This is a selected Lean 4.32.0 example project drawn from the paper's retained exports. Five original Lean files are preserved byte-for-byte; the root import module, Lake configuration, and `Audit.lean` are release packaging.

| Original component | Released file |
| --- | --- |
| General Taylor interfaces | [ReasLib/Analysis/Calculus/Taylor.lean](ReasLib/Analysis/Calculus/Taylor.lean) |
| Finite-dimensional Taylor source application | [Theorem_2_1.lean](NocedalNumericalOptimization/Chapter02/Theorem_2_1.lean) |
| First-order optimality source type | [Theorem_2_2.lean](NocedalNumericalOptimization/Chapter02/Theorem_2_2.lean) |
| Fundamental group maps and equivalence | [Product.lean](ReasLib/AlgebraicTopology/FundamentalGroup/Product.lean) |
| Topology source application | [Exercise_3_2.lean](RiemannSurfaces/Chapter1/Exercise_3_2.lean) |

## Build and audit

```bash
lake update
lake exe cache get
lake build
lake env lean Audit.lean
```

Run these commands in this directory. Elan selects `leanprover/lean4:v4.32.0`; the Lake configuration pins Mathlib to `81a5d257c8e410db227a6665ed08f64fea08e997`. Dependency setup may download substantial cache files.

`Audit.lean` checks nine names, including the existing Mathlib optimality theorem. All should report dependencies contained in `{propext, Classical.choice, Quot.sound}`. Merely seeing a successful build is not the complete audit: inspect the reported axioms as well.

An existing matching cache can be used without another download through [scripts/check_lean.py](../../scripts/check_lean.py). See [reproduction](../../docs/reproduce.md).

## Reading the mathematics

**Optimality.** `Theorem_2_2` checks an instance of `IsLocalMin.fderiv_eq_zero` on `EuclideanSpace ℝ (Fin n)`. For the smooth source this recovers the required derivative condition. The totalized derivative API does not remove the mathematical need to interpret differentiability correctly.

**Taylor.** The public module works with real normed spaces and continuous linear maps. The source application specializes the general space and codomain to the original coordinate setting. The three named conclusions concern first-order expansion, the integral representation of derivative change, and second-order expansion.

**Topology.** Projection and pairing define homomorphisms between the fundamental group of a product and the product of fundamental groups. Left- and right-inverse laws assemble them into `prodMulEquiv`. Base points stay explicit. The source application checks the resulting interfaces at its prescribed types.

This project demonstrates the selected components together; it is not the entire ReasLib corpus. Source hashes and original project/module origins appear in [provenance](../../data/release-provenance.json). Distribution does not assign new licensing terms to upstream material; see [reuse notes](../../docs/provenance-and-reuse.md).
