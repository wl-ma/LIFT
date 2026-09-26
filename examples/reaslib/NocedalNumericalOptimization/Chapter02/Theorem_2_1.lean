module

public import ReasLib.Analysis.Calculus.Taylor

@[expose] public section

section

variable (n : ℕ)

/- Theorem 2.1 (1). The first-order directional mean-value identity. -/
#check (Taylor.existsFirstOrder (E := EuclideanSpace ℝ (Fin n)) :
  ∀ (f : EuclideanSpace ℝ (Fin n) → ℝ), ContDiff ℝ 1 f →
    ∀ (x p : EuclideanSpace ℝ (Fin n)),
      ∃ t ∈ Set.Ioo (0 : ℝ) 1,
        f (x + p) = f x + fderiv ℝ f (x + t • p) p)

/- Theorem 2.1 (2). The derivative-valued integral identity. -/
#check (Taylor.fderivAddEqIntegral
    (E := EuclideanSpace ℝ (Fin n)) (F := ℝ) :
  ∀ (f : EuclideanSpace ℝ (Fin n) → ℝ), ContDiff ℝ 2 f →
    ∀ (x p : EuclideanSpace ℝ (Fin n)),
      fderiv ℝ f (x + p) = fderiv ℝ f x +
        ∫ t in (0 : ℝ)..1, fderiv ℝ (fderiv ℝ f) (x + t • p) p)

/- Theorem 2.1 (3). The second-order directional Lagrange remainder. -/
#check (Taylor.existsSecondOrder (E := EuclideanSpace ℝ (Fin n)) :
  ∀ (f : EuclideanSpace ℝ (Fin n) → ℝ), ContDiff ℝ 2 f →
    ∀ (x p : EuclideanSpace ℝ (Fin n)),
      ∃ t ∈ Set.Ioo (0 : ℝ) 1,
        f (x + p) = f x + fderiv ℝ f x p +
          (fderiv ℝ (fderiv ℝ f) (x + t • p) p) p / 2)

end
