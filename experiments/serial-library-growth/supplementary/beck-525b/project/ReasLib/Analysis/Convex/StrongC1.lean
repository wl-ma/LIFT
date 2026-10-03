module

public import Mathlib.Analysis.Convex.Basic
public import Mathlib.Analysis.Convex.Strong
public import Mathlib.Analysis.Calculus.ContDiff.Defs
public import Mathlib.Analysis.Calculus.FDeriv.Basic
public import Mathlib.Analysis.Calculus.FDeriv.Defs
public import Mathlib.Analysis.Calculus.Deriv.MeanValue
public import Mathlib.Analysis.Calculus.Deriv.Pow
public import Mathlib.LinearAlgebra.FiniteDimensional.Defs
public import Mathlib.Topology.Order.DenselyOrdered

@[expose] public section

universe u

open Filter
open scoped Topology

/-- `μ`-strong convexity, in the continuously differentiable sense, of a real function on a convex
subset of a real normed space. The domain `Q` is convex, the parameter `μ` is positive, and `f` is
`ContDiffOn ℝ 1` within `Q`: this is within-set `C¹`, not continuity of a chosen derivative on an
open neighborhood, not `UniqueDiffOn`, and not whole-space `ContDiff`. The first-order lower bound
uses the ambient norm, with linear term `(fderivWithin ℝ f Q x) (y - x)`. -/
structure StrongConvexC1On {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] (Q : Set E)
    (μ : ℝ) (f : E → ℝ) : Prop where
  /-- The domain is convex. -/
  convexDomain : Convex ℝ Q
  /-- The strong-convexity parameter is positive. -/
  muPos : 0 < μ
  /-- `f` is continuously differentiable within `Q`. -/
  contDiffOn : ContDiffOn ℝ 1 f Q
  /-- First-order quadratic lower bound on `Q`. -/
  lower :
    ∀ x ∈ Q, ∀ y ∈ Q,
      f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y

