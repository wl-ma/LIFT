module

public import ReasLib.Analysis.Convex.EffectiveDomain
public import ReasLib.Analysis.Convex.Strong
public import ReasLib.Analysis.InnerProductSpace.StronglyMonotone
public import Mathlib.Data.EReal.Operations

@[expose] public section

open scoped InnerProductSpace

universe u

/-- The subdifferential of an extended-real function `f` at `x` is the set of vectors `u` for which
`x` lies in `effectiveDomain f` and `f` satisfies the global supporting inequality
`f x + (⟪u, z - x⟫_ℝ : EReal) ≤ f z` at every `z`. -/
def subdifferential {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (f : E → EReal) : E → Set E :=
  fun x ↦ {u | x ∈ effectiveDomain f ∧ ∀ z, f x + (⟪u, z - x⟫_ℝ : EReal) ≤ f z}

/-- Membership in `subdifferential f x` is effective-domain membership of `x` together with the
global supporting inequality. -/
theorem mem_subdifferential {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {f : E → EReal} {x u : E} :
    u ∈ subdifferential f x ↔
      x ∈ effectiveDomain f ∧ ∀ z, f x + (⟪u, z - x⟫_ℝ : EReal) ≤ f z :=
  Iff.rfl

/-- The subdifferential is empty at any point outside `effectiveDomain f`. -/
theorem subdifferential_eq_empty_of_notMem_effectiveDomain {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {f : E → EReal} {x : E} (hx : x ∉ effectiveDomain f) :
    subdifferential f x = ∅ :=
  Set.eq_empty_iff_forall_notMem.mpr fun _ hu => hx (mem_subdifferential.mp hu).1

/-- If `u` supports `f` at `x` and `z` lies in `effectiveDomain f`, the supporting inequality
descends to real parts: `(f x).toReal + ⟪u, z - x⟫_ℝ ≤ (f z).toReal`. -/
private lemma toReal_add_inner_le_of_mem_subdifferential {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {f : E → EReal} {x z u : E} (hu : u ∈ subdifferential f x)
    (hz : z ∈ effectiveDomain f) :
    (f x).toReal + ⟪u, z - x⟫_ℝ ≤ (f z).toReal := by
  -- Subgradient membership puts `x` in the effective domain, so both values are finite.
  have hx : x ∈ effectiveDomain f := (mem_subdifferential.mp hu).1
  rw [mem_effectiveDomain] at hx hz
  have hsupp : f x + (⟪u, z - x⟫_ℝ : EReal) ≤ f z := (mem_subdifferential.mp hu).2 z
  -- Rewrite the finite extended-real values as coercions, then compare the real parts.
  rw [← EReal.coe_toReal (ne_of_lt hx.2) (ne_of_gt hx.1),
    ← EReal.coe_toReal (ne_of_lt hz.2) (ne_of_gt hz.1), ← EReal.coe_add] at hsupp
  exact EReal.coe_le_coe_iff.mp hsupp

/-- The displacement from the second endpoint of a two-point convex combination is the first
weight times the step between the endpoints. -/
private lemma convexCombo_sub {E : Type*} [AddCommGroup E] [Module ℝ E] (t : ℝ) (z x : E) :
    t • z + (1 - t) • x - x = t • (z - x) := by
  -- Expand the complementary weight, cancel the base point, and factor the step.
  calc
    t • z + (1 - t) • x - x
        = t • z + ((1 : ℝ) • x - t • x) - x := by rw [sub_smul]
    _ = t • z + (x - t • x) - x := by rw [one_smul]
    _ = t • z + x - t • x - x := by rw [← add_sub_assoc]
    _ = t • z - t • x + x - x := by rw [add_sub_right_comm]
    _ = t • z - t • x := by rw [add_sub_cancel_right]
    _ = t • (z - x) := by rw [← smul_sub]

/-- A real bound `a ≤ b + t * c` for every weight `t` in the open unit interval forces `a ≤ b`. -/
private lemma le_of_forall_mem_Ioo_add_mul {a b c : ℝ}
    (h : ∀ t ∈ Set.Ioo (0 : ℝ) 1, a ≤ b + t * c) : a ≤ b := by
  classical
  -- A nonpositive slope is already bounded at the midpoint; a positive slope is beaten by a
  -- sufficiently small weight.
  by_cases hc : 0 < c
  · by_contra hba
    have hgap : 0 < a - b := sub_pos.mpr (lt_of_not_ge hba)
    have hc0 : c ≠ 0 := hc.ne'
    have htwo : 0 < 2 * c := mul_pos two_pos hc
    set t : ℝ := min ((a - b) / (2 * c)) (1 / 2)
    have ht0 : 0 < t := lt_min (div_pos hgap htwo) (div_pos one_pos two_pos)
    have ht1 : t < 1 := (min_le_right _ _).trans_lt ((div_lt_one two_pos).mpr one_lt_two)
    have ht_mem : t ∈ Set.Ioo (0 : ℝ) 1 := ⟨ht0, ht1⟩
    have hscale : ((a - b) / (2 * c)) * c = (a - b) / 2 := by
      calc
        ((a - b) / (2 * c)) * c
            = (a - b) * c / (2 * c) := div_mul_eq_mul_div₀ (a - b) c (2 * c)
        _ = c * (a - b) / (c * 2) := by rw [mul_comm (a - b) c, mul_comm (2 : ℝ) c]
        _ = (a - b) / 2 := mul_div_mul_left (a - b) (2 : ℝ) hc0
    have htc : t * c ≤ (a - b) / 2 := by
      have hle : t * c ≤ ((a - b) / (2 * c)) * c :=
        mul_le_mul_of_nonneg_right (min_le_left _ _) hc.le
      rwa [hscale] at hle
    have hgap_le : a - b ≤ (a - b) / 2 := (sub_le_iff_le_add'.mpr (h t ht_mem)).trans htc
    have hnonpos : (a - b) / 2 ≤ 0 := by
      have hsub : (a - b) - (a - b) / 2 ≤ 0 := sub_nonpos.mpr hgap_le
      have heq : (a - b) - (a - b) / 2 = (a - b) / 2 := by
        rw [sub_eq_iff_eq_add, ← two_mul ((a - b) / 2)]
        exact (mul_div_cancel₀ (a - b) two_ne_zero).symm
      rwa [heq] at hsub
    exact not_lt_of_ge hnonpos (div_pos hgap two_pos)
  · have hcle : c ≤ 0 := le_of_not_gt hc
    have ht_mem : (1 / 2 : ℝ) ∈ Set.Ioo (0 : ℝ) 1 :=
      ⟨div_pos one_pos two_pos, (div_lt_one two_pos).mpr one_lt_two⟩
    have hmul : (1 / 2 : ℝ) * c ≤ 0 :=
      mul_nonpos_of_nonneg_of_nonpos (div_pos one_pos two_pos).le hcle
    have hstep : b + (1 / 2) * c ≤ b := by
      calc
        b + (1 / 2) * c = (1 / 2) * c + b := add_comm _ _
        _ ≤ 0 + b := add_le_add_left hmul b
        _ = b := zero_add b
    exact (h (1 / 2) ht_mem).trans hstep

/-- A subgradient of a `β`-strongly convex extended-real function satisfies the quadratic lower
bound `(f x).toReal + ⟪u, z - x⟫_ℝ + β / 2 * ‖z - x‖ ^ 2 ≤ (f z).toReal` on the effective
domain. -/
lemma StrongConvex.le_toReal_add_sq_of_mem_subdifferential {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {β : ℝ} {f : E → EReal} (hf : StrongConvex β f) {x z u : E}
    (hu : u ∈ subdifferential f x) (hz : z ∈ effectiveDomain f) :
    (f x).toReal + ⟪u, z - x⟫_ℝ + β / 2 * ‖z - x‖ ^ 2 ≤ (f z).toReal := by
  -- Real strong convexity is the quadratic deficit of `(f ·).toReal` on the effective domain.
  have hsc : StrongConvexOn (effectiveDomain f) β (fun w ↦ (f w).toReal) :=
    (strongConvex_iff_strongConvexOn.mp hf).2.2
  unfold StrongConvexOn UniformConvexOn at hsc
  have hx : x ∈ effectiveDomain f := (mem_subdifferential.mp hu).1
  -- Every open-segment weight leaves a remainder proportional to the weight, so the remainder
  -- vanishes in the limit.
  refine le_of_forall_mem_Ioo_add_mul (c := β / 2 * ‖z - x‖ ^ 2) fun t ht => ?_
  have ht0 : 0 < t := ht.1
  have hs : 0 ≤ 1 - t := sub_nonneg.mpr ht.2.le
  have hsum : t + (1 - t) = 1 := add_sub_cancel t 1
  set quad : ℝ := β / 2 * ‖z - x‖ ^ 2
  -- The free point carries weight `t`, so dividing by `t` retains the modulus `β / 2`.
  have hzt : t • z + (1 - t) • x ∈ effectiveDomain f :=
    (convex_iff_add_mem.mp hsc.1) hz hx ht0.le hs hsum
  have hdef :
      (f (t • z + (1 - t) • x)).toReal ≤
        t * (f z).toReal + (1 - t) * (f x).toReal - t * (1 - t) * quad := by
    simpa [quad, smul_eq_mul] using hsc.2 hz hx ht0.le hs hsum
  have hsupp :
      (f x).toReal + t * ⟪u, z - x⟫_ℝ ≤ (f (t • z + (1 - t) • x)).toReal := by
    -- The segment displacement is the scaled step, so the supporting inner product scales by `t`.
    simpa [convexCombo_sub, inner_smul_right] using
      toReal_add_inner_le_of_mem_subdifferential hu hzt
  have hineq :
      (f x).toReal + t * ⟪u, z - x⟫_ℝ ≤
        t * (f z).toReal + (1 - t) * (f x).toReal - t * (1 - t) * quad :=
    hsupp.trans hdef
  have hmul :
      t * ((f x).toReal + ⟪u, z - x⟫_ℝ) ≤ t * ((f z).toReal - (1 - t) * quad) := by
    have hleft :
        t * ((f x).toReal + ⟪u, z - x⟫_ℝ) =
          (f x).toReal + t * ⟪u, z - x⟫_ℝ - (1 - t) * (f x).toReal := by
      ring
    have hright :
        t * ((f z).toReal - (1 - t) * quad) =
          t * (f z).toReal + (1 - t) * (f x).toReal - t * (1 - t) * quad -
            (1 - t) * (f x).toReal := by
      ring
    rw [hleft, hright]
    exact sub_le_sub_right hineq ((1 - t) * (f x).toReal)
  have hdiv : (f x).toReal + ⟪u, z - x⟫_ℝ ≤ (f z).toReal - (1 - t) * quad :=
    (mul_le_mul_iff_of_pos_left ht0).mp hmul
  have hshift : (f z).toReal - (1 - t) * quad + quad = (f z).toReal + t * quad := by
    ring
  calc
    (f x).toReal + ⟪u, z - x⟫_ℝ + quad
        ≤ (f z).toReal - (1 - t) * quad + quad := add_le_add_left hdiv quad
    _ = (f z).toReal + t * quad := hshift

/-- Two quadratic bounds with opposite steps add up to the strong-monotonicity inequality
`β * ‖x - y‖ ^ 2 ≤ ⟪x - y, u - v⟫_ℝ`. -/
private lemma inner_sub_le_of_quadratic_bounds {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {β : ℝ} {x y u v : E} {a b : ℝ}
    (hxy : a + ⟪u, y - x⟫_ℝ + β / 2 * ‖y - x‖ ^ 2 ≤ b)
    (hyx : b + ⟪v, x - y⟫_ℝ + β / 2 * ‖x - y‖ ^ 2 ≤ a) :
    β * ‖x - y‖ ^ 2 ≤ ⟪x - y, u - v⟫_ℝ := by
  -- The two quadratic terms agree after reversing the difference, and together they make `β`.
  have hnorm : ‖y - x‖ ^ 2 = ‖x - y‖ ^ 2 := by
    rw [norm_sub_rev y x]
  have htwo (q : ℝ) : β / 2 * q + β / 2 * q = β * q := by
    rw [← add_mul, ← two_mul (β / 2), mul_div_cancel₀ β two_ne_zero]
  have hqq :
      β / 2 * ‖y - x‖ ^ 2 + β / 2 * ‖x - y‖ ^ 2 = β * ‖x - y‖ ^ 2 := by
    rw [hnorm]
    exact htwo (‖x - y‖ ^ 2)
  have hadd := add_le_add hxy hyx
  have hsumEq :
      a + ⟪u, y - x⟫_ℝ + β / 2 * ‖y - x‖ ^ 2 +
          (b + ⟪v, x - y⟫_ℝ + β / 2 * ‖x - y‖ ^ 2) =
        a + b + (⟪u, y - x⟫_ℝ + ⟪v, x - y⟫_ℝ +
          (β / 2 * ‖y - x‖ ^ 2 + β / 2 * ‖x - y‖ ^ 2)) := by
    ring
  have hnonpos : ⟪u, y - x⟫_ℝ + ⟪v, x - y⟫_ℝ + β * ‖x - y‖ ^ 2 ≤ 0 := by
    have hpacked :
        a + b + (⟪u, y - x⟫_ℝ + ⟪v, x - y⟫_ℝ + β * ‖x - y‖ ^ 2) ≤ a + b := by
      -- Reassociate the sum of the two bounds, then cancel the common real values.
      have hbound :
          a + b + (⟪u, y - x⟫_ℝ + ⟪v, x - y⟫_ℝ +
              (β / 2 * ‖y - x‖ ^ 2 + β / 2 * ‖x - y‖ ^ 2)) ≤ b + a := by
        simpa [hsumEq] using hadd
      have hcomm :
          a + b + (⟪u, y - x⟫_ℝ + ⟪v, x - y⟫_ℝ + β * ‖x - y‖ ^ 2) ≤ b + a := by
        simpa [hqq] using hbound
      simpa [add_comm b a] using hcomm
    have hle :
        (a + b) + (⟪u, y - x⟫_ℝ + ⟪v, x - y⟫_ℝ + β * ‖x - y‖ ^ 2) ≤ (a + b) + 0 := by
      simpa [add_zero] using hpacked
    exact (add_le_add_iff_left (a + b)).mp hle
  have hinner : ⟪x - y, u - v⟫_ℝ = -(⟪u, y - x⟫_ℝ + ⟪v, x - y⟫_ℝ) := by
    have hrev : ⟪u, x - y⟫_ℝ = -⟪u, y - x⟫_ℝ := by
      rw [← neg_sub y x, inner_neg_right]
    calc
      ⟪x - y, u - v⟫_ℝ
          = ⟪x - y, u⟫_ℝ - ⟪x - y, v⟫_ℝ := inner_sub_right (x - y) u v
      _ = ⟪u, x - y⟫_ℝ - ⟪v, x - y⟫_ℝ := by
          rw [real_inner_comm (x - y) u, real_inner_comm (x - y) v]
      _ = -⟪u, y - x⟫_ℝ - ⟪v, x - y⟫_ℝ := by rw [hrev]
      _ = -(⟪u, y - x⟫_ℝ + ⟪v, x - y⟫_ℝ) := by ring
  -- Negating the cancelled sum turns the inner-product remainder into the monotonicity inequality.
  rw [hinner]
  linarith

/-- `StrongConvex.subdifferential_stronglyMonotone`. If `f : E → EReal` is proper and `β`-strongly convex, then `subdifferential f` is
`β`-strongly monotone. Properness is `StrongConvex β f` together with a nonempty effective
domain. -/
theorem StrongConvex.subdifferential_stronglyMonotone {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {β : ℝ} {f : E → EReal} (hf : StrongConvex β f)
    (hdom : (effectiveDomain f).Nonempty) : StronglyMonotone β (subdifferential f) := by
  -- Strong monotonicity is the graph inequality on every pair of subgradients.
  intro x y u v hu hv
  -- Properness records that the effective domain is nonempty; only existing subgradients are used.
  have _hdom : (effectiveDomain f).Nonempty := hdom
  have hx : x ∈ effectiveDomain f := (mem_subdifferential.mp hu).1
  have hy : y ∈ effectiveDomain f := (mem_subdifferential.mp hv).1
  -- Add the two quadratic supporting inequalities; the values of `f` cancel.
  exact inner_sub_le_of_quadratic_bounds
    (hf.le_toReal_add_sq_of_mem_subdifferential hu hy)
    (hf.le_toReal_add_sq_of_mem_subdifferential hv hx)

/-- For a proper `β`-strongly convex `f : E → EReal`, every pair of subgradients satisfies
`β * ‖x - y‖ ^ 2 ≤ ⟪x - y, u - v⟫_ℝ`. -/
theorem StrongConvex.le_inner_subdifferential {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {β : ℝ} {f : E → EReal} (hf : StrongConvex β f)
    (hdom : (effectiveDomain f).Nonempty) {x y u v : E} (hu : u ∈ subdifferential f x)
    (hv : v ∈ subdifferential f y) : β * ‖x - y‖ ^ 2 ≤ ⟪x - y, u - v⟫_ℝ :=
  (hf.subdifferential_stronglyMonotone hdom).le_inner hu hv
