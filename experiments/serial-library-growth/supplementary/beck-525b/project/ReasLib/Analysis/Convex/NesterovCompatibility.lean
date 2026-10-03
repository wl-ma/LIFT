module

public import ReasLib.Analysis.Convex.StrongC1

@[expose] public section

universe u

/-- `StrongConvexC1On.iff`. Preserve the complete source interface for Nesterov Definition 2.1.3.
The explicit real codomain instance retains the original elaborated type. -/
theorem StrongConvexC1On.iff {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [FiniteDimensional ℝ E] (Q : Set E) (μ : ℝ) (f : E → ℝ) :
    StrongConvexC1On Q μ f ↔
      Convex ℝ Q ∧ 0 < μ ∧
        (@ContDiffOn ℝ _ E _ _ ℝ _ (NormedField.toNormedSpace) 1 f Q) ∧
          ∀ x ∈ Q, ∀ y ∈ Q,
            f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y := by
  -- `NormedField.toNormedSpace` is the canonical `NormedSpace ℝ ℝ` instance, so the explicit
  -- codomain spelling is the published finite-dimensional characterization.
  exact strongConvexC1On_iff_of_finiteDimensional Q μ f
