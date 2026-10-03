module

public import ReasLib.Analysis.Convex.Strong

universe u

@[expose] public section

/- Bauschke Definition107. A proper function `f : E → EReal` on a real inner product space is
strongly convex with constant `β > 0` when, for every `x, y` in `effectiveDomain f` and every
`α ∈ Set.Ioo (0 : ℝ) 1`, the value at the convex combination plus
`α * (1 - α) * (β / 2) * ‖x - y‖ ^ 2` is at most the same combination of the values. Properness
means that `f` never takes `⊥` and the effective domain is nonempty. This open additive form is
equivalent to `StrongConvex β f` together with a nonempty effective domain. -/
#check (StrongConvex.iff_proper_Ioo :
  ∀ {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ) (f : E → EReal),
    StrongConvex β f ∧ (effectiveDomain f).Nonempty ↔
      0 < β ∧ (∀ x, ⊥ < f x) ∧ (effectiveDomain f).Nonempty ∧
        ∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ α ∈ Set.Ioo (0 : ℝ) 1,
          f (α • x + (1 - α) • y) +
              ((α * (1 - α) * (β / 2) * ‖x - y‖ ^ 2 : ℝ) : EReal) ≤
            (α : EReal) * f x + ((1 - α) : EReal) * f y)
