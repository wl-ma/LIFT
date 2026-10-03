import ReasLib
import Downstream.Definitions

universe u

/-- A global minimizer of an extended-real function is finite whenever any value is finite. -/
private lemma isMinOn_univ_lt_top {α : Type*} {f : α → EReal} {xStar x : α}
    (hxStar : IsMinOn f Set.univ xStar) (hx : f x < ⊤) : f xStar < ⊤ := by
  -- Global minimality compares the minimizer with the given finite value.
  rw [isMinOn_univ_iff] at hxStar
  exact lt_of_le_of_lt (hxStar x) hx

/-- A weighted sum of two finite extended reals, minus a real, is the coercion of that real
expression. -/
private lemma weightedSub_coe_eq {a b : EReal} {t c : ℝ} (ha_top : a ≠ ⊤) (ha_bot : a ≠ ⊥)
    (hb_top : b ≠ ⊤) (hb_bot : b ≠ ⊥) :
    (t : EReal) * a + ((1 - t : ℝ) : EReal) * b - (c : EReal) =
      ↑(t * a.toReal + (1 - t) * b.toReal - c) := by
  -- Finite extended reals are coercions of their real parts; the remaining arithmetic is real.
  conv =>
    lhs
    rw [← EReal.coe_toReal ha_top ha_bot, ← EReal.coe_toReal hb_top hb_bot,
      ← EReal.coe_mul t a.toReal, ← EReal.coe_mul (1 - t) b.toReal,
      ← EReal.coe_add (t * a.toReal) ((1 - t) * b.toReal),
      ← EReal.coe_sub (t * a.toReal + (1 - t) * b.toReal) c]

/-- Cancelling a positive weight turns a convex-combination deficit into a slack lower bound. -/
private lemma le_of_weightedMinDeficit {a b c t : ℝ} (ht : 0 < t)
    (h : a ≤ t * b + (1 - t) * a - t * (1 - t) * c) : a + (1 - t) * c ≤ b := by
  -- The two copies of `a` combine into the factor `t`, which is then cancelled.
  have hfac : t * a ≤ t * (b - (1 - t) * c) := by
    linarith
  have hcancel : a ≤ b - (1 - t) * c := le_of_mul_le_mul_left hfac ht
  exact le_sub_iff_add_le.mp hcancel

/-- A nonnegative increment that is almost attained for every open unit weight is fully attained. -/
private lemma le_add_of_forall_Ioo_slack {a b c : ℝ} (hc : 0 ≤ c)
    (h : ∀ t, 0 < t → t < 1 → a + (1 - t) * c ≤ b) : a + c ≤ b := by
  -- Any positive error absorbs the missing piece `t * c` for a sufficiently small weight.
  refine le_of_forall_pos_lt_add fun ε hε => ?_
  obtain ⟨s, hs0, hsε⟩ := exists_pos_mul_lt hε c
  let t : ℝ := min s ((1 : ℝ) / 2)
  have ht0 : 0 < t := lt_min hs0 one_half_pos
  have ht1 : t < 1 := (min_le_right s ((1 : ℝ) / 2)).trans_lt one_half_lt_one
  have htc : t * c < ε := by
    -- Shrinking the weight does not increase the product, because `c` is nonnegative.
    have hsε' : s * c < ε := by
      rw [mul_comm]
      exact hsε
    exact (mul_le_mul_of_nonneg_right (min_le_left s ((1 : ℝ) / 2)) hc).trans_lt hsε'
  have hbound : a + (1 - t) * c ≤ b := h t ht0 ht1
  calc
    a + c = a + (1 - t) * c + t * c := by ring
    _ ≤ b + t * c := add_le_add_left hbound (t * c)
    _ < b + ε := add_lt_add_right htc b

