module

public import ReasLib.Analysis.Convex.StrongC1
public import Mathlib.Analysis.Calculus.ContDiff.Operations

@[expose] public section

universe u

/-- Nonnegative-curvature `C¹` convexity of a real function on a convex subset of a real normed
space. The domain `Q` is convex, the parameter `μ` satisfies `0 ≤ μ`, and `f` is
`ContDiffOn ℝ 1` within `Q`: this is within-set `C¹`, not continuity of a chosen derivative on an
open neighborhood, not `UniqueDiffOn`, and not whole-space `ContDiff`. The first-order lower bound
uses the ambient norm, with linear term `(fderivWithin ℝ f Q x) (y - x)`. The case `μ = 0` is the
convex `C¹` class, and `0 < μ` recovers `StrongConvexC1On`. -/
structure StrongConvexC1NonnegOn {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] (Q : Set E)
    (μ : ℝ) (f : E → ℝ) : Prop where
  /-- The domain is convex. -/
  convexDomain : Convex ℝ Q
  /-- The curvature parameter is nonnegative. -/
  muNonneg : 0 ≤ μ
  /-- `f` is continuously differentiable within `Q`. -/
  contDiffOn : ContDiffOn ℝ 1 f Q
  /-- First-order quadratic lower bound on `Q`. -/
  lower :
    ∀ x ∈ Q, ∀ y ∈ Q,
      f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y

