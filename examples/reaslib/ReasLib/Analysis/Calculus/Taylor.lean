module

public import Mathlib.Analysis.Calculus.Taylor
public import Mathlib.MeasureTheory.Integral.IntervalIntegral.ContDiff

@[expose] public section

namespace Taylor

/-- A continuously differentiable real function changes between two ordered
endpoints by its derivative at an intermediate point times their difference. -/
theorem existsMeanValueDeriv (φ : ℝ → ℝ) (α₀ α₁ : ℝ)
    (hφ : ContDiff ℝ 1 φ) (hα : α₀ < α₁) :
    ∃ ξ ∈ Set.Ioo α₀ α₁,
      φ α₁ = φ α₀ + deriv φ ξ * (α₁ - α₀) := by
  -- Apply the scalar mean value theorem with the ordinary derivative.
  have hcontinuous : ContinuousOn φ (Set.Icc α₀ α₁) := hφ.continuous.continuousOn
  have hderiv : ∀ ξ ∈ Set.Ioo α₀ α₁, HasDerivAt φ (deriv φ ξ) ξ := by
    intro ξ _
    exact (hφ.differentiable_one ξ).hasDerivAt
  obtain ⟨ξ, hξ, hslope⟩ :=
    exists_hasDerivAt_eq_slope φ (deriv φ) hα hcontinuous hderiv
  refine ⟨ξ, hξ, ?_⟩
  -- Clear the nonzero interval length and rearrange the slope identity.
  have hlength : α₁ - α₀ ≠ 0 := sub_ne_zero.mpr hα.ne'
  have hslopeProduct : deriv φ ξ * (α₁ - α₀) = φ α₁ - φ α₀ :=
    (eq_div_iff hlength).mp hslope
  rw [hslopeProduct]
  abel

