module

public import Mathlib.Analysis.InnerProductSpace.Basic

@[expose] public section

open scoped InnerProductSpace

namespace Analysis.InnerProductSpace

/-- For a real normed space, `‖r • x‖ ^ 2 = r ^ 2 * ‖x‖ ^ 2`. -/
lemma norm_sq_smul (E : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E] (r : ℝ) (x : E) :
    ‖r • x‖ ^ 2 = r ^ 2 * ‖x‖ ^ 2 := by
  -- Replace the scaled norm by a product, then cancel the absolute value by squaring.
  rw [norm_smul, Real.norm_eq_abs, mul_pow, sq_abs]

/-- For a real inner product space, `⟪a • x, b • y⟫_ℝ = a * b * ⟪x, y⟫_ℝ`. -/
lemma real_inner_smul_smul (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (a b : ℝ) (x y : E) : ⟪a • x, b • y⟫_ℝ = a * b * ⟪x, y⟫_ℝ := by
  -- Pull out each real scalar and left-associate the resulting product.
  rw [real_inner_smul_left, real_inner_smul_right, mul_assoc]

/-- In `ℝ`, a weighted combination of squares differs from the squares of the weights by
`-t * (1 - t) * (u - 2 * c + v)`. -/
private lemma sqCombo_sub (t u v c : ℝ) :
    t ^ 2 * u + 2 * (t * (1 - t) * c) + (1 - t) ^ 2 * v - t * u - (1 - t) * v =
      -t * (1 - t) * (u - 2 * c + v) := by
  -- The two sides are identical as polynomials in the commutative ring `ℝ`.
  ring

/-- `Analysis.InnerProductSpace.euclideanNormSq_combo_sub`. In a real inner product space, the squared Euclidean norm of a convex combination satisfies
`‖t • x + (1 - t) • y‖ ^ 2 - t * ‖x‖ ^ 2 - (1 - t) * ‖y‖ ^ 2 = -t * (1 - t) * ‖x - y‖ ^ 2`
for every pair of vectors and every real weight `t`. -/
theorem euclideanNormSq_combo_sub (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (x y : E) (t : ℝ) :
    ‖t • x + (1 - t) • y‖ ^ 2 - t * ‖x‖ ^ 2 - (1 - t) * ‖y‖ ^ 2 =
      -t * (1 - t) * ‖x - y‖ ^ 2 := by
  -- Expand the combination before the gap, so a subtraction is not rewritten as an addition.
  rw [norm_add_sq_real (t • x) ((1 - t) • y), norm_sq_smul, norm_sq_smul, real_inner_smul_smul,
    norm_sub_sq_real]
  -- The normalized equality is the scalar identity at the squared norms and the inner product.
  exact sqCombo_sub t (‖x‖ ^ 2) (‖y‖ ^ 2) ⟪x, y⟫_ℝ

end Analysis.InnerProductSpace
