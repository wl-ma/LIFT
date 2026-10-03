module

public import ReasLib.Analysis.Convex.QuadraticShift

public section

universe u

namespace StrongConvex

/-- `StrongConvex.leCombo_Ioo_iff_convex_subNormSq`. Preserve the complete
Bauschke Proposition108 interface after the theorem was promoted to the shared library. -/
theorem leCombo_Ioo_iff_convex_subNormSq {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] (β : ℝ) (f : E → EReal) (hβ : 0 < β) (hbot : ∀ x, ⊥ < f x)
    (hdom : (effectiveDomain f).Nonempty) :
    (∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ α ∈ Set.Ioo (0 : ℝ) 1,
        f (α • x + (1 - α) • y) +
            ((α * (1 - α) * (β / 2) * ‖x - y‖ ^ 2 : ℝ) : EReal) ≤
          (α : EReal) * f x + ((1 - α) : EReal) * f y) ↔
      (∀ x y : E, ∀ α ∈ Set.Ioo (0 : ℝ) 1,
        subNormSq β f (α • x + (1 - α) • y) ≤
          (α : EReal) * subNormSq β f x + ((1 - α) : EReal) * subNormSq β f y) :=
  -- The published root theorem has this exact type, so namespace recovery is a direct application.
  _root_.leCombo_Ioo_iff_convex_subNormSq β f hβ hbot hdom

end StrongConvex
