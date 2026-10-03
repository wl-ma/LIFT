module

public import ReasLib.Analysis.Convex.QuadraticShift

universe u

/- Bauschke Proposition108. Let `f : E → EReal` be proper, in the sense that `∀ x, ⊥ < f x`
and `(effectiveDomain f).Nonempty`, and let `0 < β`. On a real inner product space, `f` is
strongly convex with constant `β` if and only if `subNormSq β f` is convex. Strong convexity
is the open additive inequality on `effectiveDomain f` for every `α ∈ Set.Ioo (0 : ℝ) 1`, and
convexity of the shift is the global open-interval Jensen inequality. -/
#check (leCombo_Ioo_iff_convex_subNormSq :
  ∀ {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ) (f : E → EReal),
    0 < β → (∀ x, ⊥ < f x) → (effectiveDomain f).Nonempty →
      ((∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ α ∈ Set.Ioo (0 : ℝ) 1,
          f (α • x + (1 - α) • y) +
              ((α * (1 - α) * (β / 2) * ‖x - y‖ ^ 2 : ℝ) : EReal) ≤
            (α : EReal) * f x + ((1 - α) : EReal) * f y) ↔
        (∀ x y : E, ∀ α ∈ Set.Ioo (0 : ℝ) 1,
          subNormSq β f (α • x + (1 - α) • y) ≤
            (α : EReal) * subNormSq β f x + ((1 - α) : EReal) * subNormSq β f y)))
