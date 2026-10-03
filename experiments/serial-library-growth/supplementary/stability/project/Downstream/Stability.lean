import ReasLib
import Downstream.Definitions

/-- The supremum of a continuous bilinear pairing on the product of the two unit spheres. -/
private noncomputable def spherePairingSup {E1 E2 : Type*} [NormedAddCommGroup E1]
    [NormedSpace ℝ E1] [NormedAddCommGroup E2] [NormedSpace ℝ E2]
    (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ)) : ℝ :=
  sSup {r : ℝ | ∃ x : E1, ∃ u : E2, ‖x‖ = 1 ∧ ‖u‖ = 1 ∧ r = A x u}

/-- Unit-sphere pairings of a continuous bilinear map are bounded above by its operator norm. -/
private lemma bddAbove_spherePairing {E1 E2 : Type*} [NormedAddCommGroup E1] [NormedSpace ℝ E1]
    [NormedAddCommGroup E2] [NormedSpace ℝ E2] (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ)) :
    BddAbove {r : ℝ | ∃ x : E1, ∃ u : E2, ‖x‖ = 1 ∧ ‖u‖ = 1 ∧ r = A x u} := by
  -- Operator continuity supplies an upper bound without compactness or attainment.
  refine ⟨‖A‖, ?_⟩
  intro r hr
  rcases hr with ⟨x, u, hx, hu, rfl⟩
  have habs : A x u ≤ ‖A x u‖ := by
    rw [Real.norm_eq_abs]
    exact le_abs_self _
  have hop : ‖A x u‖ ≤ ‖A‖ * ‖x‖ * ‖u‖ := ContinuousLinearMap.le_opNorm₂ A x u
  have hunit : ‖A‖ * ‖x‖ * ‖u‖ = ‖A‖ := by
    rw [hx, hu, mul_one, mul_one]
  linarith

/-- The unit-sphere pairing set is symmetric, so its supremum is nonnegative. -/
private lemma spherePairingSup_nonneg {E1 E2 : Type*} [NormedAddCommGroup E1] [NormedSpace ℝ E1]
    [NormedAddCommGroup E2] [NormedSpace ℝ E2] (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ)) :
    0 ≤ spherePairingSup A := by
  unfold spherePairingSup
  set S := {r : ℝ | ∃ x : E1, ∃ u : E2, ‖x‖ = 1 ∧ ‖u‖ = 1 ∧ r = A x u}
  by_cases hS : S = ∅
  · -- An empty real supremum is zero.
    rw [hS, Real.sSup_empty]
  · obtain ⟨r, hr⟩ := Set.nonempty_iff_ne_empty.mpr hS
    rcases hr with ⟨x, u, hx, hu, rfl⟩
    -- Replacing `u` by `-u` stays on the unit sphere and negates the pairing.
    have hneg : -(A x u) ∈ S := by
      refine ⟨x, -u, hx, ?_, ?_⟩
      · simpa using hu
      · simp
    have hrle : A x u ≤ sSup S :=
      le_csSup (bddAbove_spherePairing A) ⟨x, u, hx, hu, rfl⟩
    have hnle : -(A x u) ≤ sSup S := le_csSup (bddAbove_spherePairing A) hneg
    linarith

