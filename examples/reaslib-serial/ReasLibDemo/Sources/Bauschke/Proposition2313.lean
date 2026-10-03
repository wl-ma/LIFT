module

public import ReasLib.Analysis.InnerProductSpace.Resolvent

universe u

/- Bauschke Proposition2313 (1). On a real inner product space, let `A : E → Set E` be monotone
and let `0 < β`. Then `A` is `β`-strongly monotone if and only if `operatorResolvent A` is
`(β + 1)`-cocoercive. -/
#check (stronglyMonotone_iff_resolvent_cocoercive :
  ∀ {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ) (A : E → Set E),
    StronglyMonotone 0 A → 0 < β →
      (StronglyMonotone β A ↔ Cocoercive (β + 1) (operatorResolvent A)))

/- Bauschke Proposition2313 (2). On a real inner product space, let `A : E → Set E` be monotone,
let `0 < β`, and assume `StronglyMonotone β A`. Then `operatorResolvent A` is Lipschitz on
`resolventDomain A` with constant `1 / (β + 1)`. -/
#check (resolvent_norm_sub_le :
  ∀ {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ) (A : E → Set E),
    StronglyMonotone 0 A → 0 < β → StronglyMonotone β A →
      ∀ z w : resolventDomain A,
        ‖operatorResolvent A z - operatorResolvent A w‖ ≤
          (1 / (β + 1)) * ‖Subtype.val z - Subtype.val w‖)
