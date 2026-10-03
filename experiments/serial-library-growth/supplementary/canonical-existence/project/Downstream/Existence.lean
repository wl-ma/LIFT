import ReasLib
import Downstream.Definitions

/-- The smoothed payoff `u ↦ A x u - phihat u - μ * d2 u` is continuous on `Q2`
whenever `phihat` and `d2` are continuous on `Q2`. -/
private lemma continuousOn_smoothedObjective {E1 E2 : Type*} [NormedAddCommGroup E1]
    [NormedSpace ℝ E1] [NormedAddCommGroup E2] [NormedSpace ℝ E2] (Q2 : Set E2)
    (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ)) (phihat d2 : E2 → ℝ) (μ : ℝ) (x : E1)
    (hphihat : ContinuousOn phihat Q2) (hd2 : ContinuousOn d2 Q2) :
    ContinuousOn (fun u => A x u - phihat u - μ * d2 u) Q2 := by
  -- The continuous linear pairing restricts to a continuous function on `Q2`.
  have hAx : ContinuousOn (fun u => A x u) Q2 := (A x).continuous.continuousOn
  -- Subtract `phihat`, then the scaled continuous term `μ * d2`, matching left-associated subtraction.
  exact (hAx.sub hphihat).sub (hd2.const_mul μ)

/-- smoothedMaximizer_exists: on a nonempty closed bounded `Q2` in a finite-dimensional real normed space, the continuous payoff `u ↦ A x u - phihat u - μ * d2 u` attains a maximizer. -/
lemma smoothedMaximizer_exists {E1 E2 : Type*} [NormedAddCommGroup E1] [NormedSpace ℝ E1]
    [FiniteDimensional ℝ E1] [NormedAddCommGroup E2] [NormedSpace ℝ E2]
    [FiniteDimensional ℝ E2] (Q2 : Set E2) (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ))
    (phihat d2 : E2 → ℝ) (μ : ℝ) (x : E1) (hQ2_closed : IsClosed Q2)
    (hQ2_bdd : Bornology.IsBounded Q2) (hQ2_nonempty : Q2.Nonempty)
    (hphihat : ContinuousOn phihat Q2) (hd2 : ContinuousOn d2 Q2) :
    ∃ u, IsSmoothedMaximizer Q2 A phihat d2 μ x u := by
  -- Heine–Borel: a closed bounded subset of a finite-dimensional real normed space is compact.
  have hQ2_compact : IsCompact Q2 :=
    Metric.isCompact_of_isClosed_isBounded hQ2_closed hQ2_bdd
  -- A continuous real function on a nonempty compact set attains its maximum.
  obtain ⟨u, hu, hmax⟩ :=
    hQ2_compact.exists_isMaxOn hQ2_nonempty
      (continuousOn_smoothedObjective Q2 A phihat d2 μ x hphihat hd2)
  -- `IsMaxOn` is the pointwise inequality in `IsSmoothedMaximizer`.
  exact ⟨u, hu, hmax⟩
