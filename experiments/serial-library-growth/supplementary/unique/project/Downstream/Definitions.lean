import Mathlib

def IsSmoothedMaximizer {E1 E2 : Type*} [NormedAddCommGroup E1] [NormedSpace ℝ E1]
    [NormedAddCommGroup E2] [NormedSpace ℝ E2] (Q2 : Set E2)
    (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ)) (phihat d2 : E2 → ℝ) (μ : ℝ) (x : E1) (u : E2) : Prop :=
  u ∈ Q2 ∧
    ∀ v ∈ Q2, A x v - phihat v - μ * d2 v ≤ A x u - phihat u - μ * d2 u
