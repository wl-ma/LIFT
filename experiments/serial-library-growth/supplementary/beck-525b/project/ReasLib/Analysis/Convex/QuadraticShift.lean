module

public import ReasLib.Analysis.Convex.Strong

public section

universe u

/-- The extended-real shift of `f` by the quadratic `σ / (2 : ℝ) * ‖x‖ ^ 2`. -/
noncomputable def subNormSq {E : Type u} [NormedAddCommGroup E] (σ : ℝ) (f : E → EReal) : E → EReal :=
  fun x ↦ f x - ((σ / (2 : ℝ) * ‖x‖ ^ 2 : ℝ) : EReal)

/-- Subtracting a real multiple of the squared norm does not change the effective domain. -/
lemma effectiveDomain_subNormSq {E : Type*} [NormedAddCommGroup E] (σ : ℝ) (f : E → EReal) :
    effectiveDomain (subNormSq σ f) = effectiveDomain f := by
  ext x
  rw [mem_effectiveDomain, mem_effectiveDomain]
  -- The quadratic correction is real, so adding its negation preserves both `⊥` and `⊤`.
  have hshift :
      subNormSq σ f x = f x + ((-(σ / (2 : ℝ) * ‖x‖ ^ 2) : ℝ) : EReal) := by
    unfold subNormSq
    rw [sub_eq_add_neg, ← EReal.coe_neg]
  rw [hshift]
  have hneBot : ((-(σ / (2 : ℝ) * ‖x‖ ^ 2) : ℝ) : EReal) ≠ ⊥ := EReal.coe_ne_bot _
  have hneTop : ((-(σ / (2 : ℝ) * ‖x‖ ^ 2) : ℝ) : EReal) ≠ ⊤ := EReal.coe_ne_top _
  constructor
  · intro h
    exact ⟨(EReal.bot_lt_add_iff.mp h.1).1,
      lt_top_iff_ne_top.mpr
        ((EReal.add_ne_top_iff_ne_top_left hneBot hneTop).mp (lt_top_iff_ne_top.mp h.2))⟩
  · intro h
    exact ⟨EReal.bot_lt_add_iff.mpr ⟨h.1, EReal.bot_lt_coe _⟩,
      lt_top_iff_ne_top.mpr
        ((EReal.add_ne_top_iff_ne_top_left hneBot hneTop).mpr (lt_top_iff_ne_top.mp h.2))⟩

/-- At a finite value, the quadratic shift is the coercion of the corresponding real subtraction. -/
lemma subNormSq_eq_coe_toReal_sub {E : Type*} [NormedAddCommGroup E] {σ : ℝ} {f : E → EReal}
    {x : E} (hx : x ∈ effectiveDomain f) :
    subNormSq σ f x = ↑((f x).toReal - σ / (2 : ℝ) * ‖x‖ ^ 2) := by
  -- Effective-domain membership is finiteness, and subtraction commutes with that coercion.
  rw [mem_effectiveDomain] at hx
  unfold subNormSq
  -- The right-hand side already contains `(f x).toReal`, so rewrite only the outer value.
  nth_rw 1 [← EReal.coe_toReal (ne_of_lt hx.2) (ne_of_gt hx.1)]
  rw [← EReal.coe_sub]

/-- For finite values, a weighted comparison of quadratic shifts agrees with the comparison of real
parts. -/
private lemma subNormSq_weighted_le_iff {E : Type*} [NormedAddCommGroup E] {σ t : ℝ}
    {f : E → EReal} {x y z : E}
    (hx : x ∈ effectiveDomain f) (hy : y ∈ effectiveDomain f) (hz : z ∈ effectiveDomain f) :
    subNormSq σ f z ≤ (t : EReal) * subNormSq σ f x + ((1 - t) : EReal) * subNormSq σ f y ↔
      (f z).toReal - σ / (2 : ℝ) * ‖z‖ ^ 2 ≤
        t * ((f x).toReal - σ / (2 : ℝ) * ‖x‖ ^ 2) +
          (1 - t) * ((f y).toReal - σ / (2 : ℝ) * ‖y‖ ^ 2) := by
  -- Every term is a real coercion. Normalize `1 - t` before reflecting products and order.
  rw [subNormSq_eq_coe_toReal_sub hx, subNormSq_eq_coe_toReal_sub hy,
    subNormSq_eq_coe_toReal_sub hz, ← EReal.coe_mul, ← EReal.coe_one, ← EReal.coe_sub,
    ← EReal.coe_mul, ← EReal.coe_add, EReal.coe_le_coe_iff]