/-- Build `μ`-strong convexity in the `C¹` sense from convexity of `Q`, positivity of `μ`,
`ContDiffOn ℝ 1` of `f` on `Q`, and the first-order quadratic lower bound. -/
def StrongConvexC1On.ofConditions {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {Q : Set E} {μ : ℝ} {f : E → ℝ} (convexDomain : Convex ℝ Q) (muPos : 0 < μ)
    (contDiffOn : ContDiffOn ℝ 1 f Q)
    (lower :
      ∀ x ∈ Q, ∀ y ∈ Q,
        f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y) :
    StrongConvexC1On Q μ f where
  convexDomain := convexDomain
  muPos := muPos
  contDiffOn := contDiffOn
  lower := lower

/-- `strongConvexC1On_iff`. `μ`-strong convexity in the `C¹` sense is convexity of `Q`, positivity of `μ`,
`ContDiffOn ℝ 1` of `f` on `Q`, and the first-order quadratic lower bound using `fderivWithin`. -/
theorem strongConvexC1On_iff {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] (Q : Set E)
    (μ : ℝ) (f : E → ℝ) :
    StrongConvexC1On Q μ f ↔
      Convex ℝ Q ∧ 0 < μ ∧ ContDiffOn ℝ 1 f Q ∧
        ∀ x ∈ Q, ∀ y ∈ Q,
          f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y := by
  constructor
  · intro hf
    -- The structure records exactly these four conjuncts, with no extra nonempty assumption.
    exact ⟨hf.convexDomain, hf.muPos, hf.contDiffOn, hf.lower⟩
  · rintro ⟨hQ, hμ, hf, hlower⟩
    -- Repackage the conjuncts; the bounded quantifiers stay vacuous if `Q` is empty.
    exact StrongConvexC1On.ofConditions hQ hμ hf hlower

/-- On a convex set, any two derivatives within the set agree on each feasible direction `y - x`
with `x, y` in the set. -/
private lemma HasFDerivWithinAt.apply_sub_eq_of_convex {E : Type u} {F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E] [NormedAddCommGroup F] [NormedSpace ℝ F]
    {Q : Set E} {f : E → F} {f' g' : E →L[ℝ] F} {x y : E} (hQ : Convex ℝ Q) (hx : x ∈ Q)
    (hy : y ∈ Q) (hf' : HasFDerivWithinAt f f' Q x) (hg' : HasFDerivWithinAt f g' Q x) :
    f' (y - x) = g' (y - x) := by
  -- Convexity keeps the segment from `x` to `y` inside `Q`, so `y - x` is tangent at `x`.
  have hmem : y - x ∈ tangentConeAt ℝ Q x :=
    mem_tangentConeAt_of_segment_subset (hQ.segment_subset hx hy)
  -- Within-derivatives agree on the tangent cone, hence on this single feasible direction.
  exact hf'.unique_on hg' hmem

/-- The first-order quadratic lower bound holds for any `HasFDerivWithinAt` witness at `x`, not
only the chosen `fderivWithin`. -/
theorem StrongConvexC1On.le_of_hasFDerivWithinAt {E : Type u} [NormedAddCommGroup E]
    [NormedSpace ℝ E] {Q : Set E} {μ : ℝ} {f : E → ℝ} (hf : StrongConvexC1On Q μ f) {x y : E}
    (hx : x ∈ Q) (hy : y ∈ Q) {f' : E →L[ℝ] ℝ} (hf' : HasFDerivWithinAt f f' Q x) :
    f x + f' (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y := by
  -- `C¹` within `Q` supplies the canonical within-derivative at `x`.
  have hcanon : HasFDerivWithinAt f (fderivWithin ℝ f Q x) Q x :=
    (hf.contDiffOn.differentiableOn_one x hx).hasFDerivWithinAt
  -- Replace the arbitrary witness by that derivative on the feasible direction `y - x`.
  rw [HasFDerivWithinAt.apply_sub_eq_of_convex hf.convexDomain hx hy hf' hcanon]
  exact hf.lower x hx y hy

/-- `μ`-strong convexity in the `C¹` sense depends on the function only through its values on
`Q`. -/
theorem StrongConvexC1On.congr {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] {Q : Set E}
    {μ : ℝ} {f g : E → ℝ} (hf : StrongConvexC1On Q μ f) (hfg : Set.EqOn f g Q) :
    StrongConvexC1On Q μ g := by
  -- Equality on `Q` leaves convexity and `μ` unchanged and transports the analytic data.
  refine StrongConvexC1On.ofConditions hf.convexDomain hf.muPos ?_ ?_
  · -- `ContDiffOn.congr` expects the new function on the left of the pointwise equality.
    exact hf.contDiffOn.congr fun z hz ↦ (hfg hz).symm
  · intro x hx y hy
    -- Values and `fderivWithin` of `g` agree with those of `f` at points of `Q`.
    rw [hfg.symm hx, hfg.symm hy, fderivWithin_congr' hfg.symm hx]
    exact hf.lower x hx y hy

/-- A `C¹` strongly convex function is differentiable within `Q`. -/
theorem StrongConvexC1On.differentiableOn {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {Q : Set E} {μ : ℝ} {f : E → ℝ} (hf : StrongConvexC1On Q μ f) : DifferentiableOn ℝ f Q := by
  -- Order-one continuous differentiability within `Q` specializes to differentiability on `Q`.
  exact hf.contDiffOn.differentiableOn_one

/-- On a finite-dimensional real normed space, `C¹` `μ`-strong convexity is convexity of `Q`,
positivity of `μ`, `ContDiffOn ℝ 1 f Q`, and the displayed `fderivWithin` lower bound.
Finite-dimensionality is ambient rather than a basis hypothesis. -/
theorem strongConvexC1On_iff_of_finiteDimensional {E : Type u} [NormedAddCommGroup E]
    [NormedSpace ℝ E] [FiniteDimensional ℝ E] (Q : Set E) (μ : ℝ) (f : E → ℝ) :
    StrongConvexC1On Q μ f ↔
      Convex ℝ Q ∧ 0 < μ ∧ ContDiffOn ℝ 1 f Q ∧
        ∀ x ∈ Q, ∀ y ∈ Q,
          f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y := by
  -- Finite-dimensionality is not used; the equivalence is the general one.
  exact strongConvexC1On_iff Q μ f

/-- The within-derivative of `f` along `AffineMap.lineMap x y`, at an interior parameter,
is `fderivWithin` applied to the direction `y - x`. -/
private lemma hasDerivAt_comp_lineMap {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {Q : Set E} {f : E → ℝ} (hQ : Convex ℝ Q) (hf : DifferentiableOn ℝ f Q) {x y : E}
    (hx : x ∈ Q) (hy : y ∈ Q) {t : ℝ} (ht : t ∈ Set.Ioo (0 : ℝ) 1) :
    HasDerivAt (fun s ↦ f (AffineMap.lineMap x y s))
      ((fderivWithin ℝ f Q (AffineMap.lineMap x y t)) (y - x)) t := by
  -- The open segment parameter lies in the closed segment, hence in the convex domain.
  have htI : t ∈ Set.Icc (0 : ℝ) 1 := Set.Ioo_subset_Icc_self ht
  have hz : AffineMap.lineMap x y t ∈ Q := hQ.lineMap_mem hx hy htI
  have hf' : HasFDerivWithinAt f (fderivWithin ℝ f Q (AffineMap.lineMap x y t)) Q
      (AffineMap.lineMap x y t) :=
    (hf _ hz).hasFDerivWithinAt
  -- A neighborhood of `t` stays inside the segment, so the chain rule applies within `Q`.
  have hmem : ∀ᶠ s in nhds t, AffineMap.lineMap x y s ∈ Q := by
    filter_upwards [Icc_mem_nhds ht.1 ht.2] with s hs
    exact hQ.lineMap_mem hx hy hs
  exact hf'.comp_hasDerivAt t AffineMap.hasDerivAt_lineMap hmem

/-- A first-order quadratic lower bound implies `μ`-monotonicity of `fderivWithin` on feasible
directions `x - y`. -/
private lemma le_sub_fderivWithin_of_lower {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {Q : Set E} {μ : ℝ} {f : E → ℝ}
    (hlower : ∀ x ∈ Q, ∀ y ∈ Q,
      f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y) :
    ∀ x ∈ Q, ∀ y ∈ Q,
      μ * ‖x - y‖ ^ 2 ≤
        (fderivWithin ℝ f Q x) (x - y) - (fderivWithin ℝ f Q y) (x - y) := by
  intro x hx y hy
  -- Add the lower bounds at `(x, y)` and `(y, x)`, then reverse the direction `y - x`.
  have hxy := hlower x hx y hy
  have hyx := hlower y hy x hx
  have hnorm : ‖y - x‖ ^ 2 = ‖x - y‖ ^ 2 := by rw [norm_sub_rev]
  have hneg : (fderivWithin ℝ f Q x) (y - x) = -((fderivWithin ℝ f Q x) (x - y)) := by
    rw [← neg_sub, map_neg]
  rw [hnorm, hneg] at hxy
  linarith

/-- A first-order quadratic lower bound implies the quadratic convex-combination inequality, with
weight `α` on the first endpoint. -/
private lemma convexCombo_quadratic_of_lower {E : Type u} [NormedAddCommGroup E]
    [NormedSpace ℝ E] {Q : Set E} {μ : ℝ} {f : E → ℝ} (hQ : Convex ℝ Q)
    (hlower : ∀ x ∈ Q, ∀ y ∈ Q,
      f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y) :
    ∀ x ∈ Q, ∀ y ∈ Q, ∀ α : ℝ, α ∈ Set.Icc (0 : ℝ) 1 →
      f (α • x + (1 - α) • y) + α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 ≤
        α * f x + (1 - α) * f y := by
  intro x hx y hy α hα
  have h1α : 0 ≤ 1 - α := sub_nonneg.mpr hα.2
  have hadd : α + (1 - α) = 1 := by ring
  -- Convexity keeps the combination inside `Q`; the endpoint increments are scalar multiples.
  set z := α • x + (1 - α) • y with hzdef
  have hz : z ∈ Q := by
    rw [hzdef]
    exact hQ hx hy hα.1 h1α hadd
  have hxcoef : x - α • x = (1 - α) • x := by
    conv_lhs =>
      arg 1
      rw [← one_smul ℝ x]
    exact (sub_smul 1 α x).symm
  have hycoef : y - (1 - α) • y = α • y := by
    conv_lhs =>
      arg 1
      rw [← one_smul ℝ y]
    exact (sub_smul 1 (1 - α) y).symm.trans
      (congrArg (fun coeff : ℝ ↦ coeff • y) (sub_sub_self 1 α))
  have hxz : x - z = (1 - α) • (x - y) := by
    rw [hzdef, sub_add_eq_sub_sub, hxcoef, smul_sub]
  have hyz : y - z = -(α • (x - y)) := by
    rw [hzdef, sub_add_eq_sub_sub, sub_right_comm, hycoef, smul_sub, neg_sub]
  have hnx : ‖x - z‖ ^ 2 = (1 - α) ^ 2 * ‖x - y‖ ^ 2 := by
    rw [hxz, norm_smul, Real.norm_eq_abs, abs_of_nonneg h1α, mul_pow]
  have hny : ‖y - z‖ ^ 2 = α ^ 2 * ‖x - y‖ ^ 2 := by
    rw [hyz, norm_neg, norm_smul, Real.norm_eq_abs, abs_of_nonneg hα.1, mul_pow]
  have hcancel : α * (fderivWithin ℝ f Q z) (x - z) +
      (1 - α) * (fderivWithin ℝ f Q z) (y - z) = 0 := by
    rw [hxz, hyz, map_smul, map_neg, map_smul, smul_eq_mul, smul_eq_mul]
    ring
  have hquad : α * (μ / 2 * ‖x - z‖ ^ 2) + (1 - α) * (μ / 2 * ‖y - z‖ ^ 2) =
      α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 := by
    rw [hnx, hny]
    ring
  -- Scale the lower bounds by the convex weights and add; the linear terms cancel.
  have hxbound : α * f z + α * (fderivWithin ℝ f Q z) (x - z) +
      α * (μ / 2 * ‖x - z‖ ^ 2) ≤ α * f x := by
    have hmul := mul_le_mul_of_nonneg_left (hlower z hz x hx) hα.1
    have hdist : α * (f z + (fderivWithin ℝ f Q z) (x - z) + μ / 2 * ‖x - z‖ ^ 2) =
        α * f z + α * (fderivWithin ℝ f Q z) (x - z) + α * (μ / 2 * ‖x - z‖ ^ 2) := by
      ring
    rw [← hdist]
    exact hmul
  have hybound : (1 - α) * f z + (1 - α) * (fderivWithin ℝ f Q z) (y - z) +
      (1 - α) * (μ / 2 * ‖y - z‖ ^ 2) ≤ (1 - α) * f y := by
    have hmul := mul_le_mul_of_nonneg_left (hlower z hz y hy) h1α
    have hdist : (1 - α) * (f z + (fderivWithin ℝ f Q z) (y - z) + μ / 2 * ‖y - z‖ ^ 2) =
        (1 - α) * f z + (1 - α) * (fderivWithin ℝ f Q z) (y - z) +
          (1 - α) * (μ / 2 * ‖y - z‖ ^ 2) := by
      ring
    rw [← hdist]
    exact hmul
  have hsum : f z + α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 ≤ α * f x + (1 - α) * f y := by
    have hjoined : f z +
        (α * (fderivWithin ℝ f Q z) (x - z) + (1 - α) * (fderivWithin ℝ f Q z) (y - z)) +
        (α * (μ / 2 * ‖x - z‖ ^ 2) + (1 - α) * (μ / 2 * ‖y - z‖ ^ 2)) ≤
        α * f x + (1 - α) * f y := by
      linarith
    rw [hcancel, hquad] at hjoined
    linarith
  simpa [hzdef] using hsum

/-- `μ`-monotonicity of `fderivWithin` lower-bounds the directional derivative along an interior
segment parameter by the base derivative plus the quadratic increment. -/
private lemma segmentDeriv_ge_of_fderivMono {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {Q : Set E} {μ : ℝ} {f : E → ℝ} (hQ : Convex ℝ Q)
    (hmono : ∀ x ∈ Q, ∀ y ∈ Q,
      μ * ‖x - y‖ ^ 2 ≤
        (fderivWithin ℝ f Q x) (x - y) - (fderivWithin ℝ f Q y) (x - y))
    {x y : E} (hx : x ∈ Q) (hy : y ∈ Q) {t : ℝ} (ht : t ∈ Set.Ioo (0 : ℝ) 1) :
    (fderivWithin ℝ f Q x) (y - x) + μ * t * ‖y - x‖ ^ 2 ≤
      (fderivWithin ℝ f Q (AffineMap.lineMap x y t)) (y - x) := by
  have htI : t ∈ Set.Icc (0 : ℝ) 1 := Set.Ioo_subset_Icc_self ht
  have hz : AffineMap.lineMap x y t ∈ Q := hQ.lineMap_mem hx hy htI
  have hzx : AffineMap.lineMap x y t - x = t • (y - x) := by
    rw [AffineMap.lineMap_apply_module']
    exact add_sub_cancel_right _ _
  have hmono_zx := hmono _ hz x hx
  rw [hzx] at hmono_zx
  have hnorm : ‖t • (y - x)‖ ^ 2 = t ^ 2 * ‖y - x‖ ^ 2 := by
    rw [norm_smul, Real.norm_eq_abs, abs_of_pos ht.1, mul_pow]
  have hmapz : (fderivWithin ℝ f Q (AffineMap.lineMap x y t)) (t • (y - x)) =
      t * (fderivWithin ℝ f Q (AffineMap.lineMap x y t)) (y - x) := by
    rw [map_smul, smul_eq_mul]
  have hmapx : (fderivWithin ℝ f Q x) (t • (y - x)) =
      t * (fderivWithin ℝ f Q x) (y - x) := by
    rw [map_smul, smul_eq_mul]
  rw [hnorm, hmapz, hmapx] at hmono_zx
  -- Cancel the positive factor `t` from the scaled monotonicity inequality.
  have hscaled : t * (μ * t * ‖y - x‖ ^ 2) ≤
      t * ((fderivWithin ℝ f Q (AffineMap.lineMap x y t)) (y - x) -
        (fderivWithin ℝ f Q x) (y - x)) := by
    have hrewrite : μ * (t ^ 2 * ‖y - x‖ ^ 2) = t * (μ * t * ‖y - x‖ ^ 2) := by ring
    have hdiff : t * (fderivWithin ℝ f Q (AffineMap.lineMap x y t)) (y - x) -
        t * (fderivWithin ℝ f Q x) (y - x) =
        t * ((fderivWithin ℝ f Q (AffineMap.lineMap x y t)) (y - x) -
          (fderivWithin ℝ f Q x) (y - x)) := by ring
    rw [← hrewrite, ← hdiff]
    exact hmono_zx
  have hdiv := (mul_le_mul_iff_of_pos_left ht.1).mp hscaled
  linarith

/-- `μ`-monotonicity of `fderivWithin` on a convex set implies the first-order quadratic lower
bound. -/
private lemma lower_of_fderivWithin_mono {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {Q : Set E} {μ : ℝ} {f : E → ℝ} (hQ : Convex ℝ Q) (hf : DifferentiableOn ℝ f Q)
    (hmono : ∀ x ∈ Q, ∀ y ∈ Q,
      μ * ‖x - y‖ ^ 2 ≤
        (fderivWithin ℝ f Q x) (x - y) - (fderivWithin ℝ f Q y) (x - y)) :
    ∀ x ∈ Q, ∀ y ∈ Q,
      f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y := by
  intro x hx y hy
  -- Compare `f` along the segment with the quadratic deficit based at `x`.
  set g : ℝ → ℝ := fun t ↦ f (AffineMap.lineMap x y t) with hg
  set c : ℝ := (fderivWithin ℝ f Q x) (y - x) with hc
  set k : ℝ := μ / 2 * ‖y - x‖ ^ 2 with hk
  set deficit : ℝ → ℝ := fun t ↦ g t - c * t - k * t ^ 2 with hdeficit
  set deficit' : ℝ → ℝ := fun t ↦
    (fderivWithin ℝ f Q (AffineMap.lineMap x y t)) (y - x) - c - μ * t * ‖y - x‖ ^ 2
    with hdeficit'
  have hgcont : ContinuousOn g (Set.Icc (0 : ℝ) 1) := by
    have hline : Continuous fun t : ℝ ↦ AffineMap.lineMap x y t :=
      continuous_iff_continuousAt.mpr fun _ ↦ AffineMap.hasDerivAt_lineMap.continuousAt
    exact hf.continuousOn.comp hline.continuousOn (hQ.mapsTo_lineMap hx hy)
  have hcont : ContinuousOn deficit (Set.Icc (0 : ℝ) 1) := by
    have hlin : ContinuousOn (fun t : ℝ ↦ c * t) (Set.Icc (0 : ℝ) 1) :=
      (continuous_const.mul continuous_id).continuousOn
    have hsq : ContinuousOn (fun t : ℝ ↦ k * t ^ 2) (Set.Icc (0 : ℝ) 1) :=
      (continuous_const.mul (continuous_id.pow 2)).continuousOn
    exact (hgcont.sub hlin).sub hsq
  have hderiv : ∀ t ∈ interior (Set.Icc (0 : ℝ) 1),
      HasDerivWithinAt deficit (deficit' t) (interior (Set.Icc (0 : ℝ) 1)) t := by
    intro t ht
    have htIoo : t ∈ Set.Ioo (0 : ℝ) 1 := by rwa [interior_Icc] at ht
    have hgderiv : HasDerivAt g
        ((fderivWithin ℝ f Q (AffineMap.lineMap x y t)) (y - x)) t := by
      simpa [hg] using hasDerivAt_comp_lineMap hQ hf hx hy htIoo
    have hct : HasDerivAt (fun s : ℝ ↦ c * s) c t := by
      simpa using (hasDerivAt_id t).const_mul c
    have hkt : HasDerivAt (fun s : ℝ ↦ k * s ^ 2) (k * ((2 : ℝ) * t)) t := by
      have hpow : HasDerivAt (fun s : ℝ ↦ s ^ 2) ((2 : ℝ) * t) t := by
        simpa using hasDerivAt_pow 2 t
      simpa using hpow.const_mul k
    have hraw : HasDerivAt deficit
        ((fderivWithin ℝ f Q (AffineMap.lineMap x y t)) (y - x) - c -
          k * ((2 : ℝ) * t)) t := by
      simpa [hdeficit] using (hgderiv.sub hct).sub hkt
    have hcoeff : k * ((2 : ℝ) * t) = μ * t * ‖y - x‖ ^ 2 := by
      rw [hk]
      ring
    have hderiv_eq : (fderivWithin ℝ f Q (AffineMap.lineMap x y t)) (y - x) - c -
        k * ((2 : ℝ) * t) = deficit' t := by
      rw [hdeficit', hcoeff]
    exact (hraw.congr_deriv hderiv_eq).hasDerivWithinAt
  have hnonneg : ∀ t ∈ interior (Set.Icc (0 : ℝ) 1), 0 ≤ deficit' t := by
    intro t ht
    have htIoo : t ∈ Set.Ioo (0 : ℝ) 1 := by rwa [interior_Icc] at ht
    have hge := segmentDeriv_ge_of_fderivMono hQ hmono hx hy htIoo
    rw [hdeficit', hc]
    linarith
  -- A nonnegative interior derivative makes the deficit monotone on the closed segment.
  have hmon : MonotoneOn deficit (Set.Icc (0 : ℝ) 1) :=
    monotoneOn_of_hasDerivWithinAt_nonneg (convex_Icc (0 : ℝ) 1) hcont hderiv hnonneg
  have hle : deficit 0 ≤ deficit 1 :=
    hmon (Set.left_mem_Icc.mpr zero_le_one) (Set.right_mem_Icc.mpr zero_le_one) zero_le_one
  have h0 : deficit 0 = f x := by
    simp [hdeficit, hg, AffineMap.lineMap_apply_zero]
  have h1 : deficit 1 = f y - c - k := by
    simp [hdeficit, hg, AffineMap.lineMap_apply_one]
  have hbound : f x ≤ f y - c - k := by simpa [h0, h1] using hle
  rw [hc, hk] at hbound
  linarith

/-- On `(0, 1)`, a quadratic convex-combination inequality bounds the right difference quotient
based at the second endpoint. -/
private lemma slope_le_of_convexCombo {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {Q : Set E} {μ : ℝ} {f : E → ℝ}
    (hcombo : ∀ x ∈ Q, ∀ y ∈ Q, ∀ α : ℝ, α ∈ Set.Icc (0 : ℝ) 1 →
      f (α • x + (1 - α) • y) + α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 ≤
        α * f x + (1 - α) * f y)
    {x y : E} (hx : x ∈ Q) (hy : y ∈ Q) {t : ℝ} (ht : t ∈ Set.Ioo (0 : ℝ) 1) :
    (f (AffineMap.lineMap x y t) - f x) / t + (1 - t) * (μ / 2 * ‖y - x‖ ^ 2) ≤
      f y - f x := by
  have htI : t ∈ Set.Icc (0 : ℝ) 1 := Set.Ioo_subset_Icc_self ht
  -- Put weight `t` on `y`, so the combination is the segment starting at `x`.
  have hineq := hcombo y hy x hx t htI
  have hline : AffineMap.lineMap x y t = t • y + (1 - t) • x := by
    rw [AffineMap.lineMap_apply_module, add_comm]
  have hassoc : t * (1 - t) * (μ / 2) * ‖y - x‖ ^ 2 =
      t * ((1 - t) * (μ / 2 * ‖y - x‖ ^ 2)) := by ring
  rw [hline]
  have hdiv : (f (t • y + (1 - t) • x) - f x) / t ≤
      f y - f x - (1 - t) * (μ / 2 * ‖y - x‖ ^ 2) := by
    rw [div_le_iff₀' ht.1]
    linarith
  linarith

/-- A quadratic convex-combination inequality on a convex set, together with differentiability,
implies the first-order quadratic lower bound. -/
private lemma lower_of_convexCombo {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {Q : Set E} {μ : ℝ} {f : E → ℝ} (hQ : Convex ℝ Q) (hf : DifferentiableOn ℝ f Q)
    (hcombo : ∀ x ∈ Q, ∀ y ∈ Q, ∀ α : ℝ, α ∈ Set.Icc (0 : ℝ) 1 →
      f (α • x + (1 - α) • y) + α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 ≤
        α * f x + (1 - α) * f y) :
    ∀ x ∈ Q, ∀ y ∈ Q,
      f x + (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y := by
  intro x hx y hy
  have hcanon : HasFDerivWithinAt f (fderivWithin ℝ f Q x) Q x :=
    (hf x hx).hasFDerivWithinAt
  -- The rescaled segment increment tends to `y - x` and stays in `Q` for small positive steps.
  have hid : Tendsto (fun t : ℝ ↦ t) (𝓝[>] 0) (nhds 0) :=
    tendsto_id.mono_left (nhdsWithin_le_nhds : 𝓝[>] (0 : ℝ) ≤ nhds 0)
  have hdlim : Tendsto (fun t : ℝ ↦ t • (y - x)) (𝓝[>] 0) (nhds 0) := by
    simpa using hid.smul_const (y - x)
  have hmem : ∀ᶠ t in 𝓝[>] (0 : ℝ), x + t • (y - x) ∈ Q := by
    filter_upwards [Ioo_mem_nhdsGT zero_lt_one] with t ht
    exact hQ.add_smul_sub_mem hx hy (Set.Ioo_subset_Icc_self ht)
  have hcdlim : Tendsto (fun t : ℝ ↦ t⁻¹ • (t • (y - x))) (𝓝[>] 0) (nhds (y - x)) := by
    refine tendsto_const_nhds.congr' ?_
    filter_upwards [self_mem_nhdsWithin] with t ht
    have ht0 : t ≠ 0 := ne_of_gt ht
    simp [smul_smul, inv_mul_cancel₀ ht0, one_smul]
  have hslope : Tendsto (fun t : ℝ ↦ t⁻¹ • (f (x + t • (y - x)) - f x)) (𝓝[>] 0)
      (nhds ((fderivWithin ℝ f Q x) (y - x))) :=
    hcanon.lim hdlim hmem hcdlim
  have hslope' : Tendsto (fun t : ℝ ↦ (f (AffineMap.lineMap x y t) - f x) / t) (𝓝[>] 0)
      (nhds ((fderivWithin ℝ f Q x) (y - x))) := by
    refine hslope.congr' ?_
    filter_upwards with t
    simp [AffineMap.lineMap_apply_module', add_comm, smul_eq_mul, div_eq_inv_mul]
  have hquad : Tendsto (fun t : ℝ ↦ (1 - t) * (μ / 2 * ‖y - x‖ ^ 2)) (𝓝[>] 0)
      (nhds (μ / 2 * ‖y - x‖ ^ 2)) := by
    have hsub : Tendsto (fun t : ℝ ↦ 1 - t) (𝓝[>] 0) (nhds 1) := by
      simpa using tendsto_const_nhds.sub hid
    simpa using Filter.Tendsto.mul_const (μ / 2 * ‖y - x‖ ^ 2) hsub
  -- Pass to the limit in the rearranged segment inequality.
  have hsum := hslope'.add hquad
  have hineq : ∀ᶠ t in 𝓝[>] (0 : ℝ),
      (f (AffineMap.lineMap x y t) - f x) / t + (1 - t) * (μ / 2 * ‖y - x‖ ^ 2) ≤
        f y - f x := by
    filter_upwards [Ioo_mem_nhdsGT zero_lt_one] with t ht
    exact slope_le_of_convexCombo hcombo hx hy ht
  have hlim : (fderivWithin ℝ f Q x) (y - x) + μ / 2 * ‖y - x‖ ^ 2 ≤ f y - f x :=
    le_of_tendsto hsum hineq
  linarith

/-- `StrongConvexC1On.iff_fderivMono_convexCombo`. On a finite-dimensional real normed space, if `Q` is convex, `μ` is positive, and `f` is
`ContDiffOn ℝ 1` on `Q`, then `C¹` `μ`-strong convexity of `f` on `Q` is equivalent to
monotonicity of `fderivWithin ℝ f Q` with modulus `μ` together with the quadratic
convex-combination inequality along segments of `Q`. The norm is the ambient norm. `Q` may be
empty and need not be open or the whole space. -/
theorem StrongConvexC1On.iff_fderivMono_convexCombo {E : Type u} [NormedAddCommGroup E]
    [NormedSpace ℝ E] [FiniteDimensional ℝ E] (Q : Set E) (μ : ℝ) (f : E → ℝ)
    (hQ : Convex ℝ Q) (hμ : 0 < μ) (hf : ContDiffOn ℝ 1 f Q) :
    StrongConvexC1On Q μ f ↔
      (∀ x ∈ Q, ∀ y ∈ Q,
        μ * ‖x - y‖ ^ 2 ≤
          (fderivWithin ℝ f Q x) (x - y) - (fderivWithin ℝ f Q y) (x - y)) ∧
        (∀ x ∈ Q, ∀ y ∈ Q, ∀ α : ℝ, α ∈ Set.Icc 0 1 →
          f (α • x + (1 - α) • y) + α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 ≤
            α * f x + (1 - α) * f y) := by
  constructor
  · intro hsc
    -- The defining lower bound produces both monotonicity and the segment inequality.
    exact ⟨le_sub_fderivWithin_of_lower hsc.lower,
      convexCombo_quadratic_of_lower hQ hsc.lower⟩
  · rintro ⟨hmono, _⟩
    -- Monotonicity restores the lower bound, so the recorded hypotheses reassemble.
    exact StrongConvexC1On.ofConditions hQ hμ hf
      (lower_of_fderivWithin_mono hQ hf.differentiableOn_one hmono)

/-- On a finite-dimensional real normed space, if `Q` is convex, `μ` is positive, and `f` is
`ContDiffOn ℝ 1` on `Q`, then `C¹` `μ`-strong convexity of `f` on `Q` is equivalent to
monotonicity of `fderivWithin ℝ f Q` with modulus `μ`: for all `x, y ∈ Q`,
`μ * ‖x - y‖ ^ 2 ≤ (fderivWithin ℝ f Q x) (x - y) - (fderivWithin ℝ f Q y) (x - y)`.
The pairing is `fderivWithin` on the direction `x - y` for the ambient norm. `Q` may be empty
and need not be open or the whole space. -/
theorem StrongConvexC1On.iff_fderivMono {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [FiniteDimensional ℝ E] (Q : Set E) (μ : ℝ) (f : E → ℝ) (hQ : Convex ℝ Q) (hμ : 0 < μ)
    (hf : ContDiffOn ℝ 1 f Q) :
    StrongConvexC1On Q μ f ↔
      ∀ x ∈ Q, ∀ y ∈ Q,
        μ * ‖x - y‖ ^ 2 ≤
          (fderivWithin ℝ f Q x) (x - y) - (fderivWithin ℝ f Q y) (x - y) := by
  constructor
  · intro hsc
    -- Project the quadratic lower bound onto feasible directions.
    exact le_sub_fderivWithin_of_lower hsc.lower
  · intro hmono
    -- Integrate the monotone derivative of the segment deficit back to the lower bound.
    exact StrongConvexC1On.ofConditions hQ hμ hf
      (lower_of_fderivWithin_mono hQ hf.differentiableOn_one hmono)

/-- On a finite-dimensional real normed space, if `Q` is convex, `μ` is positive, and `f` is
`ContDiffOn ℝ 1` on `Q`, then `C¹` `μ`-strong convexity of `f` on `Q` is equivalent to the
quadratic convex-combination inequality: for all `x, y ∈ Q` and all `α ∈ Set.Icc (0 : ℝ) 1`,
`f (α • x + (1 - α) • y) + α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 ≤ α * f x + (1 - α) * f y`.
The weight `α` is on `x`. `Q` may be empty and need not be open or the whole space. -/
theorem StrongConvexC1On.iff_convexCombo {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [FiniteDimensional ℝ E] (Q : Set E) (μ : ℝ) (f : E → ℝ) (hQ : Convex ℝ Q) (hμ : 0 < μ)
    (hf : ContDiffOn ℝ 1 f Q) :
    StrongConvexC1On Q μ f ↔
      ∀ x ∈ Q, ∀ y ∈ Q, ∀ α : ℝ, α ∈ Set.Icc 0 1 →
        f (α • x + (1 - α) • y) + α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 ≤
          α * f x + (1 - α) * f y := by
  constructor
  · intro hsc
    -- Expand the lower bound at the convex combination and cancel the linear terms.
    exact convexCombo_quadratic_of_lower hQ hsc.lower
  · intro hcombo
    -- Differentiate the segment inequality from the right at the endpoint.
    exact StrongConvexC1On.ofConditions hQ hμ hf
      (lower_of_convexCombo hQ hf.differentiableOn_one hcombo)

/-- On a real normed space, `StrongConvexOn Q μ f` holds if and only if `Q` is convex and, for all
`x, y ∈ Q` and all `α ∈ Set.Icc (0 : ℝ) 1`,
`f (α • x + (1 - α) • y) + α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 ≤ α * f x + (1 - α) * f y`.
No finite-dimensionality, continuous differentiability, or positivity of `μ` is assumed. -/
theorem strongConvexOn_iff_segment {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (Q : Set E) (μ : ℝ) (f : E → ℝ) :
    StrongConvexOn Q μ f ↔
      Convex ℝ Q ∧
        ∀ x ∈ Q, ∀ y ∈ Q, ∀ α : ℝ, α ∈ Set.Icc 0 1 →
          f (α • x + (1 - α) • y) + α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 ≤
            α * f x + (1 - α) * f y := by
  rw [StrongConvexOn, UniformConvexOn]
  constructor
  · rintro ⟨hQ, hseg⟩
    refine ⟨hQ, ?_⟩
    intro x hx y hy α hα
    -- Specialize the two-weight form to weights `α` and `1 - α`.
    have h1α : 0 ≤ 1 - α := sub_nonneg.mpr hα.2
    have hadd : α + (1 - α) = 1 := by ring
    have hineq := hseg hx hy hα.1 h1α hadd
    rw [smul_eq_mul, smul_eq_mul] at hineq
    have hmul : α * (1 - α) * (μ / 2 * ‖x - y‖ ^ 2) =
        α * (1 - α) * (μ / 2) * ‖x - y‖ ^ 2 := by ring
    linarith
  · rintro ⟨hQ, hseg⟩
    refine ⟨hQ, ?_⟩
    intro x hx y hy a b ha hb hab
    -- Recover the second weight from `a + b = 1` and return to the segment form.
    have hb_eq : b = 1 - a := eq_sub_of_add_eq' hab
    subst hb_eq
    have haI : a ∈ Set.Icc (0 : ℝ) 1 := ⟨ha, sub_nonneg.mp hb⟩
    have hineq := hseg x hx y hy a haI
    rw [smul_eq_mul, smul_eq_mul]
    have hmul : a * (1 - a) * (μ / 2) * ‖x - y‖ ^ 2 =
        a * (1 - a) * (μ / 2 * ‖x - y‖ ^ 2) := by ring
    linarith

/-- On a finite-dimensional real normed space, if `Q` is convex, `μ` is positive, and `f` is
`ContDiffOn ℝ 1` on `Q`, then `C¹` `μ`-strong convexity of `f` on `Q` is equivalent to
`StrongConvexOn Q μ f`. The ambient norm is arbitrary. `Q` may be empty and need not be open
or the whole space. -/
theorem StrongConvexC1On.iff_strongConvexOn {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [FiniteDimensional ℝ E] (Q : Set E) (μ : ℝ) (f : E → ℝ) (hQ : Convex ℝ Q) (hμ : 0 < μ)
    (hf : ContDiffOn ℝ 1 f Q) :
    StrongConvexC1On Q μ f ↔ StrongConvexOn Q μ f := by
  constructor
  · intro hsc
    -- The C¹ segment inequality is the segment form of strong convexity.
    exact (strongConvexOn_iff_segment Q μ f).2
      ⟨hQ, (StrongConvexC1On.iff_convexCombo Q μ f hQ hμ hf).1 hsc⟩
  · intro hsc
    -- Strong convexity supplies that same segment inequality.
    exact (StrongConvexC1On.iff_convexCombo Q μ f hQ hμ hf).2
      ((strongConvexOn_iff_segment Q μ f).1 hsc).2

/-- `StrongConvexC1On.le_of_fderiv_eq_zero`. On a finite-dimensional real normed space, if `f` is `μ`-strongly convex in the `C¹` sense on
the whole space and `fderiv ℝ f xStar = 0`, then for every `x`,
`f xStar + μ / 2 * ‖x - xStar‖ ^ 2 ≤ f x`. -/
theorem StrongConvexC1On.le_of_fderiv_eq_zero {E : Type u} [NormedAddCommGroup E]
    [NormedSpace ℝ E] [FiniteDimensional ℝ E] {μ : ℝ} {f : E → ℝ}
    (hf : StrongConvexC1On Set.univ μ f) {xStar : E} (hderiv : fderiv ℝ f xStar = 0) :
    ∀ x : E, f xStar + μ / 2 * ‖x - xStar‖ ^ 2 ≤ f x := by
  intro x
  -- On `Set.univ` the quadratic lower bound is the claimed inequality once the linear term vanishes.
  -- `fderivWithin` agrees with `fderiv`, and that derivative is the zero map at `xStar`.
  simpa [fderivWithin_univ, hderiv] using
    hf.lower xStar (Set.mem_univ xStar) x (Set.mem_univ x)
