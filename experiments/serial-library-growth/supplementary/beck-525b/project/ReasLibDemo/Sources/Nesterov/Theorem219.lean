module

public import ReasLib.Analysis.Convex.StrongC1

@[expose] public section

universe u

/-Nesterov Theorem219. Let `Q` be a convex subset of a finite-dimensional real normed space,
let `μ > 0`, and let `f : E → ℝ` be continuously differentiable on `Q` in the sense
`ContDiffOn ℝ 1 f Q`. Then `StrongConvexC1On Q μ f` is equivalent to the conjunction of
derivative monotonicity
`μ * ‖x - y‖ ^ 2 ≤ (fderivWithin ℝ f Q x) (x - y) - (fderivWithin ℝ f Q y) (x - y)`
for all `x, y ∈ Q`, and the convex-combination inequality
`f (α • x + (1 - α) • y) + α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 ≤ α * f x + (1 - α) * f y`
for all `x, y ∈ Q` and all `α ∈ Set.Icc (0 : ℝ) 1`. The pairing is `fderivWithin` on the
direction `x - y`, for an arbitrary ambient norm. `Q` may be empty and need not be open.-/
#check (StrongConvexC1On.iff_fderivMono_convexCombo :
  ∀ {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    (Q : Set E) (μ : ℝ) (f : E → ℝ),
    Convex ℝ Q → 0 < μ → ContDiffOn ℝ 1 f Q →
      (StrongConvexC1On Q μ f ↔
        (∀ x ∈ Q, ∀ y ∈ Q,
          μ * ‖x - y‖ ^ 2 ≤
            (fderivWithin ℝ f Q x) (x - y) - (fderivWithin ℝ f Q y) (x - y)) ∧
        (∀ x ∈ Q, ∀ y ∈ Q, ∀ α : ℝ, α ∈ Set.Icc 0 1 →
          f (α • x + (1 - α) • y) + α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 ≤
            α * f x + (1 - α) * f y)))