/-- Real convexity of the quadratic shift is convexity of the effective domain together with the
extended Jensen inequality at every weight in the unit interval. -/
private lemma convexOn_toReal_sub_normSq_iff {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {σ : ℝ} {f : E → EReal} :
    ConvexOn ℝ (effectiveDomain f) (fun x ↦ (f x).toReal - σ / (2 : ℝ) * ‖x‖ ^ 2) ↔
      Convex ℝ (effectiveDomain (subNormSq σ f)) ∧
        ∀ x ∈ effectiveDomain (subNormSq σ f), ∀ y ∈ effectiveDomain (subNormSq σ f),
          ∀ t ∈ Set.Icc (0 : ℝ) 1,
            subNormSq σ f (t • x + (1 - t) • y) ≤
              (t : EReal) * subNormSq σ f x + ((1 - t) : EReal) * subNormSq σ f y := by
  -- The quadratic correction does not change which points are finite.
  rw [effectiveDomain_subNormSq]
  constructor
  · intro hconv
    refine ⟨hconv.1, ?_⟩
    intro x hx y hy t ht
    -- Unit-interval weights are nonnegative and complementary.
    have ht0 : 0 ≤ t := ht.1
    have ht1 : 0 ≤ 1 - t := sub_nonneg.mpr ht.2
    have hsum : t + (1 - t) = 1 := by
      rw [add_comm, sub_add_cancel]
    have hz : t • x + (1 - t) • y ∈ effectiveDomain f :=
      (convex_iff_add_mem.mp hconv.1) hx hy ht0 ht1 hsum
    have hreal := hconv.2 hx hy ht0 ht1 hsum
    -- Scalar multiplication on `ℝ` is multiplication, so the comparison lifts.
    simp only [smul_eq_mul] at hreal
    exact (subNormSq_weighted_le_iff hx hy hz).mpr hreal
  · rintro ⟨hdom, hle⟩
    refine ⟨hdom, ?_⟩
    intro x hx y hy a b ha hb hab
    -- Turn the pair of weights into a unit-interval parameter and its complement.
    have hb_eq : b = 1 - a := eq_sub_iff_add_eq.mpr ((add_comm b a).trans hab)
    have ha_le : a ≤ 1 := by
      rw [← sub_nonneg, ← hb_eq]
      exact hb
    have hz : a • x + b • y ∈ effectiveDomain f :=
      (convex_iff_add_mem.mp hdom) hx hy ha hb hab
    rw [hb_eq] at hz
    have hreal := (subNormSq_weighted_le_iff hx hy hz).mp (hle x hx y hy a ⟨ha, ha_le⟩)
    -- Descend to the real inequality used by `ConvexOn`.
    simp only [smul_eq_mul, hb_eq]
    exact hreal

/-- Let `E` be a Euclidean space: the endowed norm satisfies
`‖x‖ = √⟪x, x⟫_ℝ` for every `x`, as in `norm_eq_sqrt_real_inner`. For `σ > 0` and
`f : E → EReal` with values in `(-∞, ∞]`, `f` is `σ`-strongly convex if and only if
`subNormSq σ f`, the function `fun x ↦ f x - ((σ / (2 : ℝ) * ‖x‖ ^ 2 : ℝ) : EReal)`, is convex.
Convexity means that `effectiveDomain (subNormSq σ f)` is convex and Jensen's inequality holds
for every weight `t ∈ Set.Icc (0 : ℝ) 1`. -/
theorem strongConvex_iff_convex_subNormSq {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] [FiniteDimensional ℝ E] {σ : ℝ} {f : E → EReal}
    (hσ : 0 < σ) (hbot : ∀ x, ⊥ < f x) :
    StrongConvex σ f ↔
      Convex ℝ (effectiveDomain (subNormSq σ f)) ∧
        ∀ x ∈ effectiveDomain (subNormSq σ f), ∀ y ∈ effectiveDomain (subNormSq σ f),
          ∀ t ∈ Set.Icc (0 : ℝ) 1,
            subNormSq σ f (t • x + (1 - t) • y) ≤
              (t : EReal) * subNormSq σ f x + ((1 - t) : EReal) * subNormSq σ f y := by
  -- Positivity and exclusion of `⊥` are hypotheses. Real strong convexity is then convexity of
  -- the quadratic shift, transported to the extended-real domain and Jensen inequality.
  rw [strongConvex_iff_strongConvexOn, and_iff_right hσ, and_iff_right hbot,
    strongConvexOn_iff_convex, convexOn_toReal_sub_normSq_iff]


/-- For every real weight, `β / 2 * ‖·‖ ^ 2` decreases by
`t * (1 - t) * (β / 2) * ‖x - y‖ ^ 2` at the combination `t • x + (1 - t) • y`. -/
private lemma convexCombo_quadraticGap {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (β : ℝ) (x y : E) (t : ℝ) :
    t * (β / 2 * ‖x‖ ^ 2) + (1 - t) * (β / 2 * ‖y‖ ^ 2) -
        β / 2 * ‖t • x + (1 - t) • y‖ ^ 2 =
      t * (1 - t) * (β / 2) * ‖x - y‖ ^ 2 := by
  -- The unscaled squared-norm identity supplies the distance term.
  have hgap := Analysis.InnerProductSpace.euclideanNormSq_combo_sub E x y t
  have hneg :
      t * ‖x‖ ^ 2 + (1 - t) * ‖y‖ ^ 2 - ‖t • x + (1 - t) • y‖ ^ 2 =
        t * (1 - t) * ‖x - y‖ ^ 2 := by
    linear_combination -hgap
  -- Division by `2` is multiplication by the inverse, so the scalar factor stays in a ring.
  simp only [div_eq_mul_inv]
  calc
    t * (β * (2 : ℝ)⁻¹ * ‖x‖ ^ 2) + (1 - t) * (β * (2 : ℝ)⁻¹ * ‖y‖ ^ 2) -
        β * (2 : ℝ)⁻¹ * ‖t • x + (1 - t) • y‖ ^ 2
      = (β * (2 : ℝ)⁻¹) *
          (t * ‖x‖ ^ 2 + (1 - t) * ‖y‖ ^ 2 - ‖t • x + (1 - t) • y‖ ^ 2) := by
        ring
    _ = (β * (2 : ℝ)⁻¹) * (t * (1 - t) * ‖x - y‖ ^ 2) := by
        rw [hneg]
    _ = t * (1 - t) * (β * (2 : ℝ)⁻¹) * ‖x - y‖ ^ 2 := by
        ring

/-- For finite extended-real values, adding a real and comparing with a weighted sum is the same
comparison of real parts. -/
private lemma add_coe_le_weighted_iff_toReal {E : Type*} {f : E → EReal} {x y z : E}
    (hx : x ∈ effectiveDomain f) (hy : y ∈ effectiveDomain f) (hz : z ∈ effectiveDomain f)
    (t c : ℝ) :
    f z + (c : EReal) ≤ (t : EReal) * f x + ((1 - t) : EReal) * f y ↔
      (f z).toReal + c ≤ t * (f x).toReal + (1 - t) * (f y).toReal := by
  -- Each finite value is the coercion of its real part, and order reflects that coercion.
  rw [mem_effectiveDomain] at hx hy hz
  constructor
  · intro h
    rw [← EReal.coe_toReal (ne_of_lt hz.2) (ne_of_gt hz.1),
      ← EReal.coe_toReal (ne_of_lt hx.2) (ne_of_gt hx.1),
      ← EReal.coe_toReal (ne_of_lt hy.2) (ne_of_gt hy.1),
      ← EReal.coe_mul, ← EReal.coe_one, ← EReal.coe_sub, ← EReal.coe_mul,
      ← EReal.coe_add, ← EReal.coe_add, EReal.coe_le_coe_iff] at h
    exact h
  · intro h
    rw [← EReal.coe_toReal (ne_of_lt hz.2) (ne_of_gt hz.1),
      ← EReal.coe_toReal (ne_of_lt hx.2) (ne_of_gt hx.1),
      ← EReal.coe_toReal (ne_of_lt hy.2) (ne_of_gt hy.1),
      ← EReal.coe_mul, ← EReal.coe_one, ← EReal.coe_sub, ← EReal.coe_mul,
      ← EReal.coe_add, ← EReal.coe_add, EReal.coe_le_coe_iff]
    exact h

/-- Subtracting weighted real corrections is equivalent to adding the complementary weighted gap. -/
private lemma weightedSub_le_iff_add_gap (t a b c px py pz : ℝ) :
    c - pz ≤ t * (a - px) + (1 - t) * (b - py) ↔
      c + (t * px + (1 - t) * py - pz) ≤ t * a + (1 - t) * b := by
  -- The two inequalities differ by the same real quantity.
  have hdiff :
      (c - pz) - (t * (a - px) + (1 - t) * (b - py)) =
        (c + (t * px + (1 - t) * py - pz)) - (t * a + (1 - t) * b) := by
    ring
  constructor
  · intro h
    -- Turn both inequalities into nonpositive differences and match those differences.
    rw [← sub_nonpos] at h
    rw [← sub_nonpos, ← hdiff]
    exact h
  · intro h
    rw [← sub_nonpos] at h
    rw [← sub_nonpos, hdiff]
    exact h

/-- At finite endpoints and a finite convex combination, the `subNormSq` weighted inequality agrees
with the additive quadratic-modulus inequality. -/
private lemma subNormSq_convexCombo_le_iff {E : Type*} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] (β : ℝ) (f : E → EReal) {x y : E} {t : ℝ}
    (hx : x ∈ effectiveDomain f) (hy : y ∈ effectiveDomain f)
    (hz : t • x + (1 - t) • y ∈ effectiveDomain f) :
    subNormSq β f (t • x + (1 - t) • y) ≤
        (t : EReal) * subNormSq β f x + ((1 - t) : EReal) * subNormSq β f y ↔
      f (t • x + (1 - t) • y) +
          ((t * (1 - t) * (β / 2) * ‖x - y‖ ^ 2 : ℝ) : EReal) ≤
        (t : EReal) * f x + ((1 - t) : EReal) * f y := by
  -- Descend both comparisons to `ℝ`, then replace the quadratic gap by the modulus.
  rw [subNormSq_weighted_le_iff hx hy hz,
    add_coe_le_weighted_iff_toReal hx hy hz t (t * (1 - t) * (β / 2) * ‖x - y‖ ^ 2),
    weightedSub_le_iff_add_gap t (f x).toReal (f y).toReal (f (t • x + (1 - t) • y)).toReal
      (β / 2 * ‖x‖ ^ 2) (β / 2 * ‖y‖ ^ 2) (β / 2 * ‖t • x + (1 - t) • y‖ ^ 2),
    convexCombo_quadraticGap β x y t]

/-- An open convex combination of `subNormSq β f` lies below the weighted sum when one endpoint
value is `⊤`. -/
private lemma subNormSq_convexCombo_le_of_top {E : Type*} [NormedAddCommGroup E]
    [NormedSpace ℝ E] (β : ℝ)
    (f : E → EReal) (hbot : ∀ x, ⊥ < f x) {x y : E} {α : ℝ} (hα : α ∈ Set.Ioo (0 : ℝ) 1)
    (htop : f x = ⊤ ∨ f y = ⊤) :
    subNormSq β f (α • x + (1 - α) • y) ≤
      (α : EReal) * subNormSq β f x + ((1 - α) : EReal) * subNormSq β f y := by
  -- Open weights are positive, so a top endpoint forces the weighted sum to be `⊤`.
  have hα0 : 0 < α := hα.1
  have hα1 : 0 < 1 - α := sub_pos.mpr hα.2
  have hmul_ne_bot {a : ℝ} {z : E} (ha : 0 < a) : (a : EReal) * subNormSq β f z ≠ ⊥ := by
    rcases eq_or_ne (f z) ⊤ with htopz | hfin
    · unfold subNormSq
      rw [htopz, EReal.top_sub_coe, EReal.coe_mul_top_of_pos ha]
      exact ne_of_gt (bot_lt_top : (⊥ : EReal) < ⊤)
    · have hz : z ∈ effectiveDomain f := by
        rw [effectiveDomain_eq_lt_top hbot, Set.mem_setOf_eq]
        exact lt_top_iff_ne_top.mpr hfin
      rw [subNormSq_eq_coe_toReal_sub hz, ← EReal.coe_mul]
      exact EReal.coe_ne_bot _
  rcases htop with hx | hy
  · have hxTop : subNormSq β f x = ⊤ := by
      unfold subNormSq
      rw [hx, EReal.top_sub_coe]
    -- Normalize `1 - ↑α` to the coercion `↑(1 - α)` before the top-addition lemma.
    rw [hxTop, EReal.coe_mul_top_of_pos hα0, ← EReal.coe_one, ← EReal.coe_sub,
      EReal.top_add_of_ne_bot (hmul_ne_bot hα1)]
    exact le_top
  · have hyTop : subNormSq β f y = ⊤ := by
      unfold subNormSq
      rw [hy, EReal.top_sub_coe]
    rw [hyTop, ← EReal.coe_one, ← EReal.coe_sub, EReal.coe_mul_top_of_pos hα1,
      EReal.add_top_of_ne_bot (hmul_ne_bot hα0)]
    exact le_top

/-- `leCombo_Ioo_iff_convex_subNormSq`. Let `E` be a real inner product space, let `0 < β`, and let `f : E → EReal` satisfy
`∀ x, ⊥ < f x` with `(effectiveDomain f).Nonempty`. The open additive inequality
`f (α • x + (1 - α) • y) + ((α * (1 - α) * (β / 2) * ‖x - y‖ ^ 2 : ℝ) : EReal) ≤
(α : EReal) * f x + ((1 - α) : EReal) * f y` holds for every `x, y ∈ effectiveDomain f` and
every `α ∈ Set.Ioo (0 : ℝ) 1` if and only if `subNormSq β f` satisfies
`subNormSq β f (α • x + (1 - α) • y) ≤ (α : EReal) * subNormSq β f x +
((1 - α) : EReal) * subNormSq β f y` for every `x y : E` and every such `α`.
`subNormSq β f x = f x - ((β / (2 : ℝ) * ‖x‖ ^ 2 : ℝ) : EReal)`. -/
theorem leCombo_Ioo_iff_convex_subNormSq {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] (β : ℝ) (f : E → EReal) (hβ : 0 < β) (hbot : ∀ x, ⊥ < f x)
    (hdom : (effectiveDomain f).Nonempty) :
    (∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ α ∈ Set.Ioo (0 : ℝ) 1,
        f (α • x + (1 - α) • y) +
            ((α * (1 - α) * (β / 2) * ‖x - y‖ ^ 2 : ℝ) : EReal) ≤
          (α : EReal) * f x + ((1 - α) : EReal) * f y) ↔
      (∀ x y : E, ∀ α ∈ Set.Ioo (0 : ℝ) 1,
        subNormSq β f (α • x + (1 - α) • y) ≤
          (α : EReal) * subNormSq β f x + ((1 - α) : EReal) * subNormSq β f y) := by
  constructor
  · intro hstrong x y α hα
    -- A top endpoint makes the weighted quadratic shift `⊤`.
    rcases eq_or_ne (f x) ⊤ with hx | hx
    · exact subNormSq_convexCombo_le_of_top β f hbot hα (Or.inl hx)
    rcases eq_or_ne (f y) ⊤ with hy | hy
    · exact subNormSq_convexCombo_le_of_top β f hbot hα (Or.inr hy)
    have hxmem : x ∈ effectiveDomain f := by
      rw [effectiveDomain_eq_lt_top hbot, Set.mem_setOf_eq]
      exact lt_top_iff_ne_top.mpr hx
    have hymem : y ∈ effectiveDomain f := by
      rw [effectiveDomain_eq_lt_top hbot, Set.mem_setOf_eq]
      exact lt_top_iff_ne_top.mpr hy
    have hle := hstrong x hxmem y hymem α hα
    -- The weighted right-hand side is a real coercion, so the combination cannot be `⊤`.
    have hrhs_ne : (α : EReal) * f x + ((1 - α) : EReal) * f y ≠ ⊤ := by
      rw [mem_effectiveDomain] at hxmem hymem
      rw [← EReal.coe_toReal (ne_of_lt hxmem.2) (ne_of_gt hxmem.1),
        ← EReal.coe_toReal (ne_of_lt hymem.2) (ne_of_gt hymem.1),
        ← EReal.coe_mul, ← EReal.coe_one, ← EReal.coe_sub, ← EReal.coe_mul, ← EReal.coe_add]
      exact EReal.coe_ne_top _
    have hcomb_ne : f (α • x + (1 - α) • y) ≠ ⊤ := by
      intro htop
      rw [htop, EReal.top_add_coe] at hle
      exact hrhs_ne (top_le_iff.mp hle)
    have hcomb : α • x + (1 - α) • y ∈ effectiveDomain f := by
      rw [mem_effectiveDomain]
      exact ⟨hbot _, lt_top_iff_ne_top.mpr hcomb_ne⟩
    exact (subNormSq_convexCombo_le_iff β f hxmem hymem hcomb).mpr hle
  · intro hsub x hx y hy α hα
    have hle := hsub x y α hα
    -- Finite endpoints make the weighted `subNormSq` sum a real coercion.
    have hrhs_ne :
        (α : EReal) * subNormSq β f x + ((1 - α) : EReal) * subNormSq β f y ≠ ⊤ := by
      rw [subNormSq_eq_coe_toReal_sub hx, subNormSq_eq_coe_toReal_sub hy, ← EReal.coe_mul,
        ← EReal.coe_one, ← EReal.coe_sub, ← EReal.coe_mul, ← EReal.coe_add]
      exact EReal.coe_ne_top _
    have hshift_ne : subNormSq β f (α • x + (1 - α) • y) ≠ ⊤ := by
      intro htop
      rw [htop] at hle
      exact hrhs_ne (top_le_iff.mp hle)
    have hcomb_ne : f (α • x + (1 - α) • y) ≠ ⊤ := by
      intro htop
      unfold subNormSq at hshift_ne
      rw [htop, EReal.top_sub_coe] at hshift_ne
      exact hshift_ne rfl
    have hcomb : α • x + (1 - α) • y ∈ effectiveDomain f := by
      rw [mem_effectiveDomain]
      exact ⟨hbot _, lt_top_iff_ne_top.mpr hcomb_ne⟩
    exact (subNormSq_convexCombo_le_iff β f hx hy hcomb).mp hle
