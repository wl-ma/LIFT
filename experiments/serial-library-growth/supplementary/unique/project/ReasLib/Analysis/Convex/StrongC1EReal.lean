module

public import ReasLib.Analysis.Convex.Strong
public import ReasLib.Analysis.Convex.StrongC1

@[expose] public section

universe u

/-- `StrongConvexC1On.iff_strongConvex_coe`. On a finite-dimensional real inner-product space, if `f : E → ℝ` is globally `ContDiff ℝ 1`
and `0 < μ`, then C¹ `μ`-strong convexity on `Set.univ` is equivalent to extended-real
`μ`-strong convexity of `fun x ↦ (f x : EReal)`. The norm is the inner-product norm, and the
whole-space domain is particular to this equivalence. -/
theorem StrongConvexC1On.iff_strongConvex_coe {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] [FiniteDimensional ℝ E] {μ : ℝ} {f : E → ℝ} (hμ : 0 < μ)
    (hf : ContDiff ℝ 1 f) :
    StrongConvexC1On Set.univ μ f ↔ StrongConvex μ (fun x ↦ (f x : EReal)) := by
  -- The coerced extended-real function is strongly convex exactly when `μ` is positive and `f`
  -- is strongly convex on the whole space; positivity is already `hμ`.
  rw [StrongConvex.coe_iff_strongConvexOn_univ, and_iff_right hμ]
  -- Global `C¹` strong convexity on a finite-dimensional space is ordinary strong convexity.
  exact StrongConvexC1On.iff_strongConvexOn (Set.univ : Set E) μ f convex_univ hμ
    (hf.contDiffOn (s := Set.univ))