/-- A continuous bilinear pairing is bounded by the unit-sphere supremum times the two norms. -/
private lemma le_spherePairingSup {E1 E2 : Type*} [NormedAddCommGroup E1] [NormedSpace ℝ E1]
    [NormedAddCommGroup E2] [NormedSpace ℝ E2] (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ)) (x : E1) (u : E2) :
    A x u ≤ spherePairingSup A * ‖x‖ * ‖u‖ := by
  by_cases hx : x = 0
  · -- A vanishing first argument kills both sides.
    rw [hx, map_zero, ContinuousLinearMap.zero_apply, norm_zero, mul_zero, zero_mul]
  · by_cases hu : u = 0
    · rw [hu, map_zero, norm_zero, mul_zero]
    · -- Scale both nonzero vectors onto the unit spheres.
      have hx0 : ‖x‖ ≠ 0 := norm_ne_zero_iff.mpr hx
      have hu0 : ‖u‖ ≠ 0 := norm_ne_zero_iff.mpr hu
      set x₁ : E1 := ‖x‖⁻¹ • x
      set u₁ : E2 := ‖u‖⁻¹ • u
      have hx₁ : ‖x₁‖ = 1 := by
        unfold x₁
        rw [norm_smul, Real.norm_of_nonneg (inv_nonneg.mpr (norm_nonneg x)), inv_mul_cancel₀ hx0]
      have hu₁ : ‖u₁‖ = 1 := by
        unfold u₁
        rw [norm_smul, Real.norm_of_nonneg (inv_nonneg.mpr (norm_nonneg u)), inv_mul_cancel₀ hu0]
      have hxrepr : ‖x‖ • x₁ = x := by
        unfold x₁
        rw [smul_smul, mul_inv_cancel₀ hx0, one_smul]
      have hurepr : ‖u‖ • u₁ = u := by
        unfold u₁
        rw [smul_smul, mul_inv_cancel₀ hu0, one_smul]
      have hscale : A x u = ‖x‖ * ‖u‖ * A x₁ u₁ := by
        -- Rewrite only the paired vectors, not the scalar norms on the right.
        conv_lhs =>
          rw [← hxrepr, map_smul, ContinuousLinearMap.smul_apply, ← hurepr, map_smul]
          simp only [smul_eq_mul]
        ring
      have hunit : A x₁ u₁ ≤ spherePairingSup A := by
        have hmem :
            A x₁ u₁ ∈ {r : ℝ | ∃ x : E1, ∃ u : E2, ‖x‖ = 1 ∧ ‖u‖ = 1 ∧ r = A x u} :=
          ⟨x₁, u₁, hx₁, hu₁, rfl⟩
        simpa [spherePairingSup] using le_csSup (bddAbove_spherePairing A) hmem
      have hmul : ‖x‖ * ‖u‖ * A x₁ u₁ ≤ ‖x‖ * ‖u‖ * spherePairingSup A :=
        mul_le_mul_of_nonneg_left hunit (mul_nonneg (norm_nonneg x) (norm_nonneg u))
      have hcomm : ‖x‖ * ‖u‖ * spherePairingSup A = spherePairingSup A * ‖x‖ * ‖u‖ := by
        ring
      rw [hscale, ← hcomm]
      exact hmul

