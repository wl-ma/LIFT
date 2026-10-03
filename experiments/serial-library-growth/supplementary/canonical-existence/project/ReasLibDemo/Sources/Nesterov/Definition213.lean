module

public import ReasLib.Analysis.Convex.StrongC1
public import Mathlib.LinearAlgebra.FiniteDimensional.Defs

/-Nesterov Definition213. Let `Q` be a convex subset of a finite-dimensional real normed space,
equipped with the ambient norm `‖·‖`, and let `μ > 0`. A function `f : E → ℝ`, read as a map on
`Q`, that is continuously differentiable on `Q` is `μ`-strongly convex on `Q` with respect to
`‖·‖` when, for all `x, y ∈ Q`,
`f y ≥ f x + (fderivWithin ℝ f Q x) (y - x) + (μ / 2) * ‖y - x‖ ^ 2`.
The book membership notation is `f ∈ S¹_{μ,1}(Q, ‖·‖)`; the second subscript is notation for this
`C¹` class and is not a Lipschitz rank. Continuous differentiability means `ContDiffOn ℝ 1 f Q`
within `Q`, not on an open neighborhood, not `UniqueDiffOn`, and not whole-space `ContDiff`. The
linear term is `(fderivWithin ℝ f Q x) (y - x)`, the derivative applied to the direction `y - x`,
not an inner product and not `gradientWithin`. `Q` may be empty and need not be open or equal to
`Set.univ`. The constant `μ` is the strong-convexity parameter of `f`.-/
#check (strongConvexC1On_iff_of_finiteDimensional : ∀ {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E] (Q : Set E) (μ : ℝ) (f : E → ℝ), StrongConvexC1On Q μ f ↔ Convex ℝ Q ∧ 0 < μ ∧ ContDiffOn ℝ 1 f Q ∧ ∀ x ∈ Q, ∀ y ∈ Q, f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y)
