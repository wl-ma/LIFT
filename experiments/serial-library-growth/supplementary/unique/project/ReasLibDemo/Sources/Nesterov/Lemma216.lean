module

public import ReasLib.Analysis.Convex.StrongC1Nonneg

universe u

/-Nesterov Lemma216. In a finite-dimensional real vector space with a fixed arbitrary norm, let
`Q1` and `Q2` be convex domains. If `f1` lies in `StrongConvexC1NonnegOn Q1 μ1 f1` and `f2` lies
in `StrongConvexC1NonnegOn Q2 μ2 f2`, then for every `α ≥ 0` and `β ≥ 0` the combination
`fun x ↦ α * f1 x + β * f2 x` lies in
`StrongConvexC1NonnegOn (Q1 ∩ Q2) (α * μ1 + β * μ2)`. Continuous differentiability is
`ContDiffOn ℝ 1` within the named domain. The linear term is `fderivWithin` on the named domain
applied to `y - x`. Parameter `0` is included, so the cases `α = β = 0`, `μ1 = 0`, and `μ2 = 0`
remain. The domains may be empty or lower-dimensional and need not be open, equal to `Set.univ`,
or have nonempty intersection.-/
#check (StrongConvexC1NonnegOn.nonnegCombination :
  ∀ {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    (Q1 Q2 : Set E) (μ1 μ2 α β : ℝ) (f1 f2 : E → ℝ),
    StrongConvexC1NonnegOn Q1 μ1 f1 → StrongConvexC1NonnegOn Q2 μ2 f2 → 0 ≤ α → 0 ≤ β →
      StrongConvexC1NonnegOn (Q1 ∩ Q2) (α * μ1 + β * μ2)
        (fun x ↦ α * f1 x + β * f2 x))

@[expose] public section

/-- `StrongConvexC1On.combination`. If both summands are positively curved in the `C¹` sense and the combined parameter
`alpha * mu1 + beta * mu2` is positive, then the same nonnegative combination is positively curved
on `Q1 ∩ Q2`. The strict positivity of the combined parameter is extra and is not required for the
general nonnegative combination. -/
theorem StrongConvexC1On.combination
    {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    (Q1 Q2 : Set E) (mu1 mu2 alpha beta : ℝ) (f1 f2 : E → ℝ)
    (hf1 : StrongConvexC1On Q1 mu1 f1) (hf2 : StrongConvexC1On Q2 mu2 f2)
    (halpha : 0 ≤ alpha) (hbeta : 0 ≤ beta) (hmu : 0 < alpha * mu1 + beta * mu2) :
    StrongConvexC1On (Q1 ∩ Q2) (alpha * mu1 + beta * mu2)
      (fun x ↦ alpha * f1 x + beta * f2 x) := by
  -- Positive curvature is the shared nonnegative combination together with the
  -- hypothesis that the combined parameter is positive.
  exact StrongConvexC1On.nonnegCombination Q1 Q2 mu1 mu2 alpha beta f1 f2 hf1 hf2 halpha hbeta hmu
