module

public import ReasLibDemo.Sources.Beck.Example521_Indicator
public import ReasLib.Analysis.Convex.Strong

@[expose] public section

universe u

/-- On `C`, the half squared norm plus the extended-real indicator equals the coerced half squared
norm. -/
theorem halfNormSq_add_erealIndicator_eq_coe_of_mem
    {E : Type u} [NormedAddCommGroup E] {C : Set E} {x : E} (hx : x ∈ C) :
    ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal) + erealIndicator C x =
      ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal) := by
  -- On `C` the indicator is `0`, so it does not change the coerced half squared norm.
  rw [erealIndicator_of_mem hx, add_zero]

/-- Outside `C`, the half squared norm plus the extended-real indicator equals `⊤`. -/
theorem halfNormSq_add_erealIndicator_eq_top_of_notMem
    {E : Type u} [NormedAddCommGroup E] {C : Set E} {x : E} (hx : x ∉ C) :
    ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal) + erealIndicator C x = ⊤ := by
  -- Off `C` the indicator is `⊤`, and a real coercion plus `⊤` is `⊤`.
  rw [erealIndicator_of_notMem hx, EReal.coe_add_top]

/-- The effective domain of the half squared norm plus the extended-real indicator is `C`. -/
theorem effectiveDomain_halfNormSq_add_erealIndicator
    {E : Type u} [NormedAddCommGroup E] (C : Set E) :
    effectiveDomain (fun x ↦ ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal) + erealIndicator C x) = C := by
  -- The sum is a finite real coercion on `C` and `⊤` outside `C`.
  ext x
  rw [mem_effectiveDomain]
  constructor
  · intro hfin
    -- Off `C` the sum equals `⊤`, which is not strictly below itself.
    by_contra hx
    rw [halfNormSq_add_erealIndicator_eq_top_of_notMem hx] at hfin
    exact lt_irrefl _ hfin.2
  · intro hx
    -- On `C` the indicator vanishes, leaving a real coercion strictly between `⊥` and `⊤`.
    rw [halfNormSq_add_erealIndicator_eq_coe_of_mem hx]
    exact ⟨EReal.bot_lt_coe _, EReal.coe_lt_top _⟩

/-- The extended-real function `fun x ↦ ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal)` is
`StrongConvex (1 : ℝ)` on a real inner product space. -/
lemma halfNormSqEReal_strongConvex {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] :
    StrongConvex (1 : ℝ)
      (fun x : E ↦ ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal)) := by
  -- A real coercion excludes `⊥`, and the modulus `1` is positive.
  rw [strongConvex_iff_strongConvexOn]
  refine ⟨zero_lt_one, fun x ↦ EReal.bot_lt_coe _, ?_⟩
  -- Every value is finite, so the effective domain is the whole space.
  have hdom :
      effectiveDomain (fun x : E ↦ ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal)) = Set.univ := by
    ext x
    constructor
    · intro _
      exact Set.mem_univ x
    · intro _
      rw [mem_effectiveDomain]
      exact ⟨EReal.bot_lt_coe _, EReal.coe_lt_top _⟩
  -- Subtracting `(1 / 2) * ‖·‖ ^ 2` cancels the real part of the coerced half squared norm.
  have hcancel (z : E) :
      ((((1 : ℝ) / 2) * ‖z‖ ^ 2 : ℝ) : EReal).toReal - (1 : ℝ) / 2 * ‖z‖ ^ 2 = 0 := by
    rw [EReal.toReal_coe]
    ring
  -- The zero function is convex on the whole space, hence so is the subtraction map.
  rw [hdom, strongConvexOn_iff_convex]
  refine (convexOn_const (0 : ℝ) convex_univ).congr ?_
  intro x _
  exact (hcancel x).symm

/-- If `C` is convex, then `erealIndicator C` satisfies the closed convex-combination inequality
on its effective domain. -/
lemma erealIndicator_le_combo {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] {C : Set E}
    (hC : Convex ℝ C) {x y : E} (hx : x ∈ effectiveDomain (erealIndicator C))
    (hy : y ∈ effectiveDomain (erealIndicator C)) {t : ℝ} (ht : t ∈ Set.Icc (0 : ℝ) 1) :
    erealIndicator C (t • x + (1 - t) • y) ≤
      (t : EReal) * erealIndicator C x + ((1 - t) : EReal) * erealIndicator C y := by
  -- Effective-domain membership is membership in `C`.
  have hxC : x ∈ C := mem_effectiveDomain_erealIndicator.mp hx
  have hyC : y ∈ C := mem_effectiveDomain_erealIndicator.mp hy
  have ht0 : 0 ≤ t := ht.1
  have ht1 : 0 ≤ 1 - t := sub_nonneg.mpr ht.2
  have hsum : t + (1 - t) = 1 := add_sub_cancel t 1
  -- Nonnegative weights summing to one stay inside the convex set.
  have hzC : t • x + (1 - t) • y ∈ C :=
    (convex_iff_add_mem.mp hC) hxC hyC ht0 ht1 hsum
  -- All three indicator values are `0`, so both sides of the inequality vanish.
  rw [erealIndicator_of_mem hzC, erealIndicator_of_mem hxC, erealIndicator_of_mem hyC,
    mul_zero, mul_zero, add_zero]

/-- `halfNormSq_add_erealIndicator_strongConvex`. Beck Example521. Let `E` be a finite-dimensional real Euclidean space and `C` a nonempty convex
subset. The extended-real function
`fun x ↦ ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal) + erealIndicator C x`, equal to
`((1 : ℝ) / 2) * ‖x‖ ^ 2` on `C` and to `⊤` outside `C`, is `StrongConvex (1 : ℝ)`. -/
theorem halfNormSq_add_erealIndicator_strongConvex
    {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
    {C : Set E} (hne : C.Nonempty) (hconv : Convex ℝ C) :
    StrongConvex (1 : ℝ)
      (fun x ↦ ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal) + erealIndicator C x) := by
  -- Nonemptiness of `C` is nonemptiness of the indicator's effective domain.
  have _hdom_ne : (effectiveDomain (erealIndicator C)).Nonempty := by
    obtain ⟨x, hx⟩ := hne
    exact ⟨x, mem_effectiveDomain_erealIndicator.mpr hx⟩
  -- Convexity of `C` transfers across that same membership characterization.
  have hdom : Convex ℝ (effectiveDomain (erealIndicator C)) := by
    rw [Set.ext fun _ ↦ mem_effectiveDomain_erealIndicator]
    exact hconv
  -- The target is the pointwise sum of the `1`-strongly convex half squared norm and the convex
  -- indicator.
  exact StrongConvex.add_convex halfNormSqEReal_strongConvex (bot_lt_erealIndicator C) hdom
    fun x hx y hy t ht ↦ erealIndicator_le_combo hconv hx hy ht