section
variable {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- Real parts along an open segment from a domain point to a global minimizer retain a slack
quadratic strong-convexity gap. -/
private lemma toReal_le_of_isMinOn_stronglyConvex {f : E → EReal} {σ : ℝ}
    (hf : is_strongly_convex_function f σ) {xStar x : E} (hxStar : IsMinOn f Set.univ xStar)
    (hx : x ∈ effective_domain f) {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) :
    (f xStar).toReal + (1 - t) * ((σ / 2) * ‖x - xStar‖ ^ (2 : ℕ)) ≤ (f x).toReal := by
  -- Both endpoint values are finite, so later coercions to `ℝ` are valid.
  have hx_lt : f x < ⊤ := hx
  have hxStar_lt : f xStar < ⊤ := isMinOn_univ_lt_top hxStar hx_lt
  have hx_ne_top : f x ≠ ⊤ := ne_of_lt hx_lt
  have hxStar_ne_top : f xStar ≠ ⊤ := ne_of_lt hxStar_lt
  have hx_ne_bot : f x ≠ ⊥ := hf.ne_bot x
  have hxStar_ne_bot : f xStar ≠ ⊥ := hf.ne_bot xStar
  have hxStar_mem : xStar ∈ effective_domain f := hxStar_lt
  have htIcc : t ∈ Set.Icc (0 : ℝ) 1 := ⟨ht0.le, ht1.le⟩
  -- Minimality bounds the segment value, and strong convexity expands that segment.
  have hmin : f xStar ≤ f (t • x + (1 - t) • xStar) := by
    rw [isMinOn_univ_iff] at hxStar
    exact hxStar _
  have hchain := hmin.trans (hf.segment_ineq hx hxStar_mem htIcc)
  have hreal :
      (f xStar).toReal ≤
        t * (f x).toReal + (1 - t) * (f xStar).toReal -
          (σ / 2) * t * (1 - t) * ‖x - xStar‖ ^ (2 : ℕ) := by
    -- The weighted deficit is finite, so the extended-real comparison is a real comparison.
    rw [weightedSub_coe_eq hx_ne_top hx_ne_bot hxStar_ne_top hxStar_ne_bot] at hchain
    conv at hchain =>
      lhs
      rw [← EReal.coe_toReal hxStar_ne_top hxStar_ne_bot]
    exact EReal.coe_le_coe_iff.mp hchain
  -- Commute the modulus past the convex weights `t` and `1 - t`.
  have hcoeff :
      (σ / 2) * t * (1 - t) * ‖x - xStar‖ ^ (2 : ℕ) =
        t * (1 - t) * ((σ / 2) * ‖x - xStar‖ ^ (2 : ℕ)) := by
    rw [mul_comm (σ / 2) t, mul_assoc t (σ / 2) (1 - t), mul_comm (σ / 2) (1 - t),
      ← mul_assoc t (1 - t) (σ / 2),
      mul_assoc (t * (1 - t)) (σ / 2) (‖x - xStar‖ ^ (2 : ℕ))]
  rw [hcoeff] at hreal
  exact le_of_weightedMinDeficit ht0 hreal

/-- `lower_quadratic_bound_of_isMinOn_of_strongly_convex`. If `xStar` is a global minimizer of a
`σ`-strongly convex function `f : E → EReal`, then every `x` in `effective_domain f` satisfies
`f x ≥ f xStar + ((σ / 2) * ‖x - xStar‖ ^ (2 : ℕ) : EReal)`. -/
theorem lower_quadratic_bound_of_isMinOn_of_strongly_convex
    {f : E → EReal} {σ : ℝ} (hf : is_strongly_convex_function f σ)
    (xStar : E) (hxStar : IsMinOn f Set.univ xStar) (x : E) (hx : x ∈ effective_domain f) :
    f x ≥ f xStar + ((((σ / 2) * ‖x - xStar‖ ^ (2 : ℕ)) : ℝ) : EReal) := by
  -- Remove the open-weight slack, then lift the resulting real inequality back to `EReal`.
  set c : ℝ := (σ / 2) * ‖x - xStar‖ ^ (2 : ℕ)
  have hc : 0 ≤ c :=
    mul_nonneg (div_nonneg hf.sigma_pos.le zero_le_two) (pow_nonneg (norm_nonneg _) 2)
  have hslack : ∀ t, 0 < t → t < 1 → (f xStar).toReal + (1 - t) * c ≤ (f x).toReal := by
    intro t ht0 ht1
    exact toReal_le_of_isMinOn_stronglyConvex hf hxStar hx ht0 ht1
  have hreal : (f xStar).toReal + c ≤ (f x).toReal := le_add_of_forall_Ioo_slack hc hslack
  have hx_lt : f x < ⊤ := hx
  have hxStar_lt : f xStar < ⊤ := isMinOn_univ_lt_top hxStar hx_lt
  -- Rewrite only the minimizer, so `toReal` on the right is not rewritten again.
  have hcoeStar : ((f xStar).toReal : EReal) = f xStar :=
    EReal.coe_toReal (ne_of_lt hxStar_lt) (hf.ne_bot xStar)
  calc
    f xStar + (c : EReal) = ↑(f xStar).toReal + (c : EReal) := by
      conv =>
        lhs
        rw [← hcoeStar]
    _ = ↑((f xStar).toReal + c) := by
      rw [← EReal.coe_add]
    _ ≤ ↑(f x).toReal := EReal.coe_le_coe_iff.mpr hreal
    _ = f x := EReal.coe_toReal (ne_of_lt hx_lt) (hf.ne_bot x)

end
