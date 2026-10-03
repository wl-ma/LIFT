module

public import ReasLib.Analysis.InnerProductSpace.StronglyMonotone

universe u

/- An operator `A : E → Set E` is `β`-strongly monotone when every graph pair satisfies
`β * ‖x - y‖ ^ 2 ≤ ⟪x - y, u - v⟫_ℝ`. -/
#check (StronglyMonotone :
  ∀ {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E], ℝ → (E → Set E) → Prop)
