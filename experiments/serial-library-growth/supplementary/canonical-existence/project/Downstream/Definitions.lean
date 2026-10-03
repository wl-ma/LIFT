import Mathlib

def IsSmoothedMaximizer {E1 E2 : Type*} [NormedAddCommGroup E1] [NormedSpace ℝ E1]
    [NormedAddCommGroup E2] [NormedSpace ℝ E2] (Q2 : Set E2)
    (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ)) (phihat d2 : E2 → ℝ) (μ : ℝ) (x : E1) (u : E2) : Prop :=
  u ∈ Q2 ∧
    ∀ v ∈ Q2, A x v - phihat v - μ * d2 v ≤ A x u - phihat u - μ * d2 u

noncomputable def SmoothedMaxFunction {E1 E2 : Type*} [NormedAddCommGroup E1]
    [NormedSpace ℝ E1] [NormedAddCommGroup E2] [NormedSpace ℝ E2]
    (Q2 : Set E2) (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ)) (phihat d2 : E2 → ℝ) (μ : ℝ) :
    E1 → ℝ :=
  fun x => sSup ((fun u => A x u - phihat u - μ * d2 u) '' Q2)

def DualPairing {E : Type*} [SeminormedAddCommGroup E] [NormedSpace ℝ E]
    [FiniteDimensional ℝ E]
    (s : Module.Dual ℝ E) (x : E) : ℝ :=
  s x

noncomputable def DualNormDef {E : Type*} [SeminormedAddCommGroup E] [NormedSpace ℝ E]
    [FiniteDimensional ℝ E] (s : Module.Dual ℝ E) : ℝ :=
  sSup { r : ℝ | ∃ x : E, ‖x‖ = 1 ∧ r = DualPairing s x }

def AdjointOperator {E1 E2 : Type*} [SeminormedAddCommGroup E1] [NormedSpace ℝ E1]
    [FiniteDimensional ℝ E1] [SeminormedAddCommGroup E2] [NormedSpace ℝ E2]
    [FiniteDimensional ℝ E2] (A : E1 →ₗ[ℝ] Module.Dual ℝ E2) :
    E2 →ₗ[ℝ] Module.Dual ℝ E1 :=
  LinearMap.flip A

noncomputable def OperatorNormDef {E1 E2 : Type*} [SeminormedAddCommGroup E1]
    [NormedSpace ℝ E1] [FiniteDimensional ℝ E1] [SeminormedAddCommGroup E2]
    [NormedSpace ℝ E2] [FiniteDimensional ℝ E2]
    (A : E1 →ₗ[ℝ] Module.Dual ℝ E2) : ℝ :=
  sSup { r : ℝ |
    ∃ x : E1, ∃ u : E2, ‖x‖ = 1 ∧ ‖u‖ = 1 ∧ r = DualPairing (A x) u }
