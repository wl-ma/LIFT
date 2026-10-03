module

public import ReasLib.Analysis.Convex.EffectiveDomain
public import ReasLib.Analysis.Convex.Indicator
public import ReasLib.Analysis.InnerProductSpace.NormSq
public import Mathlib.Analysis.Convex.Strong
public import Mathlib.Data.EReal.Operations
public import Mathlib.LinearAlgebra.FiniteDimensional.Defs

@[expose] public section

universe u

/-- `σ`-strong convexity of an extended-real function on a real inner product space. The parameter
`σ` is positive, `f` never takes the value `⊥`, `effectiveDomain f` is convex, and every convex
combination with weight in `Set.Icc (0 : ℝ) 1` satisfies the quadratic deficit inequality for the
inner-product norm `‖·‖`. -/
structure StrongConvex {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (σ : ℝ)
    (f : E → EReal) : Prop where
  /-- The strong-convexity parameter is positive. -/
  sigmaPos : 0 < σ
  /-- The function never takes the value `⊥`. -/
  botLt : ∀ x, ⊥ < f x
  /-- The effective domain is convex. -/
  convexDomain : Convex ℝ (effectiveDomain f)
  /-- Quadratic deficit inequality on the effective domain. -/
  leCombo :
    ∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ t ∈ Set.Icc (0 : ℝ) 1,
      f (t • x + (1 - t) • y) ≤
        (t : EReal) * f x + ((1 - t) : EReal) * f y -
          ((σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2 : ℝ) : EReal)

/-- Build `σ`-strong convexity from positivity of `σ`, exclusion of `⊥`, convexity of the effective
domain, and the quadratic deficit inequality. -/
def StrongConvex.ofConditions {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {σ : ℝ}
    {f : E → EReal} (sigmaPos : 0 < σ) (botLt : ∀ x, ⊥ < f x)
    (convexDomain : Convex ℝ (effectiveDomain f))
    (leCombo :
      ∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ t ∈ Set.Icc (0 : ℝ) 1,
        f (t • x + (1 - t) • y) ≤
          (t : EReal) * f x + ((1 - t) : EReal) * f y -
            ((σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2 : ℝ) : EReal)) :
    StrongConvex σ f where
  sigmaPos := sigmaPos
  botLt := botLt
  convexDomain := convexDomain
  leCombo := leCombo

/-- `σ`-strong convexity is positivity of `σ`, exclusion of `⊥`, convexity of the effective domain,
and the quadratic deficit inequality. -/
theorem strongConvex_iff {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] (σ : ℝ)
    (f : E → EReal) :
    StrongConvex σ f ↔
      0 < σ ∧ (∀ x, ⊥ < f x) ∧ Convex ℝ (effectiveDomain f) ∧
        ∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ t ∈ Set.Icc (0 : ℝ) 1,
          f (t • x + (1 - t) • y) ≤
            (t : EReal) * f x + ((1 - t) : EReal) * f y -
              ((σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2 : ℝ) : EReal) := by
  constructor
  · intro h
    exact ⟨h.sigmaPos, h.botLt, h.convexDomain, h.leCombo⟩
  · intro h
    exact StrongConvex.ofConditions h.1 h.2.1 h.2.2.1 h.2.2.2

/-- Coercing the real part of a finite extended-real value recovers that value. -/
private lemma coe_toReal_of_mem_effectiveDomain {α : Type*} {f : α → EReal} {x : α}
    (hx : x ∈ effectiveDomain f) : ((f x).toReal : EReal) = f x := by
  -- Effective-domain membership is exactly finiteness, which `EReal.coe_toReal` requires.
  rw [mem_effectiveDomain] at hx
  exact EReal.coe_toReal (ne_of_lt hx.2) (ne_of_gt hx.1)

/-- A weighted combination of two finite extended-real values, minus a real deficit, is the
coercion of the same real expression. -/
private lemma weightedSub_coe_eq {E : Type*} {f : E → EReal} {x y : E}
    (hx : x ∈ effectiveDomain f) (hy : y ∈ effectiveDomain f) (t c : ℝ) :
    (t : EReal) * f x + ((1 - t) : EReal) * f y - (c : EReal) =
      ((t * (f x).toReal + (1 - t) * (f y).toReal - c : ℝ) : EReal) := by
  -- Normalize only the extended-real side, so `toReal` on the real side is left untouched.
  conv =>
    lhs
    rw [← coe_toReal_of_mem_effectiveDomain hx, ← coe_toReal_of_mem_effectiveDomain hy,
      ← EReal.coe_one, ← EReal.coe_sub 1 t, ← EReal.coe_mul t (f x).toReal,
      ← EReal.coe_mul (1 - t) (f y).toReal,
      ← EReal.coe_add (t * (f x).toReal) ((1 - t) * (f y).toReal),
      ← EReal.coe_sub (t * (f x).toReal + (1 - t) * (f y).toReal) c]

/-- For finite extended-real values, the weighted deficit inequality is equivalent to the same
inequality of real parts. -/
private lemma le_weightedSub_toReal_iff {E : Type*} {f : E → EReal} {x y z : E}
    (hx : x ∈ effectiveDomain f) (hy : y ∈ effectiveDomain f) (hz : z ∈ effectiveDomain f)
    (t c : ℝ) :
    f z ≤ (t : EReal) * f x + ((1 - t) : EReal) * f y - (c : EReal) ↔
      (f z).toReal ≤ t * (f x).toReal + (1 - t) * (f y).toReal - c := by
  -- Both sides are coercions of reals, so the order embedding `ℝ ↪ EReal` applies.
  rw [← coe_toReal_of_mem_effectiveDomain hz, weightedSub_coe_eq hx hy t c]
  exact EReal.coe_le_coe_iff

/-- Subtracting the coercion of a nonnegative real does not increase an extended real. -/
private lemma sub_coe_le_of_nonneg {a : EReal} {c : ℝ} (hc : 0 ≤ c) : a - (c : EReal) ≤ a := by
  -- Subtraction is addition of a nonpositive value, and addition is monotone.
  calc
    a - (c : EReal) = a + -(c : EReal) := sub_eq_add_neg a (c : EReal)
    _ ≤ a + 0 := add_le_add_right (EReal.neg_le_zero.mpr (EReal.coe_nonneg.mpr hc)) a
    _ = a := add_zero a

/-- The two writings of a quadratic strong-convexity deficit agree when the weights sum to one. -/
private lemma sub_strongConvexModulus_eq {σ a b fx fy r : ℝ} (hab : a + b = 1) :
    a * fx + b * fy - a * b * (σ / 2 * r ^ 2) =
      a * fx + (1 - a) * fy - σ / 2 * a * (1 - a) * r ^ 2 := by
  have hb : b = 1 - a := eq_sub_iff_add_eq.mpr ((add_comm b a).trans hab)
  have hmonomial :
      a * (1 - a) * (σ / 2 * r ^ 2) = σ / 2 * a * (1 - a) * r ^ 2 := by
    -- Commute the modulus factor past the weights and reassociate.
    rw [← mul_assoc (a * (1 - a)) (σ / 2) (r ^ 2), mul_comm (a * (1 - a)) (σ / 2),
      ← mul_assoc (σ / 2) a (1 - a)]
  -- Substitute the complementary weight, then match the quadratic monomials.
  rw [hb, hmonomial]

/-- `strongConvex_iff_strongConvexOn`. Extended-real `σ`-strong convexity is positivity of `σ`, exclusion of `⊥`, and real
`StrongConvexOn` of `(f ·).toReal` on the effective domain. -/
theorem strongConvex_iff_strongConvexOn {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {σ : ℝ} {f : E → EReal} :
    StrongConvex σ f ↔
      0 < σ ∧ (∀ x, ⊥ < f x) ∧
        StrongConvexOn (effectiveDomain f) σ (fun x ↦ (f x).toReal) := by
  constructor
  · intro hf
    -- Positivity and exclusion of `⊥` are structure fields; the deficit inequality is uniform.
    refine ⟨hf.sigmaPos, hf.botLt, ?_⟩
    unfold StrongConvexOn UniformConvexOn
    refine ⟨hf.convexDomain, ?_⟩
    intro x hx y hy a b ha hb hab
    have hb_eq : b = 1 - a := eq_sub_iff_add_eq.mpr ((add_comm b a).trans hab)
    have ha_le : a ≤ 1 := by
      -- The complementary weight is nonnegative, so `a` lies in the unit interval.
      rw [← sub_nonneg, ← hb_eq]
      exact hb
    have ha_icc : a ∈ Set.Icc (0 : ℝ) 1 := ⟨ha, ha_le⟩
    have hz : a • x + (1 - a) • y ∈ effectiveDomain f := by
      rw [← hb_eq]
      exact (convex_iff_add_mem.mp hf.convexDomain) hx hy ha hb hab
    have hreal :
        (f (a • x + (1 - a) • y)).toReal ≤
          a * (f x).toReal + (1 - a) * (f y).toReal -
            σ / 2 * a * (1 - a) * ‖x - y‖ ^ 2 :=
      (le_weightedSub_toReal_iff hx hy hz a
          (σ / 2 * a * (1 - a) * ‖x - y‖ ^ 2)).mp
        (hf.leCombo x hx y hy a ha_icc)
    -- Real scalar multiplication is multiplication, and the deficit monomials agree.
    rw [hb_eq, smul_eq_mul, smul_eq_mul, sub_strongConvexModulus_eq (add_sub_cancel a 1)]
    exact hreal
  · rintro ⟨hσ, hbot, hsc⟩
    unfold StrongConvexOn UniformConvexOn at hsc
    have hleCombo :
        ∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ t ∈ Set.Icc (0 : ℝ) 1,
          f (t • x + (1 - t) • y) ≤
            (t : EReal) * f x + ((1 - t) : EReal) * f y -
              ((σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2 : ℝ) : EReal) := by
      intro x hx y hy t ht
      have ht0 : 0 ≤ t := ht.1
      have ht1 : 0 ≤ 1 - t := sub_nonneg.mpr ht.2
      have hsum : t + (1 - t) = 1 := add_sub_cancel t 1
      have hz : t • x + (1 - t) • y ∈ effectiveDomain f :=
        (convex_iff_add_mem.mp hsc.1) hx hy ht0 ht1 hsum
      have hreal :
          (f (t • x + (1 - t) • y)).toReal ≤
            t * (f x).toReal + (1 - t) * (f y).toReal -
              σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2 := by
        have hraw := hsc.2 hx hy ht0 ht1 hsum
        -- Convert real scalar multiplication to multiplication and align the deficit monomials.
        rw [smul_eq_mul, smul_eq_mul, sub_strongConvexModulus_eq hsum] at hraw
        exact hraw
      exact
        (le_weightedSub_toReal_iff hx hy hz t
            (σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2)).mpr hreal
    exact StrongConvex.ofConditions hσ hbot hsc.1 hleCombo

/-- `StrongConvex.coe_iff_strongConvexOn_univ`. Coercing a real-valued function pointwise into `EReal` makes extended-real strong convexity
equivalent to positivity of `μ` together with real strong convexity on `Set.univ`. -/
theorem StrongConvex.coe_iff_strongConvexOn_univ {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {μ : ℝ} {f : E → ℝ} :
    StrongConvex μ (fun x ↦ (f x : EReal)) ↔ 0 < μ ∧ StrongConvexOn Set.univ μ f := by
  -- Translate extended-real strong convexity into positivity, exclusion of `⊥`, and real
  -- strong convexity of the real part on the effective domain.
  rw [strongConvex_iff_strongConvexOn]
  -- The coercion is finite on `Set.univ`, `toReal` recovers `f`, and the `⊥` bound is redundant.
  simp only [effectiveDomain_coe_eq_univ, EReal.toReal_coe, EReal.bot_lt_coe, implies_true,
    true_and]

/-- Strong convexity yields the extended-real Jensen inequality on the effective domain. -/
theorem StrongConvex.jensen {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {σ : ℝ}
    {f : E → EReal} (hf : StrongConvex σ f) {x y : E} (hx : x ∈ effectiveDomain f)
    (hy : y ∈ effectiveDomain f) {t : ℝ} (ht : t ∈ Set.Icc (0 : ℝ) 1) :
    f (t • x + (1 - t) • y) ≤ (t : EReal) * f x + ((1 - t) : EReal) * f y := by
  -- The quadratic deficit is nonnegative, so deleting it leaves Jensen's inequality.
  have hσ2 : 0 ≤ σ / 2 := div_nonneg hf.sigmaPos.le zero_le_two
  have ht1 : 0 ≤ 1 - t := sub_nonneg.mpr ht.2
  have hdef : 0 ≤ σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2 :=
    mul_nonneg (mul_nonneg (mul_nonneg hσ2 ht.1) ht1) (sq_nonneg ‖x - y‖)
  exact le_trans (hf.leCombo x hx y hy t ht) (sub_coe_le_of_nonneg hdef)

/-- The real representative `(f ·).toReal` of a strongly convex extended-real function is convex on
the effective domain. -/
theorem StrongConvex.convexOn {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {σ : ℝ}
    {f : E → EReal} (hf : StrongConvex σ f) :
    ConvexOn ℝ (effectiveDomain f) (fun x ↦ (f x).toReal) := by
  -- Lower the positive modulus to zero; strong convexity at modulus zero is convexity.
  have hsc : StrongConvexOn (effectiveDomain f) σ (fun x ↦ (f x).toReal) :=
    (strongConvex_iff_strongConvexOn.mp hf).2.2
  exact strongConvexOn_zero.mp (StrongConvexOn.mono hf.sigmaPos.le hsc)

/-- The effective domain of a pointwise sum of extended-real functions that never take the value
`⊥` is the intersection of the two effective domains. -/
private lemma effectiveDomain_add {α : Type*} {f g : α → EReal}
    (hf : ∀ x, ⊥ < f x) (hg : ∀ x, ⊥ < g x) :
    effectiveDomain (f + g) = effectiveDomain f ∩ effectiveDomain g := by
  ext x
  -- Reduce membership to finiteness of the pointwise sum.
  simp only [mem_effectiveDomain, Set.mem_inter_iff, Pi.add_apply]
  constructor
  · intro h
    -- Both values stay above `⊥`, so a finite sum forces each summand to be finite.
    have hne : f x ≠ ⊤ ∧ g x ≠ ⊤ :=
      (EReal.add_ne_top_iff_ne_top₂ (ne_of_gt (hf x)) (ne_of_gt (hg x))).mp (ne_of_lt h.2)
    exact ⟨⟨hf x, lt_top_iff_ne_top.mpr hne.1⟩, ⟨hg x, lt_top_iff_ne_top.mpr hne.2⟩⟩
  · intro h
    -- A sum of values strictly below `⊤` remains strictly below `⊤`.
    exact ⟨EReal.bot_lt_add_iff.mpr ⟨hf x, hg x⟩,
      EReal.add_lt_top (ne_of_lt h.1.2) (ne_of_lt h.2.2)⟩

/-- On the intersection of the effective domains, the real part of a pointwise sum is the sum of
the real parts. -/
private lemma toReal_add_of_mem_effectiveDomain {α : Type*} {f g : α → EReal} {x : α}
    (hxf : x ∈ effectiveDomain f) (hxg : x ∈ effectiveDomain g) :
    ((f + g) x).toReal = (f x).toReal + (g x).toReal := by
  rw [mem_effectiveDomain] at hxf hxg
  -- Finiteness is the side condition for adding real parts in `EReal`.
  rw [Pi.add_apply]
  exact EReal.toReal_add (ne_of_lt hxf.2) (ne_of_gt hxf.1) (ne_of_lt hxg.2) (ne_of_gt hxg.1)

/-- A weighted inequality between finite extended-real values descends to the same inequality of
real parts. -/
private lemma le_toReal_of_extendedJensen {E : Type*} {g : E → EReal} {x y z : E} {t : ℝ}
    (hx : x ∈ effectiveDomain g) (hy : y ∈ effectiveDomain g) (hz : z ∈ effectiveDomain g)
    (hle : g z ≤ (t : EReal) * g x + ((1 - t) : EReal) * g y) :
    (g z).toReal ≤ t * (g x).toReal + (1 - t) * (g y).toReal := by
  -- A zero deficit does not change the extended-real weighted sum.
  have hzero :
      g z ≤ (t : EReal) * g x + ((1 - t) : EReal) * g y - (0 : EReal) := by
    rwa [sub_zero]
  -- Transport across the real-part equivalence and delete that zero deficit.
  simpa [sub_zero] using (le_weightedSub_toReal_iff hx hy hz t 0).mp hzero

/-- `StrongConvex.add_convex`. The pointwise sum of a `σ`-strongly convex extended-real function and a convex extended-real
function on a finite-dimensional real inner product space is `σ`-strongly convex. Convexity of the
second summand is exclusion of `⊥`, convexity of its effective domain, and the closed-interval
extended-real Jensen inequality; neither summand is assumed proper. -/
theorem StrongConvex.add_convex {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] {σ : ℝ} {f g : E → EReal} (hf : StrongConvex σ f)
    (hbot : ∀ x, ⊥ < g x) (hconvex : Convex ℝ (effectiveDomain g))
    (hjensen :
      ∀ x ∈ effectiveDomain g, ∀ y ∈ effectiveDomain g, ∀ t ∈ Set.Icc (0 : ℝ) 1,
        g (t • x + (1 - t) • y) ≤
          (t : EReal) * g x + ((1 - t) : EReal) * g y) :
    StrongConvex σ (f + g) := by
  -- Positivity of `σ` is inherited; exclusion of `⊥`, convexity, and the deficit are checked next.
  refine StrongConvex.ofConditions hf.sigmaPos ?_ ?_ ?_
  · intro x
    -- The sum excludes `⊥` exactly when both summands do.
    rw [Pi.add_apply, EReal.bot_lt_add_iff]
    exact ⟨hf.botLt x, hbot x⟩
  · -- The effective domain of the sum is the intersection of two convex sets.
    rw [effectiveDomain_add hf.botLt hbot]
    exact Convex.inter hf.convexDomain hconvex
  · intro x hx y hy t ht
    -- Split the sum-domain memberships without losing the original hypotheses.
    have hx_mem : x ∈ effectiveDomain f ∩ effectiveDomain g := by
      rwa [effectiveDomain_add hf.botLt hbot] at hx
    have hy_mem : y ∈ effectiveDomain f ∩ effectiveDomain g := by
      rwa [effectiveDomain_add hf.botLt hbot] at hy
    have hx_f : x ∈ effectiveDomain f := hx_mem.1
    have hx_g : x ∈ effectiveDomain g := hx_mem.2
    have hy_f : y ∈ effectiveDomain f := hy_mem.1
    have hy_g : y ∈ effectiveDomain g := hy_mem.2
    set z := t • x + (1 - t) • y
    have ht0 : 0 ≤ t := ht.1
    have ht1 : 0 ≤ 1 - t := sub_nonneg.mpr ht.2
    have htsum : t + (1 - t) = 1 := add_sub_cancel t 1
    have hz : z ∈ effectiveDomain (f + g) := by
      -- The convex combination remains in the convex intersection of the domains.
      have hdom : Convex ℝ (effectiveDomain (f + g)) := by
        rw [effectiveDomain_add hf.botLt hbot]
        exact Convex.inter hf.convexDomain hconvex
      exact (convex_iff_add_mem.mp hdom) hx hy ht0 ht1 htsum
    have hz_mem : z ∈ effectiveDomain f ∩ effectiveDomain g := by
      rwa [effectiveDomain_add hf.botLt hbot] at hz
    have hz_f : z ∈ effectiveDomain f := hz_mem.1
    have hz_g : z ∈ effectiveDomain g := hz_mem.2
    -- Keep the quadratic deficit of `f` while passing to real parts.
    have hf_real :
        (f z).toReal ≤
          t * (f x).toReal + (1 - t) * (f y).toReal -
            σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2 :=
      (le_weightedSub_toReal_iff hx_f hy_f hz_f t
          (σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2)).mp
        (hf.leCombo x hx_f y hy_f t ht)
    -- Convexity of `g` contributes ordinary real Jensen, with no deficit.
    have hg_real :
        (g z).toReal ≤ t * (g x).toReal + (1 - t) * (g y).toReal :=
      le_toReal_of_extendedJensen hx_g hy_g hz_g (hjensen x hx_g y hy_g t ht)
    -- Add the inequalities and regroup the weighted sums, retaining the deficit of `f`.
    have hsum_real :
        (f z).toReal + (g z).toReal ≤
          t * ((f x).toReal + (g x).toReal) +
            (1 - t) * ((f y).toReal + (g y).toReal) -
            σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2 := by
      calc
        (f z).toReal + (g z).toReal ≤
            (t * (f x).toReal + (1 - t) * (f y).toReal -
              σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2) +
              (t * (g x).toReal + (1 - t) * (g y).toReal) :=
          add_le_add hf_real hg_real
        _ =
            t * ((f x).toReal + (g x).toReal) +
              (1 - t) * ((f y).toReal + (g y).toReal) -
              σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2 := by
          ring
    -- The three real sums are the real parts of the pointwise sum.
    rw [← toReal_add_of_mem_effectiveDomain hz_f hz_g,
      ← toReal_add_of_mem_effectiveDomain hx_f hx_g,
      ← toReal_add_of_mem_effectiveDomain hy_f hy_g] at hsum_real
    exact
      (le_weightedSub_toReal_iff hx hy hz t
          (σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2)).mpr hsum_real

/-- On a set, if `f` equals `g` plus `(m / 2)` times the squared norm, then `g` equals `f`
minus that same quadratic term. -/
private lemma eqOn_of_add_normSq {E : Type*} [NormedAddCommGroup E] {s : Set E} {m : ℝ}
    {f g : E → ℝ} (h : ∀ x, x ∈ s → f x = g x + (m / 2) * ‖x‖ ^ 2) :
    Set.EqOn g (fun x ↦ f x - (m / 2) * ‖x‖ ^ 2) s := by
  intro x hx
  -- Reduce the setwise equality to a pointwise cancellation.
  dsimp
  rw [h x hx]
  ring

/-- On a real inner product space, `m`-strong convexity of a real function on a set is equivalent
to the existence of a convex function differing from it by `(m / 2)` times the squared norm. -/
theorem strongConvexOn_iff_exists_convex_add_normSq {E : Type*} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {s : Set E} {m : ℝ} {f : E → ℝ} :
    StrongConvexOn s m f ↔
      ∃ g : E → ℝ, (∀ x, x ∈ s → f x = g x + (m / 2) * ‖x‖ ^ 2) ∧ ConvexOn ℝ s g := by
  constructor
  · intro hf
    -- The witness is the subtraction map in Mathlib's strong-convexity criterion.
    refine ⟨fun x ↦ f x - (m / 2) * ‖x‖ ^ 2, ?_, ?_⟩
    · intro x _
      -- Adding the quadratic term cancels the subtraction.
      dsimp
      ring
    · exact strongConvexOn_iff_convex.mp hf
  · rintro ⟨g, hfg, hg⟩
    -- Values on `s` identify `g` with that subtraction map.
    have hEq : Set.EqOn g (fun x ↦ f x - (m / 2) * ‖x‖ ^ 2) s :=
      eqOn_of_add_normSq hfg
    -- Convexity only depends on those values, so it transfers to the subtraction map.
    have hconv : ConvexOn ℝ s (fun x ↦ f x - (m / 2) * ‖x‖ ^ 2) :=
      ConvexOn.congr hg hEq
    exact strongConvexOn_iff_convex.mpr hconv

/-- Subtracting the coercion of a real from an extended real is equivalent to adding that coercion
on the other side of the inequality. -/
private lemma le_sub_coe_iff_add_le {a b : EReal} {c : ℝ} :
    a ≤ b - (c : EReal) ↔ a + (c : EReal) ≤ b := by
  -- A real coercion is neither `⊥` nor `⊤`, so it may cross the subtraction.
  exact EReal.le_sub_iff_add_le (Or.inl (EReal.coe_ne_bot c)) (Or.inl (EReal.coe_ne_top c))

/-- Moving the factor `β / 2` past the weights does not change the quadratic modulus or its
coercion to an extended real. -/
private lemma coe_strongConvexModulus_mul_comm (β t r : ℝ) :
    ((β / 2 * t * (1 - t) * r : ℝ) : EReal) =
      ((t * (1 - t) * (β / 2) * r : ℝ) : EReal) := by
  -- The real products agree, and coercion preserves equality.
  have hmul : β / 2 * t * (1 - t) * r = t * (1 - t) * (β / 2) * r := by
    ring
  exact congrArg (fun z : ℝ ↦ (z : EReal)) hmul

/-- At a weight equal to `0` or `1`, the convex combination is the corresponding endpoint and the
quadratic deficit coefficient vanishes. -/
private lemma leCombo_at_endpoint {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] {β : ℝ}
    {f : E → EReal} {x y : E} {t : ℝ} (ht : t = 0 ∨ t = 1) :
    f (t • x + (1 - t) • y) ≤
      (t : EReal) * f x + ((1 - t) : EReal) * f y -
        ((β / 2 * t * (1 - t) * ‖x - y‖ ^ 2 : ℝ) : EReal) := by
  -- Either endpoint selects that point and kills the factor `t * (1 - t)`.
  rcases ht with rfl | rfl
  · have hcoeff : β / 2 * (0 : ℝ) * (1 - 0) * ‖x - y‖ ^ 2 = 0 := by
      ring
    -- Clear the real coefficient before `sub_zero` rewrites the same factor in the vector.
    rw [hcoeff, zero_smul, sub_zero, one_smul, zero_add]
    simp only [EReal.coe_zero, sub_zero, zero_mul, one_mul, zero_add]
    exact le_rfl
  · have hcoeff : β / 2 * (1 : ℝ) * (1 - 1) * ‖x - y‖ ^ 2 = 0 := by
      ring
    -- `1 - ↑1` is the extended-real subtraction, not the coercion of the real difference.
    have hweight : (1 : EReal) - ↑(1 : ℝ) = 0 :=
      EReal.sub_self (EReal.coe_ne_top (1 : ℝ)) (EReal.coe_ne_bot (1 : ℝ))
    have hscalar : (1 - 1 : ℝ) = 0 := sub_self (1 : ℝ)
    have hpoint : (1 : ℝ) • x + ((1 : ℝ) - (1 : ℝ)) • y = x := by
      rw [hscalar, one_smul, zero_smul, add_zero]
    rw [hpoint, hcoeff, hweight]
    simp only [EReal.coe_zero, sub_zero, zero_mul, add_zero, EReal.coe_one, one_mul]
    exact le_rfl

/-- If an extended-real function never takes the value `⊥` and satisfies the closed quadratic
deficit inequality on its effective domain, then that domain is convex. -/
private lemma convex_effectiveDomain_of_leCombo {E : Type*} [NormedAddCommGroup E]
    [NormedSpace ℝ E] {β : ℝ} {f : E → EReal} (hbot : ∀ x, ⊥ < f x)
    (hle :
      ∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ t ∈ Set.Icc (0 : ℝ) 1,
        f (t • x + (1 - t) • y) ≤
          (t : EReal) * f x + ((1 - t) : EReal) * f y -
            ((β / 2 * t * (1 - t) * ‖x - y‖ ^ 2 : ℝ) : EReal)) :
    Convex ℝ (effectiveDomain f) := by
  -- Convexity is membership of every convex combination with nonnegative weights summing to one.
  rw [convex_iff_add_mem]
  intro x hx y hy a b ha hb hab
  -- The complementary weight puts the first weight in the closed unit interval.
  have hb_eq : b = 1 - a := by
    rw [eq_sub_iff_add_eq, add_comm]
    exact hab
  have ha_le : a ≤ 1 := by
    rw [hb_eq] at hb
    exact sub_nonneg.mp hb
  rw [hb_eq]
  -- The closed inequality bounds the combination by a real, hence strictly below `⊤`.
  have hupper :=
    hle x hx y hy a ⟨ha, ha_le⟩
  rw [weightedSub_coe_eq hx hy a (β / 2 * a * (1 - a) * ‖x - y‖ ^ 2)] at hupper
  have hlt : f (a • x + (1 - a) • y) < ⊤ :=
    lt_of_le_of_lt hupper (EReal.coe_lt_top _)
  rw [mem_effectiveDomain]
  exact ⟨hbot _, hlt⟩

namespace StrongConvex

/-- `StrongConvex.leCombo_Icc_iff_Ioo`. The quadratic deficit inequality on the closed interval `Set.Icc (0 : ℝ) 1`, written by
subtracting the real modulus, is equivalent to the same inequality on the open interval
`Set.Ioo (0 : ℝ) 1`, written by adding that modulus. Endpoint weights act as identities on finite
extended-real values, and `EReal.le_sub_iff_add_le` moves a real deficit between the two forms. -/
theorem leCombo_Icc_iff_Ioo {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] {β : ℝ}
    {f : E → EReal} :
    (∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ t ∈ Set.Icc (0 : ℝ) 1,
        f (t • x + (1 - t) • y) ≤
          (t : EReal) * f x + ((1 - t) : EReal) * f y -
            ((β / 2 * t * (1 - t) * ‖x - y‖ ^ 2 : ℝ) : EReal)) ↔
      (∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ α ∈ Set.Ioo (0 : ℝ) 1,
        f (α • x + (1 - α) • y) +
            ((α * (1 - α) * (β / 2) * ‖x - y‖ ^ 2 : ℝ) : EReal) ≤
          (α : EReal) * f x + ((1 - α) : EReal) * f y) := by
  constructor
  · intro hIcc x hx y hy α hα
    -- An open weight lies in the closed interval, so the subtracted inequality applies.
    have hsub := hIcc x hx y hy α (Set.mem_Icc_of_Ioo hα)
    -- Put `β / 2` in the open-form position, then move the real deficit across subtraction.
    rw [coe_strongConvexModulus_mul_comm] at hsub
    exact le_sub_coe_iff_add_le.mp hsub
  · intro hIoo x hx y hy t ht
    -- A closed weight is an endpoint, where the deficit vanishes, or an open weight.
    rcases eq_or_ne t 0 with rfl | ht0
    · exact leCombo_at_endpoint (Or.inl rfl)
    rcases eq_or_ne t 1 with rfl | ht1
    · exact leCombo_at_endpoint (Or.inr rfl)
    have htIoo : t ∈ Set.Ioo (0 : ℝ) 1 :=
      ⟨lt_of_le_of_ne ht.1 (Ne.symm ht0), lt_of_le_of_ne ht.2 ht1⟩
    have hadd := hIoo x hx y hy t htIoo
    rw [← coe_strongConvexModulus_mul_comm] at hadd
    exact le_sub_coe_iff_add_le.mpr hadd

/-- An extended-real function is proper when it never takes the value `⊥` and `effectiveDomain f`
is nonempty. For `0 < β`, the open additive strong-convexity inequality on that domain adds the
modulus `α * (1 - α) * (β / 2) * ‖x - y‖ ^ 2` at every weight in `Set.Ioo (0 : ℝ) 1`. Together
with properness, this inequality is equivalent to `StrongConvex β f` and a nonempty effective
domain; `StrongConvex` subtracts that same modulus on `Set.Icc (0 : ℝ) 1`. -/
theorem iff_proper_Ioo {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ)
    (f : E → EReal) :
    StrongConvex β f ∧ (effectiveDomain f).Nonempty ↔
      0 < β ∧ (∀ x, ⊥ < f x) ∧ (effectiveDomain f).Nonempty ∧
        ∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ α ∈ Set.Ioo (0 : ℝ) 1,
          f (α • x + (1 - α) • y) +
              ((α * (1 - α) * (β / 2) * ‖x - y‖ ^ 2 : ℝ) : EReal) ≤
            (α : EReal) * f x + ((1 - α) : EReal) * f y := by
  constructor
  · intro h
    -- Project strong convexity and transport the closed deficit to the open additive form.
    refine ⟨h.1.sigmaPos, h.1.botLt, h.2, ?_⟩
    exact leCombo_Icc_iff_Ioo.mp h.1.leCombo
  · rintro ⟨hβ, hbot, hne, hIoo⟩
    -- Extend the open inequality to the closed interval, including the vanishing endpoints.
    have hIcc := leCombo_Icc_iff_Ioo.mpr hIoo
    -- A real upper bound together with exclusion of `⊥` makes the effective domain convex.
    have hconv : Convex ℝ (effectiveDomain f) :=
      convex_effectiveDomain_of_leCombo hbot hIcc
    exact ⟨ofConditions hβ hbot hconv hIcc, hne⟩

end StrongConvex

namespace Analysis.Convex

/-- `Analysis.Convex.strongConvex_iff_convex_subNormSq`. On a finite-dimensional real inner product space, for a positive real parameter `σ` and an
extended-real function `f` that never takes the value `⊥`, `σ`-strong convexity of `f` is
equivalent to the existence of a real function on the space that agrees on `effectiveDomain f`
with the real representative of `f` minus `(σ / 2)` times the squared Euclidean norm and is convex
on that effective domain. -/
theorem strongConvex_iff_convex_subNormSq (E : Type*) [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] [FiniteDimensional ℝ E] (σ : ℝ) (f : E → EReal) (hσ : 0 < σ)
    (hBot : ∀ x, ⊥ < f x) :
    StrongConvex σ f ↔
      ∃ g : E → ℝ,
        (∀ x, x ∈ effectiveDomain f → (f x).toReal = g x + (σ / 2) * ‖x‖ ^ 2) ∧
          ConvexOn ℝ (effectiveDomain f) g := by
  -- Finite dimensionality is unused: the squared-norm identity holds on any real inner product space.
  -- Strip positivity of `σ` and exclusion of `⊥`, leaving real strong convexity of `(f ·).toReal`.
  rw [strongConvex_iff_strongConvexOn, and_iff_right hσ, and_iff_right hBot]
  -- That real strong convexity is exactly a convex function differing by `(σ / 2)‖·‖²`.
  exact strongConvexOn_iff_exists_convex_add_normSq

end Analysis.Convex

namespace ReasLib.Analysis.Convex

/-- The extended-real map `x ↦ (1 / 2) • ‖x‖ ^ 2` is `1`-strongly convex on a real inner product
space. -/
private lemma halfNormSqEReal_strongConvex {E : Type*} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] :
    StrongConvex (1 : ℝ) (fun x : E ↦ (((1 / 2 : ℝ) • ‖x‖ ^ 2 : ℝ) : EReal)) := by
  -- A real coercion excludes `⊥`, and the modulus `1` is positive.
  rw [strongConvex_iff_strongConvexOn]
  refine ⟨zero_lt_one, fun x ↦ EReal.bot_lt_coe _, ?_⟩
  -- Every value is finite, so the effective domain is the whole space.
  have hdom :
      effectiveDomain (fun x : E ↦ (((1 / 2 : ℝ) • ‖x‖ ^ 2 : ℝ) : EReal)) = Set.univ := by
    ext x
    -- A real coercion is finite, so every point lies in the effective domain.
    constructor
    · intro _
      exact Set.mem_univ x
    · intro _
      rw [mem_effectiveDomain]
      exact ⟨EReal.bot_lt_coe _, EReal.coe_lt_top _⟩
  -- The real part of the coerced square is the square, so the strong-convexity subtraction is zero.
  have hcancel (z : E) :
      (((1 / 2 : ℝ) • ‖z‖ ^ 2 : ℝ) : EReal).toReal - (1 : ℝ) / 2 * ‖z‖ ^ 2 = 0 := by
    rw [EReal.toReal_coe, smul_eq_mul]
    ring
  -- The zero function is convex on the whole space, hence so is the subtraction map.
  rw [hdom, strongConvexOn_iff_convex]
  refine (convexOn_const (0 : ℝ) convex_univ).congr ?_
  intro x _
  exact (hcancel x).symm

/-- The extended-real indicator of `C` is finite exactly on `C`. -/
private lemma effectiveDomain_erealIndicator {E : Type*} (C : Set E) :
    effectiveDomain (erealIndicator C) = C := by
  -- On `C` the indicator is `0`; off `C` it is `⊤`.
  classical
    ext x
    constructor
    · intro hx
      by_cases hmem : x ∈ C
      · exact hmem
      · rw [mem_effectiveDomain, erealIndicator, if_neg hmem] at hx
        exact absurd hx.2 (lt_irrefl _)
    · intro hx
      rw [mem_effectiveDomain, erealIndicator, if_pos hx]
      exact ⟨EReal.bot_lt_zero, EReal.zero_lt_top⟩

/-- The extended-real indicator never takes the value `⊥`. -/
private lemma bot_lt_erealIndicator {E : Type*} (C : Set E) (x : E) :
    ⊥ < erealIndicator C x := by
  -- The indicator is either `0` or `⊤`.
  classical
    by_cases hx : x ∈ C
    · rw [erealIndicator, if_pos hx]
      exact EReal.bot_lt_zero
    · rw [erealIndicator, if_neg hx]
      exact bot_lt_top

/-- On a convex set, the extended-real indicator satisfies the closed Jensen inequality. -/
private lemma erealIndicator_le_combo {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {C : Set E} (hC : Convex ℝ C) {x y : E} (hx : x ∈ effectiveDomain (erealIndicator C))
    (hy : y ∈ effectiveDomain (erealIndicator C)) {t : ℝ} (ht : t ∈ Set.Icc (0 : ℝ) 1) :
    erealIndicator C (t • x + (1 - t) • y) ≤
      (t : EReal) * erealIndicator C x + ((1 - t) : EReal) * erealIndicator C y := by
  -- Domain membership puts both endpoints in `C`.
  have hxC : x ∈ C := by
    rwa [effectiveDomain_erealIndicator] at hx
  have hyC : y ∈ C := by
    rwa [effectiveDomain_erealIndicator] at hy
  have ht0 : 0 ≤ t := ht.1
  have ht1 : 0 ≤ 1 - t := sub_nonneg.mpr ht.2
  have hsum : t + (1 - t) = 1 := add_sub_cancel t 1
  -- Nonnegative weights summing to one stay inside the convex set.
  have hzC : t • x + (1 - t) • y ∈ C :=
    (convex_iff_add_mem.mp hC) hxC hyC ht0 ht1 hsum
  -- All three indicator values are `0`, so both sides of Jensen's inequality vanish.
  rw [erealIndicator, if_pos hzC, erealIndicator, if_pos hxC, erealIndicator, if_pos hyC,
    mul_zero, mul_zero, add_zero]

/-- `ReasLib.Analysis.Convex.halfNormSq_add_erealIndicator_strongConvex`. The extended-real function `x ↦ (1/2)‖x‖² + δ_C(x)` is `1`-strongly convex when `C` is a
nonempty convex subset of a finite-dimensional real Euclidean space. -/
theorem halfNormSq_add_erealIndicator_strongConvex
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
    (C : Set E) (hCne : C.Nonempty) (hCconv : Convex ℝ C) :
    StrongConvex (1 : ℝ)
      (fun x => ((1 / 2 : ℝ) • ‖x‖ ^ 2 : ℝ) + erealIndicator C x) := by
  -- Nonemptiness is part of the source statement; transport it onto the indicator domain.
  have _hdom_ne : (effectiveDomain (erealIndicator C)).Nonempty := by
    rwa [effectiveDomain_erealIndicator]
  -- Convexity of `C` is convexity of the indicator's effective domain.
  have hdom : Convex ℝ (effectiveDomain (erealIndicator C)) := by
    rw [effectiveDomain_erealIndicator]
    exact hCconv
  -- The heterogeneous sum is the pointwise sum, so the addition interface applies directly.
  exact StrongConvex.add_convex halfNormSqEReal_strongConvex (bot_lt_erealIndicator C) hdom
    (fun x hx y hy t ht ↦ erealIndicator_le_combo hCconv hx hy ht)

end ReasLib.Analysis.Convex
