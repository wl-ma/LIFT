module

public import ReasLib.Analysis.Convex.StrongC1EReal

@[expose] public section

universe u

/-
ReasLib C1ERealBridge. On a finite-dimensional real inner-product space, if `f : E → ℝ` is
globally `ContDiff ℝ 1` and `0 < μ`, then `StrongConvexC1On Set.univ μ f` is equivalent to
`StrongConvex μ (fun x ↦ (f x : EReal))`. Both directions are required. The inner-product norm and
the whole-space domain specialize this bridge only and are not imposed on the original `C¹`
interfaces.
-/
#check (StrongConvexC1On.iff_strongConvex_coe :
  ∀ {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
    {μ : ℝ} {f : E → ℝ}, 0 < μ → ContDiff ℝ 1 f →
      (StrongConvexC1On Set.univ μ f ↔ StrongConvex μ (fun x ↦ (f x : EReal))))
