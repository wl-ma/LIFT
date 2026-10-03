module

public import Mathlib.Analysis.InnerProductSpace.Basic

@[expose] public section

open scoped InnerProductSpace

universe u

/-- An operator `A : E → Set E` is `β`-strongly monotone when every pair of graph values satisfies
`β * ‖x - y‖ ^ 2 ≤ ⟪x - y, u - v⟫_ℝ`. Positivity of the modulus `β` is not part of this property. -/
def StronglyMonotone {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ)
    (A : E → Set E) : Prop :=
  ∀ x y u v, u ∈ A x → v ∈ A y → β * ‖x - y‖ ^ 2 ≤ ⟪x - y, u - v⟫_ℝ

/-- `β`-strong monotonicity unfolds as the graph inequality on every pair of operator values. -/
theorem stronglyMonotone_iff {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ)
    (A : E → Set E) :
    StronglyMonotone β A ↔
      ∀ x y u v, u ∈ A x → v ∈ A y → β * ‖x - y‖ ^ 2 ≤ ⟪x - y, u - v⟫_ℝ :=
  Iff.rfl

/-- Every graph pair of a `β`-strongly monotone operator satisfies the strong monotonicity
inequality. -/
theorem StronglyMonotone.le_inner {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {β : ℝ} {A : E → Set E} (hA : StronglyMonotone β A) {x y u v : E} (hu : u ∈ A x)
    (hv : v ∈ A y) : β * ‖x - y‖ ^ 2 ≤ ⟪x - y, u - v⟫_ℝ :=
  hA x y u v hu hv

/-- `StronglyMonotone.to_zero`. Nonnegative strong monotonicity implies monotonicity, that is `StronglyMonotone 0`. -/
theorem StronglyMonotone.to_zero {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {β : ℝ} {A : E → Set E} (hβ : 0 ≤ β) (hA : StronglyMonotone β A) : StronglyMonotone 0 A := by
  -- The zero-modulus inequality is `0 ≤ ⟪x - y, u - v⟫`, and `0 ≤ β * ‖x - y‖ ^ 2` by nonnegativity.
  intro x y u v hu hv
  rw [zero_mul]
  exact (mul_nonneg hβ (sq_nonneg _)).trans (hA.le_inner hu hv)