/-- The derivative of a map restricted to an affine real line is its Fréchet
derivative applied to the direction of that line. -/
private lemma hasDerivAt_comp_add_smul {E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (g : E → F) (x p : E) (t : ℝ) (hg : DifferentiableAt ℝ g (x + t • p)) :
    HasDerivAt (fun s : ℝ ↦ g (x + s • p)) (fderiv ℝ g (x + t • p) p) t := by
  -- Differentiate the affine parametrization, then compose it with `g`.
  have haffine : HasDerivAt (fun s : ℝ ↦ x + s • p) p t := by
    simpa using (hasDerivAt_id t).smul_const p |>.const_add x
  simpa only [Function.comp_def] using hg.hasFDerivAt.comp_hasDerivAt t haffine

/-- Restricting a `C¹` map on an open convex set to an enclosed affine segment
gives a `C¹` map on the unit interval. -/
private lemma contDiffOnAddSmulSegment {E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (f : E → F) (D : Set E) (x p : E)
    (hD_open : IsOpen D) (hD_convex : Convex ℝ D)
    (h_contDiff : ContDiffOn ℝ 1 f D) (hx : x ∈ D) (hxp : x + p ∈ D) :
    ContDiffOn ℝ 1 (fun t : ℝ ↦ f (x + t • p)) (Set.Icc 0 1) := by
  intro t ht
  -- Convexity keeps the affine parametrization inside `D`.
  have htD : x + t • p ∈ D := by
    simpa using hD_convex.add_smul_sub_mem hx hxp ht
  have hfAt : ContDiffAt ℝ 1 f (x + t • p) :=
    (h_contDiff _ htD).contDiffAt (hD_open.mem_nhds htD)
  have haffine : ContDiffAt ℝ 1 (fun s : ℝ ↦ x + s • p) t := by
    fun_prop
  -- Compose in the ambient spaces and then restrict to the interval.
  exact (hfAt.comp t haffine).contDiffWithinAt

/-- A continuously differentiable map on an open convex domain changes along
a line segment by the integral of its Fréchet derivative in the segment direction. -/
theorem mapAddEqIntegralFDerivOnConvex {E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F] [CompleteSpace F]
    (f : E → F) (D : Set E) (x p : E)
    (hD_open : IsOpen D) (hD_convex : Convex ℝ D)
    (h_contDiff : ContDiffOn ℝ 1 f D) (hx : x ∈ D) (hxp : x + p ∈ D) :
    f (x + p) = f x +
      ∫ t in (0 : ℝ)..1, fderiv ℝ f (x + t • p) p := by
  -- Apply the interval fundamental theorem to the affine-line pullback.
  have hline : ContDiffOn ℝ 1 (fun t : ℝ ↦ f (x + t • p)) (Set.Icc 0 1) :=
    contDiffOnAddSmulSegment f D x p hD_open hD_convex h_contDiff hx hxp
  have hzeroOne : (0 : ℝ) ≤ 1 := by
    norm_num
  have hfundamental :=
    intervalIntegral.integral_deriv_of_contDiffOn_Icc hline hzeroOne
  have hlineDeriv : Set.EqOn
      (deriv (fun s : ℝ ↦ f (x + s • p)))
      (fun t : ℝ ↦ fderiv ℝ f (x + t • p) p) (Set.uIcc 0 1) := by
    rw [Set.uIcc_of_le hzeroOne]
    intro t ht
    -- Openness turns the domainwise regularity into ambient differentiability.
    have htD : x + t • p ∈ D := by
      simpa using hD_convex.add_smul_sub_mem hx hxp ht
    have hfAt : DifferentiableAt ℝ f (x + t • p) :=
      ((h_contDiff _ htD).contDiffAt (hD_open.mem_nhds htD)).differentiableAt (by norm_num)
    exact (hasDerivAt_comp_add_smul f x p t hfAt).deriv
  have hintegral :
      (∫ t in (0 : ℝ)..1, deriv (fun s : ℝ ↦ f (x + s • p)) t) =
        ∫ t in (0 : ℝ)..1, fderiv ℝ f (x + t • p) p :=
    intervalIntegral.integral_congr hlineDeriv
  -- Rewrite the derivative integral and normalize the two segment endpoints.
  rw [hintegral] at hfundamental
  simp only [one_smul, zero_smul, add_zero] at hfundamental
  rw [hfundamental]
  abel

/-- A continuously differentiable scalar-valued function has a directional
first-order mean-value expansion along every line segment. -/
theorem existsFirstOrder {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (f : E → ℝ) (hf : ContDiff ℝ 1 f) (x p : E) :
    ∃ t ∈ Set.Ioo (0 : ℝ) 1,
      f (x + p) = f x + fderiv ℝ f (x + t • p) p := by
  -- Apply the scalar mean value theorem to the affine-line pullback.
  have hcontinuous : ContinuousOn (fun t : ℝ ↦ f (x + t • p)) (Set.Icc 0 1) := by
    have haffine : Continuous (fun t : ℝ ↦ x + t • p) := by
      fun_prop
    exact (hf.continuous.comp haffine).continuousOn
  have hderiv : ∀ t ∈ Set.Ioo (0 : ℝ) 1,
      HasDerivAt (fun s : ℝ ↦ f (x + s • p))
        (fderiv ℝ f (x + t • p) p) t := by
    intro t _
    exact hasDerivAt_comp_add_smul f x p t (hf.differentiable_one (x + t • p))
  have hzeroOne : (0 : ℝ) < 1 := by
    norm_num
  obtain ⟨t, ht, hslope⟩ := exists_hasDerivAt_eq_slope
    (fun s : ℝ ↦ f (x + s • p))
    (fun s : ℝ ↦ fderiv ℝ f (x + s • p) p) hzeroOne hcontinuous hderiv
  refine ⟨t, ht, ?_⟩
  -- At the endpoints the slope identity is exactly the desired expansion.
  simp only [one_smul, zero_smul, add_zero, sub_zero, div_one] at hslope
  linarith

/-- For a twice continuously differentiable map into a complete normed space,
the change in its Fréchet derivative along a line segment is the interval
integral of its second Fréchet derivative in the segment direction. -/
theorem fderivAddEqIntegral {E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F] [CompleteSpace F]
    (f : E → F) (hf : ContDiff ℝ 2 f) (x p : E) :
    fderiv ℝ f (x + p) = fderiv ℝ f x +
      ∫ t in (0 : ℝ)..1, fderiv ℝ (fderiv ℝ f) (x + t • p) p := by
  -- The derivative map is `C¹`, so its restriction to the line satisfies the FTC.
  have hfderiv : ContDiff ℝ 1 (fderiv ℝ f) := by
    exact (contDiff_succ_iff_fderiv.mp hf).2.2
  have hline : ContDiff ℝ 1 (fun t : ℝ ↦ fderiv ℝ f (x + t • p)) := by
    fun_prop
  have hderiv (t : ℝ) :
      deriv (fun s : ℝ ↦ fderiv ℝ f (x + s • p)) t =
        fderiv ℝ (fderiv ℝ f) (x + t • p) p := by
    exact (hasDerivAt_comp_add_smul (fderiv ℝ f) x p t
      (hfderiv.differentiable_one (x + t • p))).deriv
  have hzeroOne : (0 : ℝ) ≤ 1 := by
    norm_num
  have hfundamental := intervalIntegral.integral_deriv_of_contDiffOn_Icc
    hline.contDiffOn hzeroOne
  -- Rewrite the line derivative pointwise and rearrange the endpoint difference.
  simp_rw [hderiv] at hfundamental
  simp only [one_smul, zero_smul, add_zero] at hfundamental
  rw [hfundamental]
  abel

/-- The first Taylor polynomial of an affine-line pullback consists of its
value and directional derivative at the base point. -/
private lemma taylorWithinEval_comp_add_smul_one {E : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    (f : E → ℝ) (hf : Differentiable ℝ f) (x p : E) :
    taylorWithinEval (fun s : ℝ ↦ f (x + s • p)) 1 (Set.uIcc 0 1) 0 1 =
      f x + fderiv ℝ f x p := by
  -- Identify the within derivative at the left endpoint using uniqueness.
  have hzeroOne : (0 : ℝ) ≤ 1 := by
    norm_num
  have hzeroOneStrict : (0 : ℝ) < 1 := by
    norm_num
  have hzeroMem : (0 : ℝ) ∈ Set.Icc 0 1 := by
    norm_num
  have hunique : UniqueDiffWithinAt ℝ (Set.uIcc (0 : ℝ) 1) 0 := by
    rw [Set.uIcc_of_le hzeroOne]
    exact uniqueDiffOn_Icc hzeroOneStrict 0 hzeroMem
  have hderiv :
      derivWithin (fun s : ℝ ↦ f (x + s • p)) (Set.uIcc 0 1) 0 =
        fderiv ℝ f x p := by
    simpa using
      (hasDerivAt_comp_add_smul f x p 0 (hf (x + (0 : ℝ) • p))).hasDerivWithinAt.derivWithin
        hunique
  -- Expand exactly the order-one Taylor polynomial and use that derivative.
  have hone : (1 : ℕ) = 0 + 1 := by
    norm_num
  rw [hone, taylorWithinEval_succ,
    taylor_within_zero_eval, iteratedDerivWithin_one, hderiv]
  norm_num

/-- The second iterated derivative of an affine-line pullback is the second
Fréchet derivative evaluated twice in the line direction. -/
private lemma iteratedDeriv_two_comp_add_smul {E : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    (f : E → ℝ) (hf : ContDiff ℝ 2 f) (x p : E) (t : ℝ) :
    iteratedDeriv 2 (fun s : ℝ ↦ f (x + s • p)) t =
      (fderiv ℝ (fderiv ℝ f) (x + t • p) p) p := by
  have hfderiv : ContDiff ℝ 1 (fderiv ℝ f) := by
    exact (contDiff_succ_iff_fderiv.mp hf).2.2
  have hfOne : ContDiff ℝ 1 f := by
    apply hf.of_le
    norm_num
  -- First identify the derivative function of the scalar pullback pointwise.
  have hfirst : deriv (fun s : ℝ ↦ f (x + s • p)) =
      fun s : ℝ ↦ fderiv ℝ f (x + s • p) p := by
    funext s
    exact (hasDerivAt_comp_add_smul f x p s (hfOne.differentiable_one _)).deriv
  -- Differentiate the CLM-valued pullback and then evaluate it at the fixed vector `p`.
  have hsecond : HasDerivAt (fun s : ℝ ↦ fderiv ℝ f (x + s • p) p)
      ((fderiv ℝ (fderiv ℝ f) (x + t • p) p) p) t := by
    have hclm := hasDerivAt_comp_add_smul (fderiv ℝ f) x p t
      (hfderiv.differentiable_one (x + t • p))
    simpa using hclm.clm_apply (hasDerivAt_const t p)
  have htwo : (2 : ℕ) = 1 + 1 := by
    norm_num
  rw [htwo, iteratedDeriv_succ, iteratedDeriv_one, hfirst]
  exact hsecond.deriv

/-- A twice continuously differentiable scalar-valued function has a
second-order directional Taylor expansion with a Lagrange remainder at an
intermediate point of every line segment. -/
theorem existsSecondOrder {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (f : E → ℝ) (hf : ContDiff ℝ 2 f) (x p : E) :
    ∃ t ∈ Set.Ioo (0 : ℝ) 1,
      f (x + p) = f x + fderiv ℝ f x p +
        (fderiv ℝ (fderiv ℝ f) (x + t • p) p) p / 2 := by
  -- Apply one-dimensional Taylor's theorem to the affine-line pullback.
  have hline : ContDiff ℝ 2 (fun s : ℝ ↦ f (x + s • p)) := by
    fun_prop
  have hzeroOneNe : (0 : ℝ) ≠ 1 := by
    norm_num
  obtain ⟨t, ht, hremainder⟩ := taylor_mean_remainder_lagrange_iteratedDeriv
    (f := fun s : ℝ ↦ f (x + s • p)) (x := 1) (x₀ := 0) (n := 1)
    hzeroOneNe hline.contDiffOn
  refine ⟨t, ?_, ?_⟩
  · -- The unordered open interval is the usual interval because `0 < 1`.
    have hzeroOne : (0 : ℝ) ≤ 1 := by
      norm_num
    simpa [Set.uIoo_of_le hzeroOne] using ht
  · -- Consume only the two affine-line interface lemmas and normalize constants.
    have hfOne : ContDiff ℝ 1 f := by
      apply hf.of_le
      norm_num
    rw [taylorWithinEval_comp_add_smul_one f hfOne.differentiable_one x p,
      iteratedDeriv_two_comp_add_smul f hf x p t] at hremainder
    norm_num at hremainder ⊢
    linarith

end Taylor
