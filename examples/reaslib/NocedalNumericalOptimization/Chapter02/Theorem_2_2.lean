module

public import Mathlib.Analysis.Calculus.LocalExtr.Basic
public import Mathlib.Analysis.InnerProductSpace.PiL2

@[expose] public section

section

variable (n : ℕ)

/- Theorem 2.2 (First-Order Necessary Conditions). The source assumes that `f`
is continuously differentiable on an open neighborhood of `xStar`. In Mathlib's
totalized `fderiv` API, the canonical theorem checked below is stronger: a local
minimum alone implies that the Fréchet derivative at `xStar` vanishes. -/
#check (IsLocalMin.fderiv_eq_zero :
  ∀ {f : EuclideanSpace ℝ (Fin n) → ℝ} {xStar : EuclideanSpace ℝ (Fin n)},
    IsLocalMin f xStar → fderiv ℝ f xStar = 0)

end
