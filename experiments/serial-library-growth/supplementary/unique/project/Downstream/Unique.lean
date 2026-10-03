import ReasLib
import Downstream.Definitions

/-- Scaling a strictly convex real-valued function by a positive constant preserves strict convexity. -/
private lemma strictConvexOn_const_mul {E : Type*} [AddCommGroup E] [Module ℝ E] {s : Set E}
    {c : ℝ} {f : E → ℝ} (hc : 0 < c) (hf : StrictConvexOn ℝ s f) :
    StrictConvexOn ℝ s (fun x ↦ c * f x) := by
  -- Multiply the strict convex-combination inequality by the positive constant.
  refine ⟨hf.1, fun x hx y hy hxy a b ha hb hab ↦ ?_⟩
  have hlt : c * f (a • x + b • y) < c * (a • f x + b • f y) :=
    mul_lt_mul_of_pos_left (hf.2 hx hy hxy ha hb hab) hc
  rw [smul_eq_mul, smul_eq_mul, mul_add, mul_left_comm c a, mul_left_comm c b] at hlt
  rw [smul_eq_mul, smul_eq_mul]
  exact hlt

/-- A continuous real-linear functional is concave on every convex set. -/
private lemma concaveOn_continuousLinearMap {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (l : E →L[ℝ] ℝ) {s : Set E} (hs : Convex ℝ s) : ConcaveOn ℝ s (fun w ↦ l w) := by
  -- Algebraic linear maps are concave, and this continuous map is that underlying map.
  exact l.toLinearMap.concaveOn hs

/-- For positive `μ` and `σ`, `w ↦ l w - f w - μ * g w` is strictly concave on `s` whenever `f`
is convex on `s` and `g` is `σ`-strongly convex on `s`. -/
private lemma strictConcaveOn_sub_sub_strongConvexOn {E : Type*} [NormedAddCommGroup E]
    [NormedSpace ℝ E] {s : Set E} (l : E →L[ℝ] ℝ) {f g : E → ℝ} {μ σ : ℝ} (hμ : 0 < μ)
    (hσ : 0 < σ) (hf : ConvexOn ℝ s f) (hg : StrongConvexOn s σ g) :
    StrictConcaveOn ℝ s (fun w ↦ l w - f w - μ * g w) := by
  -- Subtract the convex summand and the scaled strictly convex penalty from the concave linear term.
  have hlin : ConcaveOn ℝ s (fun w ↦ l w) := concaveOn_continuousLinearMap l hf.1
  have hscaled : StrictConvexOn ℝ s (fun w ↦ μ * g w) :=
    strictConvexOn_const_mul hμ (hg.strictConvexOn hσ)
  exact (hlin.sub hf).sub_strictConvexOn hscaled

/-- `smoothedMaximizer_unique`: the complete original smoothed-maximizer uniqueness statement. -/
lemma smoothedMaximizer_unique {E1 E2 : Type*} [NormedAddCommGroup E1] [NormedSpace ℝ E1]
    [FiniteDimensional ℝ E1] [NormedAddCommGroup E2] [NormedSpace ℝ E2]
    [FiniteDimensional ℝ E2] (Q2 : Set E2) (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ))
    (phihat d2 : E2 → ℝ) (μ σ2 : ℝ) (x : E1) (hμ : 0 < μ) (hσ2 : 0 < σ2)
    (hphi : ConvexOn ℝ Q2 phihat) (hconv : StrongConvexOn Q2 σ2 d2) {u v : E2}
    (hu : IsSmoothedMaximizer Q2 A phihat d2 μ x u)
    (hv : IsSmoothedMaximizer Q2 A phihat d2 μ x v) :
    u = v := by
  -- The normed-space modulus makes the maximand strictly concave, so the two maximizers coincide.
  exact (strictConcaveOn_sub_sub_strongConvexOn (A x) hμ hσ2 hphi hconv).eq_of_isMaxOn
    (isMaxOn_iff.mpr hu.2) (isMaxOn_iff.mpr hv.2) hu.1 hv.1
