module

public import ReasLib.Analysis.Convex.QuadraticShift
public import ReasLib.Analysis.InnerProductSpace.NormSq

/-
Beck Theorem517
-/
#check (Analysis.Convex.strongConvex_iff_convex_subNormSq :
  ∀ (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
    (σ : ℝ) (f : E → EReal),
      0 < σ → (∀ x, ⊥ < f x) →
        (StrongConvex σ f ↔
          ∃ g : E → ℝ,
            (∀ x, x ∈ effectiveDomain f → (f x).toReal = g x + (σ / 2) * ‖x‖ ^ 2) ∧
              ConvexOn ℝ (effectiveDomain f) g))