/-- Build nonnegative `C¹` curvature from convexity of `Q`, nonnegativity of `μ`,
`ContDiffOn ℝ 1` of `f` on `Q`, and the first-order quadratic lower bound. -/
def StrongConvexC1NonnegOn.ofConditions {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {Q : Set E} {μ : ℝ} {f : E → ℝ} (convexDomain : Convex ℝ Q) (muNonneg : 0 ≤ μ)
    (contDiffOn : ContDiffOn ℝ 1 f Q)
    (lower :
      ∀ x ∈ Q, ∀ y ∈ Q,
        f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y) :
    StrongConvexC1NonnegOn Q μ f where
  convexDomain := convexDomain
  muNonneg := muNonneg
  contDiffOn := contDiffOn
  lower := lower

/-- `strongConvexC1NonnegOn_iff`. Nonnegative `C¹` curvature is convexity of `Q`, nonnegativity of `μ`, `ContDiffOn ℝ 1` of `f`
on `Q`, and the first-order quadratic lower bound using `fderivWithin`. -/
theorem strongConvexC1NonnegOn_iff {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (Q : Set E) (μ : ℝ) (f : E → ℝ) :
    StrongConvexC1NonnegOn Q μ f ↔
      Convex ℝ Q ∧ 0 ≤ μ ∧ ContDiffOn ℝ 1 f Q ∧
        ∀ x ∈ Q, ∀ y ∈ Q,
          f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y := by
  constructor
  · intro hf
    -- The structure records exactly these four conjuncts, with no extra nonempty assumption.
    exact ⟨hf.convexDomain, hf.muNonneg, hf.contDiffOn, hf.lower⟩
  · rintro ⟨hQ, hμ, hf, hlower⟩
    -- Repackage the conjuncts; the bounded quantifiers stay vacuous if `Q` is empty.
    exact StrongConvexC1NonnegOn.ofConditions hQ hμ hf hlower

/-- The convex `C¹` class on `Q`: nonnegative `C¹` curvature with parameter `0`. -/
abbrev ConvexC1On {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (Q : Set E) (f : E → ℝ) : Prop :=
  StrongConvexC1NonnegOn Q 0 f

/-- Membership in the convex `C¹` class is convexity of `Q`, `ContDiffOn ℝ 1` of `f` on `Q`, and
the first-order lower bound without a quadratic term. -/
theorem convexC1On_iff {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (Q : Set E) (f : E → ℝ) :
    ConvexC1On Q f ↔
      Convex ℝ Q ∧ ContDiffOn ℝ 1 f Q ∧
        ∀ x ∈ Q, ∀ y ∈ Q,
          f x + (fderivWithin ℝ f Q x) (y - x) ≤ f y := by
  -- Curvature zero is the convex `C¹` class, and its quadratic term vanishes.
  rw [ConvexC1On, strongConvexC1NonnegOn_iff]
  constructor
  · rintro ⟨hQ, _, hf, hlower⟩
    refine ⟨hQ, hf, fun x hx y hy => ?_⟩
    -- At curvature zero the quadratic term is identically zero.
    simpa only [zero_div, zero_mul, add_zero] using hlower x hx y hy
  · rintro ⟨hQ, hf, hlower⟩
    refine ⟨hQ, le_rfl, hf, fun x hx y hy => ?_⟩
    -- Restore the zero quadratic term required by nonnegative curvature.
    simpa only [zero_div, zero_mul, add_zero] using hlower x hx y hy

/-- Positive `C¹` strong convexity is nonnegative `C¹` curvature together with a positive
parameter. -/
theorem strongConvexC1On_iff_nonneg_and_pos {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (Q : Set E) (μ : ℝ) (f : E → ℝ) :
    StrongConvexC1On Q μ f ↔ StrongConvexC1NonnegOn Q μ f ∧ 0 < μ := by
  constructor
  · intro hf
    -- Positivity of `μ` supplies nonnegativity; the remaining fields agree.
    exact ⟨StrongConvexC1NonnegOn.ofConditions hf.convexDomain (le_of_lt hf.muPos) hf.contDiffOn
      hf.lower, hf.muPos⟩
  · rintro ⟨hf, hμ⟩
    exact StrongConvexC1On.ofConditions hf.convexDomain hμ hf.contDiffOn hf.lower

/-- A real linear combination of functions that are `C¹` on two sets is `C¹` on their
intersection. -/
private lemma contDiffOn_linearCombination {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {Q1 Q2 : Set E} {f1 f2 : E → ℝ} {α β : ℝ} (hf1 : ContDiffOn ℝ 1 f1 Q1)
    (hf2 : ContDiffOn ℝ 1 f2 Q2) :
    ContDiffOn ℝ 1 (fun z ↦ α * f1 z + β * f2 z) (Q1 ∩ Q2) := by
  -- Restrict each within-derivative class to the intersection and scale by a constant.
  have hscale1 : ContDiffOn ℝ 1 (fun z ↦ α • f1 z) (Q1 ∩ Q2) :=
    (hf1.mono Set.inter_subset_left).const_smul α
  have hscale2 : ContDiffOn ℝ 1 (fun z ↦ β • f2 z) (Q1 ∩ Q2) :=
    (hf2.mono Set.inter_subset_right).const_smul β
  -- On `ℝ`, scalar multiplication agrees with multiplication.
  refine (hscale1.add hscale2).congr ?_
  intro z _
  simp only [smul_eq_mul]

/-- On a convex set, any two within-derivatives of the same map agree on each feasible direction
`y - x`. -/
private lemma hasFDerivWithinAt_apply_sub_eq_of_convex {E : Type u} {F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E] [NormedAddCommGroup F] [NormedSpace ℝ F]
    {Q : Set E} {f : E → F} {f' g' : E →L[ℝ] F} {x y : E} (hQ : Convex ℝ Q) (hx : x ∈ Q)
    (hy : y ∈ Q) (hf' : HasFDerivWithinAt f f' Q x) (hg' : HasFDerivWithinAt f g' Q x) :
    f' (y - x) = g' (y - x) := by
  -- Convexity keeps the segment from `x` to `y` inside `Q`, so `y - x` is tangent at `x`.
  have hmem : y - x ∈ tangentConeAt ℝ Q x :=
    mem_tangentConeAt_of_segment_subset (hQ.segment_subset hx hy)
  -- Within-derivatives agree on the tangent cone, hence on this single feasible direction.
  exact hf'.unique_on hg' hmem

/-- On a convex intersection, the within-derivative of a real linear combination, applied to a
feasible direction `y - x`, is the same linear combination of the within-derivatives. -/
private lemma fderivWithin_linearCombination_apply_sub {E : Type u} [NormedAddCommGroup E]
    [NormedSpace ℝ E] {Q1 Q2 : Set E} {f1 f2 : E → ℝ} (hQ1 : Convex ℝ Q1) (hQ2 : Convex ℝ Q2)
    (hf1 : ContDiffOn ℝ 1 f1 Q1) (hf2 : ContDiffOn ℝ 1 f2 Q2) (α β : ℝ) {x y : E}
    (hx : x ∈ Q1 ∩ Q2) (hy : y ∈ Q1 ∩ Q2) :
    (fderivWithin ℝ (fun z ↦ α * f1 z + β * f2 z) (Q1 ∩ Q2) x) (y - x) =
      α * (fderivWithin ℝ f1 Q1 x) (y - x) + β * (fderivWithin ℝ f2 Q2 x) (y - x) := by
  -- Canonical within-derivatives on each domain, restricted to the intersection.
  have h1 : HasFDerivWithinAt f1 (fderivWithin ℝ f1 Q1 x) (Q1 ∩ Q2) x :=
    ((hf1.differentiableOn_one x hx.1).hasFDerivWithinAt).mono Set.inter_subset_left
  have h2 : HasFDerivWithinAt f2 (fderivWithin ℝ f2 Q2 x) (Q1 ∩ Q2) x :=
    ((hf2.differentiableOn_one x hx.2).hasFDerivWithinAt).mono Set.inter_subset_right
  -- Scale and add those witnesses. This does not require a unique derivative on all of `E`.
  have hcomb : HasFDerivWithinAt (fun z ↦ α * f1 z + β * f2 z)
      (α • fderivWithin ℝ f1 Q1 x + β • fderivWithin ℝ f2 Q2 x) (Q1 ∩ Q2) x :=
    (h1.const_mul α).add (h2.const_mul β)
  have hcanon : HasFDerivWithinAt (fun z ↦ α * f1 z + β * f2 z)
      (fderivWithin ℝ (fun z ↦ α * f1 z + β * f2 z) (Q1 ∩ Q2) x) (Q1 ∩ Q2) x :=
    ((contDiffOn_linearCombination hf1 hf2).differentiableOn_one x hx).hasFDerivWithinAt
  -- Convexity supplies the tangent direction, so the witnesses agree on `y - x`.
  have hdir :=
    hasFDerivWithinAt_apply_sub_eq_of_convex (hQ1.inter hQ2) hx hy hcanon hcomb
  -- Rewrite continuous-linear scalar actions as multiplication in `ℝ`.
  rw [hdir]
  simp only [ContinuousLinearMap.add_apply, ContinuousLinearMap.smul_apply, smul_eq_mul]

/-- Nonnegative linear combinations preserve nonnegative `C¹` curvature on the intersection.
If `f1` has curvature `μ1` on `Q1` and `f2` has curvature `μ2` on `Q2`, and `0 ≤ α`, `0 ≤ β`,
then `fun x ↦ α * f1 x + β * f2 x` has curvature `α * μ1 + β * μ2` on `Q1 ∩ Q2`. The parameters
and coefficients may be zero. The ambient norm is arbitrary, and the domains may be empty or
lower-dimensional. -/
theorem StrongConvexC1NonnegOn.nonnegCombination {E : Type u} [NormedAddCommGroup E]
    [NormedSpace ℝ E] [FiniteDimensional ℝ E] (Q1 Q2 : Set E) (mu1 mu2 alpha beta : ℝ) (f1 f2 : E → ℝ)
    (hf1 : StrongConvexC1NonnegOn Q1 mu1 f1) (hf2 : StrongConvexC1NonnegOn Q2 mu2 f2)
    (halpha : 0 ≤ alpha) (hbeta : 0 ≤ beta) :
    StrongConvexC1NonnegOn (Q1 ∩ Q2) (alpha * mu1 + beta * mu2)
      (fun x ↦ alpha * f1 x + beta * f2 x) := by
  -- Convexity, nonnegativity, and `C¹` regularity pass to the intersection independently of
  -- whether that intersection is empty or lower-dimensional.
  refine StrongConvexC1NonnegOn.ofConditions (hf1.convexDomain.inter hf2.convexDomain)
    (add_nonneg (mul_nonneg halpha hf1.muNonneg) (mul_nonneg hbeta hf2.muNonneg))
    (contDiffOn_linearCombination hf1.contDiffOn hf2.contDiffOn) ?_
  intro x hx y hy
  -- Scale each first-order lower bound and add them.
  have hsum := add_le_add
    (mul_le_mul_of_nonneg_left (hf1.lower x hx.1 y hy.1) halpha)
    (mul_le_mul_of_nonneg_left (hf2.lower x hx.2 y hy.2) hbeta)
  -- Identify the derivative only along the feasible direction `y - x`, then match quadratics.
  calc
    alpha * f1 x + beta * f2 x
        + (fderivWithin ℝ (fun z ↦ alpha * f1 z + beta * f2 z) (Q1 ∩ Q2) x) (y - x)
        + (alpha * mu1 + beta * mu2) / 2 * ‖y - x‖ ^ 2
      = alpha * f1 x + beta * f2 x
        + (alpha * (fderivWithin ℝ f1 Q1 x) (y - x) + beta * (fderivWithin ℝ f2 Q2 x) (y - x))
        + (alpha * mu1 + beta * mu2) / 2 * ‖y - x‖ ^ 2 := by
          rw [fderivWithin_linearCombination_apply_sub hf1.convexDomain hf2.convexDomain
            hf1.contDiffOn hf2.contDiffOn alpha beta hx hy]
    _ = alpha * (f1 x + (fderivWithin ℝ f1 Q1 x) (y - x) + mu1 / 2 * ‖y - x‖ ^ 2)
        + beta * (f2 x + (fderivWithin ℝ f2 Q2 x) (y - x) + mu2 / 2 * ‖y - x‖ ^ 2) := by
          ring
    _ ≤ alpha * f1 y + beta * f2 y := hsum

/-- If both summands are positively curved in the `C¹` sense, the coefficients are nonnegative,
and `0 < α * μ1 + β * μ2`, then `fun x ↦ α * f1 x + β * f2 x` is positively curved on `Q1 ∩ Q2`.
Positivity of the combined parameter is not part of the nonnegative combination. -/
theorem StrongConvexC1On.nonnegCombination {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [FiniteDimensional ℝ E] (Q1 Q2 : Set E) (μ1 μ2 α β : ℝ) (f1 f2 : E → ℝ)
    (hf1 : StrongConvexC1On Q1 μ1 f1) (hf2 : StrongConvexC1On Q2 μ2 f2) (hα : 0 ≤ α)
    (hβ : 0 ≤ β) (hμ : 0 < α * μ1 + β * μ2) :
    StrongConvexC1On (Q1 ∩ Q2) (α * μ1 + β * μ2)
      (fun x ↦ α * f1 x + β * f2 x) := by
  -- Positive curvature is nonnegative curvature plus a positive parameter.
  rw [strongConvexC1On_iff_nonneg_and_pos] at hf1 hf2 ⊢
  exact ⟨StrongConvexC1NonnegOn.nonnegCombination Q1 Q2 μ1 μ2 α β f1 f2 hf1.1 hf2.1 hα hβ, hμ⟩
