module

public import Mathlib.Analysis.InnerProductSpace.Basic
public import Mathlib.Topology.MetricSpace.Lipschitz
public import Mathlib.Data.NNReal.Defs

@[expose] public section

open scoped InnerProductSpace

universe u

/-- A map `f` defined on a subset `s` is `β`-cocoercive when
`β * ‖f z - f w‖ ^ 2 ≤ ⟪f z - f w, Subtype.val z - Subtype.val w⟫_ℝ` for every `z w : s`. -/
def Cocoercive {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ) {s : Set E}
    (f : s → E) : Prop :=
  ∀ z w, β * ‖f z - f w‖ ^ 2 ≤ ⟪f z - f w, Subtype.val z - Subtype.val w⟫_ℝ

/-- `β`-cocoercivity unfolds as the inner-product inequality with the value difference in the left
slot. -/
theorem cocoercive_iff {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ)
    {s : Set E} (f : s → E) :
    Cocoercive β f ↔
      ∀ z w, β * ‖f z - f w‖ ^ 2 ≤ ⟪f z - f w, Subtype.val z - Subtype.val w⟫_ℝ :=
  Iff.rfl

/-- `cocoercive_iff_inner_comm`. `β`-cocoercivity is equivalent to the same inequality with the inner-product arguments
commuted. -/
theorem cocoercive_iff_inner_comm {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (β : ℝ) {s : Set E} (f : s → E) :
    Cocoercive β f ↔
      ∀ z w, β * ‖f z - f w‖ ^ 2 ≤ ⟪Subtype.val z - Subtype.val w, f z - f w⟫_ℝ := by
  -- Commuting the real inner product does not change the cocoercivity inequality.
  rw [cocoercive_iff]
  constructor
  · intro h z w
    rw [real_inner_comm]
    exact h z w
  · intro h z w
    rw [real_inner_comm]
    exact h z w

/-- If `0 < β` and `β * ‖x‖ ^ 2 ≤ ⟪x, y⟫_ℝ`, then `‖x‖ ≤ β⁻¹ * ‖y‖`. -/
private lemma norm_le_inv_mul_norm_of_mul_norm_sq_le_inner {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {β : ℝ} {x y : E} (hβ : 0 < β) (h : β * ‖x‖ ^ 2 ≤ ⟪x, y⟫_ℝ) :
    ‖x‖ ≤ β⁻¹ * ‖y‖ := by
  -- Cauchy–Schwarz replaces the inner product by a product of norms.
  have hcs : β * ‖x‖ ^ 2 ≤ ‖x‖ * ‖y‖ := h.trans (real_inner_le_norm x y)
  by_cases hx : ‖x‖ = 0
  · -- The right-hand side is nonnegative, so the zero vector satisfies the bound.
    rw [hx]
    exact mul_nonneg (inv_nonneg.2 hβ.le) (norm_nonneg y)
  · -- Cancel the positive factor `‖x‖`, then rearrange `β * ‖x‖ ≤ ‖y‖`.
    have hxpos : 0 < ‖x‖ := lt_of_le_of_ne (norm_nonneg x) (Ne.symm hx)
    have hmul : ‖x‖ * (β * ‖x‖) ≤ ‖x‖ * ‖y‖ := by
      calc
        ‖x‖ * (β * ‖x‖) = β * ‖x‖ ^ 2 := by ring
        _ ≤ ‖x‖ * ‖y‖ := hcs
    have hβx : β * ‖x‖ ≤ ‖y‖ := le_of_mul_le_mul_left hmul hxpos
    exact (le_inv_mul_iff₀ hβ).2 hβx

/-- A map that is `β`-cocoercive for `0 < β` satisfies the Lipschitz inequality with constant
`β⁻¹`. -/
theorem Cocoercive.norm_sub_le {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {β : ℝ}
    {s : Set E} {f : s → E} (hβ : 0 < β) (hf : Cocoercive β f) :
    ∀ z w, ‖f z - f w‖ ≤ (β⁻¹) * ‖Subtype.val z - Subtype.val w‖ := by
  intro z w
  -- Cocoercivity is the inner-product hypothesis of the norm comparison at these increments.
  exact norm_le_inv_mul_norm_of_mul_norm_sq_le_inner hβ (hf z w)

/-- A map that is `β`-cocoercive for `0 < β` is `LipschitzWith` constant `Real.toNNReal (β⁻¹)`. -/
theorem Cocoercive.lipschitzWith {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {β : ℝ} {s : Set E} {f : s → E} (hβ : 0 < β) (hf : Cocoercive β f) :
    LipschitzWith (Real.toNNReal (β⁻¹)) f := by
  -- Package the pointwise norm bound in the distance form expected by `LipschitzWith`.
  refine LipschitzWith.of_dist_le' fun z w => ?_
  rw [dist_eq_norm, Subtype.dist_eq, dist_eq_norm]
  exact norm_sub_le hβ hf z w