/-- Multiplication by a nonnegative constant scales the strong-convexity modulus. -/
private lemma StrongConvexOn.smul {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {s : Set E} {c m : ℝ} {f : E → ℝ} (hc : 0 ≤ c) (hf : StrongConvexOn s m f) :
    StrongConvexOn s (c * m) (fun x ↦ c * f x) := by
  rw [strongConvexOn_iff_segment] at hf ⊢
  refine ⟨hf.1, ?_⟩
  intro x hx y hy α hα
  -- Multiply the segment inequality by the nonnegative constant.
  have hineq := hf.2 x hx y hy α hα
  have hmul := mul_le_mul_of_nonneg_left hineq hc
  have hrew :
      c * (f (α • x + (1 - α) • y) + α * (1 - α) * (m / 2) * ‖x - y‖ ^ 2) =
        c * f (α • x + (1 - α) • y) +
          α * (1 - α) * ((c * m) / 2) * ‖x - y‖ ^ 2 := by
    ring
  have hrhs : c * (α * f x + (1 - α) * f y) = α * (c * f x) + (1 - α) * (c * f y) := by
    ring
  rw [hrew, hrhs] at hmul
  simpa using hmul

/-- The sum of strongly convex functions is strongly convex for the sum of the moduli. -/
private lemma StrongConvexOn.add {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {s : Set E} {m n : ℝ} {f g : E → ℝ} (hf : StrongConvexOn s m f)
    (hg : StrongConvexOn s n g) : StrongConvexOn s (m + n) (fun x ↦ f x + g x) := by
  rw [strongConvexOn_iff_segment] at hf hg ⊢
  refine ⟨hf.1, ?_⟩
  intro x hx y hy α hα
  have hf' := hf.2 x hx y hy α hα
  have hg' := hg.2 x hx y hy α hα
  have hadd := add_le_add hf' hg'
  -- Add the quadratic defects and combine the values pointwise.
  suffices
      f (α • x + (1 - α) • y) + g (α • x + (1 - α) • y) +
          α * (1 - α) * ((m + n) / 2) * ‖x - y‖ ^ 2 ≤
        α * (f x + g x) + (1 - α) * (f y + g y) by
    simpa using this
  calc
    f (α • x + (1 - α) • y) + g (α • x + (1 - α) • y) +
        α * (1 - α) * ((m + n) / 2) * ‖x - y‖ ^ 2 =
        (f (α • x + (1 - α) • y) + α * (1 - α) * (m / 2) * ‖x - y‖ ^ 2) +
          (g (α • x + (1 - α) • y) + α * (1 - α) * (n / 2) * ‖x - y‖ ^ 2) := by
      ring
    _ ≤ (α * f x + (1 - α) * f y) + (α * g x + (1 - α) * g y) := hadd
    _ = α * (f x + g x) + (1 - α) * (f y + g y) := by
      ring

/-- Subtracting a continuous linear functional does not change the strong-convexity modulus. -/
private lemma StrongConvexOn.sub_continuousLinearMap {E : Type*} [NormedAddCommGroup E]
    [NormedSpace ℝ E] {s : Set E} {m : ℝ} {f : E → ℝ} (hf : StrongConvexOn s m f)
    (ℓ : E →L[ℝ] ℝ) : StrongConvexOn s m (fun v ↦ f v - ℓ v) := by
  rw [strongConvexOn_iff_segment] at hf ⊢
  refine ⟨hf.1, ?_⟩
  intro x hx y hy α hα
  have hineq := hf.2 x hx y hy α hα
  -- The linear term agrees on both sides of the segment inequality.
  have hlin : ℓ (α • x + (1 - α) • y) = α * ℓ x + (1 - α) * ℓ y := by
    rw [map_add, map_smul, map_smul, smul_eq_mul, smul_eq_mul]
  have hrew :
      f (α • x + (1 - α) • y) - ℓ (α • x + (1 - α) • y) +
          α * (1 - α) * (m / 2) * ‖x - y‖ ^ 2 =
        (f (α • x + (1 - α) • y) + α * (1 - α) * (m / 2) * ‖x - y‖ ^ 2) -
          (α * ℓ x + (1 - α) * ℓ y) := by
    rw [hlin]
    ring
  have hrhs :
      α * (f x - ℓ x) + (1 - α) * (f y - ℓ y) =
        α * f x + (1 - α) * f y - (α * ℓ x + (1 - α) * ℓ y) := by
    ring
  rw [hrew, hrhs]
  linarith

/-- A minimizer of a strongly convex function has quadratic growth of modulus `m / 2`. -/
private lemma StrongConvexOn.le_of_isMinOn {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {s : Set E} {m : ℝ} {f : E → ℝ} (hf : StrongConvexOn s m f) (hm : 0 ≤ m) {x : E}
    (hx : x ∈ s) (hmin : IsMinOn f s x) {y : E} (hy : y ∈ s) :
    f x + m / 2 * ‖y - x‖ ^ 2 ≤ f y := by
  have hdata := (strongConvexOn_iff_segment s m f).1 hf
  have hs : Convex ℝ s := hdata.1
  have hseg := hdata.2
  rw [isMinOn_iff] at hmin
  set N := ‖y - x‖ ^ 2
  have hN : 0 ≤ N := sq_nonneg _
  have hstep : ∀ t : ℝ, 0 < t → t ≤ 1 → f x + (1 - t) * (m / 2) * N ≤ f y := by
    intro t ht0 ht1
    -- Compare the minimizer with the point dividing the segment in the ratio `t`.
    have h1t : 0 ≤ 1 - t := sub_nonneg.mpr ht1
    have hadd : (1 - t) + t = 1 := by
      ring
    have hz : (1 - t) • x + t • y ∈ s :=
      (convex_iff_add_mem.mp hs) hx hy h1t ht0.le hadd
    have hα1 : 1 - t ≤ 1 := by
      linarith
    have hcomb := hseg x hx y hy (1 - t) ⟨h1t, hα1⟩
    have ht' : 1 - (1 - t) = t := by
      ring
    have hnorm : ‖x - y‖ ^ 2 = N := by
      rw [norm_sub_rev]
    rw [ht', hnorm] at hcomb
    have hminz : f x ≤ f ((1 - t) • x + t • y) := hmin _ hz
    have hweighted : f x + (1 - t) * t * (m / 2) * N ≤ (1 - t) * f x + t * f y := by
      linarith
    have hfactor :
        t * (f x + (1 - t) * (m / 2) * N) =
          t * f x + (1 - t) * t * (m / 2) * N := by
      ring
    have hscaled : t * (f x + (1 - t) * (m / 2) * N) ≤ t * f y := by
      rw [hfactor]
      linarith
    exact (mul_le_mul_iff_of_pos_left ht0).1 hscaled
  -- Send the segment weight to zero, keeping the sharp factor `m / 2`.
  refine le_of_forall_sub_le fun ε hε => ?_
  set c := m / 2 * N
  have hc : 0 ≤ c := mul_nonneg (div_nonneg hm zero_le_two) hN
  by_cases hc0 : c = 0
  · have hendpoint := hstep 1 one_pos le_rfl
    have hzero : (1 - 1) * (m / 2) * N = c := by
      rw [hc0]
      ring
    rw [hzero] at hendpoint
    linarith
  · have hcpos : 0 < c := lt_of_le_of_ne hc (Ne.symm hc0)
    set t := min (1 : ℝ) (ε / c)
    have ht0 : 0 < t := lt_min one_pos (div_pos hε hcpos)
    have ht1 : t ≤ 1 := min_le_left _ _
    have htc : t * c ≤ ε := by
      have hle : t ≤ ε / c := min_le_right _ _
      have hmul := mul_le_mul_of_nonneg_right hle hcpos.le
      rw [div_mul_cancel₀ _ (ne_of_gt hcpos)] at hmul
      exact hmul
    have hnear := hstep t ht0 ht1
    have hshift : f x + (c - t * c) ≤ f y := by
      have hcoeff : (1 - t) * (m / 2) * N = c - t * c := by
        ring
      rwa [hcoeff] at hnear
    linarith

/-- Minimizers of a fixed strongly convex function minus a varying linear pairing are Lipschitz. -/
private lemma norm_sub_le_spherePairingSup_of_isMinOn {E1 E2 : Type*} [NormedAddCommGroup E1]
    [NormedSpace ℝ E1] [NormedAddCommGroup E2] [NormedSpace ℝ E2] {Q : Set E2} {m : ℝ}
    {f : E2 → ℝ} (hm : 0 < m) (hf : StrongConvexOn Q m f)
    (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ)) {u : E1 → E2}
    (hu : ∀ x, u x ∈ Q ∧ IsMinOn (fun v ↦ f v - A x v) Q (u x)) (x y : E1) :
    ‖u x - u y‖ ≤ (spherePairingSup A / m) * ‖x - y‖ := by
  obtain ⟨hxQ, hxMin⟩ := hu x
  obtain ⟨hyQ, hyMin⟩ := hu y
  -- Each perturbed objective keeps modulus `m`, so both minimizers have quadratic growth.
  have hxGrowth :=
    (hf.sub_continuousLinearMap (A x)).le_of_isMinOn hm.le hxQ hxMin hyQ
  have hyGrowth :=
    (hf.sub_continuousLinearMap (A y)).le_of_isMinOn hm.le hyQ hyMin hxQ
  set d := ‖u x - u y‖ with hd
  have hrev : ‖u y - u x‖ = d := by
    rw [norm_sub_rev, hd]
  rw [hrev] at hxGrowth
  have hadd := add_le_add hxGrowth hyGrowth
  have hrew :
      (f (u x) - A x (u x) + m / 2 * d ^ 2) + (f (u y) - A y (u y) + m / 2 * d ^ 2) =
        f (u x) + f (u y) - A x (u x) - A y (u y) + m * d ^ 2 := by
    ring
  have hrhs :
      (f (u y) - A x (u y)) + (f (u x) - A y (u x)) =
        f (u x) + f (u y) - A x (u y) - A y (u x) := by
    ring
  rw [hrew, hrhs] at hadd
  have hcancel : m * d ^ 2 ≤ (A x (u x) - A x (u y)) + (A y (u y) - A y (u x)) := by
    linarith
  have hAx : A x (u x) - A x (u y) = A x (u x - u y) := by
    rw [map_sub]
  have hAy : A y (u y) - A y (u x) = -A y (u x - u y) := by
    rw [← map_sub, ← neg_sub (u x) (u y), map_neg]
  have hpairEq :
      A x (u x - u y) + -A y (u x - u y) = A (x - y) (u x - u y) := by
    rw [← sub_eq_add_neg, ← ContinuousLinearMap.sub_apply, ← map_sub A x y]
  rw [hAx, hAy, hpairEq] at hcancel
  have hbound : A (x - y) (u x - u y) ≤ spherePairingSup A * ‖x - y‖ * d := by
    simpa [hd] using le_spherePairingSup A (x - y) (u x - u y)
  have hsq : m * d ^ 2 ≤ spherePairingSup A * ‖x - y‖ * d := le_trans hcancel hbound
  by_cases hd0 : d = 0
  · -- Equal minimizers give a trivial Lipschitz estimate once the supremum is nonnegative.
    rw [hd0]
    exact mul_nonneg (div_nonneg (spherePairingSup_nonneg A) hm.le) (norm_nonneg _)
  · have hdpos : 0 < d := lt_of_le_of_ne (norm_nonneg _) (Ne.symm hd0)
    have hmul : m * d * d ≤ spherePairingSup A * ‖x - y‖ * d := by
      rw [mul_assoc, ← pow_two]
      exact hsq
    have hlin : m * d ≤ spherePairingSup A * ‖x - y‖ := le_of_mul_le_mul_right hmul hdpos
    have hdiv : d ≤ spherePairingSup A * ‖x - y‖ / m := by
      rw [le_div_iff₀ hm]
      simpa [mul_comm] using hlin
    have hform : spherePairingSup A / m * ‖x - y‖ = spherePairingSup A * ‖x - y‖ / m := by
      ring
    rw [hform]
    exact hdiv

/-- `OperatorNormDef` agrees with the unit-sphere pairing supremum when the pairings agree. -/
private lemma operatorNormDef_eq_spherePairingSup {E1 E2 : Type*} [NormedAddCommGroup E1]
    [NormedSpace ℝ E1] [FiniteDimensional ℝ E1] [NormedAddCommGroup E2] [NormedSpace ℝ E2]
    [FiniteDimensional ℝ E2] (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ)) (T : E1 →ₗ[ℝ] Module.Dual ℝ E2)
    (hTU : ∀ x u, T x u = A x u) : OperatorNormDef T = spherePairingSup A := by
  -- Pointwise agreement of the pairings identifies the two supremum sets.
  unfold OperatorNormDef spherePairingSup
  congr 1
  ext r
  constructor
  · rintro ⟨x, u, hx, hu, hr⟩
    refine ⟨x, u, hx, hu, ?_⟩
    rw [hr, DualPairing]
    exact hTU x u
  · rintro ⟨x, u, hx, hu, hr⟩
    refine ⟨x, u, hx, hu, ?_⟩
    rw [hr, DualPairing]
    exact (hTU x u).symm

/-- smoothedMaximizer_lipschitz_of_isSmoothedMaximizer: if `d2` is `σ2`-strongly convex on `Q2`,
`phihat` is convex on `Q2`, and `uμ x` is a smoothed maximizer of
`v ↦ A x v - phihat v - μ * d2 v`, then `uμ` is Lipschitz with constant
`OperatorNormDef A' / (μ * σ2)`. -/
lemma smoothedMaximizer_lipschitz_of_isSmoothedMaximizer {E1 E2 : Type*}
    [NormedAddCommGroup E1] [NormedSpace ℝ E1] [FiniteDimensional ℝ E1]
    [NormedAddCommGroup E2] [NormedSpace ℝ E2] [FiniteDimensional ℝ E2]
    (Q2 : Set E2) (A : E1 →L[ℝ] (E2 →L[ℝ] ℝ)) (phihat d2 : E2 → ℝ)
    (μ σ2 : ℝ) (hμ : 0 < μ) (hσ2 : 0 < σ2) (hconv : StrongConvexOn Q2 σ2 d2)
    (hphi : ConvexOn ℝ Q2 phihat) (uμ : E1 → E2)
    (hmax : ∀ x, IsSmoothedMaximizer Q2 A phihat d2 μ x (uμ x)) :
    let A' : E1 →ₗ[ℝ] Module.Dual ℝ E2 :=
      { toFun := fun x => (A x).toLinearMap
        map_add' := by
          intro x y
          ext u
          simp
        map_smul' := by
          intro c x
          ext u
          simp }
    ∃ Kμ : ℝ,
      Kμ = (OperatorNormDef A') / (μ * σ2) ∧
        LipschitzWith (Real.toNNReal Kμ) uμ := by
  -- Name the let-bound dual-valued operator without changing its construction.
  extract_lets A'
  have hm : 0 < μ * σ2 := mul_pos hμ hσ2
  have hμ0 : 0 ≤ μ := hμ.le
  have hf : StrongConvexOn Q2 (μ * σ2) (fun v ↦ phihat v + μ * d2 v) := by
    -- Scale `d2`, view `phihat` as `0`-strongly convex, and add the moduli.
    have hd : StrongConvexOn Q2 (μ * σ2) (fun v ↦ μ * d2 v) := hconv.smul hμ0
    have hp : StrongConvexOn Q2 0 phihat := strongConvexOn_zero.2 hphi
    simpa [zero_add] using hp.add hd
  have hmin :
      ∀ x, uμ x ∈ Q2 ∧
        IsMinOn (fun v ↦ phihat v + μ * d2 v - A x v) Q2 (uμ x) := by
    intro x
    obtain ⟨hxmem, hxle⟩ := hmax x
    refine ⟨hxmem, ?_⟩
    rw [isMinOn_iff]
    intro v hv
    -- Negate the smoothed maximizer inequality to obtain a minimization inequality.
    have hvle := hxle v hv
    linarith
  have hdist :
      ∀ x y, ‖uμ x - uμ y‖ ≤ (spherePairingSup A / (μ * σ2)) * ‖x - y‖ :=
    fun x y ↦ norm_sub_le_spherePairingSup_of_isMinOn hm hf A hmin x y
  have hId : ∀ x u, A' x u = A x u := by
    intro x u
    simp [A', ContinuousLinearMap.coe_coe]
  have hnorm : OperatorNormDef A' = spherePairingSup A :=
    operatorNormDef_eq_spherePairingSup A A' hId
  refine ⟨OperatorNormDef A' / (μ * σ2), rfl, ?_⟩
  -- The nonnegative ratio is exactly the stated Lipschitz constant.
  refine LipschitzWith.of_dist_le' ?_
  intro x y
  rw [dist_eq_norm, dist_eq_norm, hnorm]
  exact hdist x y
