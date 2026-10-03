module

public import Mathlib.Data.EReal.Basic

@[expose] public section

universe u

/-- The effective domain of an extended-real function is the set of points at which the value is
finite. -/
def effectiveDomain {E : Type u} (f : E → EReal) : Set E :=
  {x | ⊥ < f x ∧ f x < ⊤}

/-- A point lies in `effectiveDomain f` exactly when the value is strictly above `⊥` and strictly
below `⊤`. -/
@[simp]
lemma mem_effectiveDomain {α : Type*} {f : α → EReal} {x : α} :
    x ∈ effectiveDomain f ↔ ⊥ < f x ∧ f x < ⊤ := by
  rfl

/-- If `f` never takes the value `⊥`, then its effective domain is the set of points strictly
below `⊤`. -/
theorem effectiveDomain_eq_lt_top {α : Type*} {f : α → EReal} (hf : ∀ x, ⊥ < f x) :
    effectiveDomain f = {x | f x < ⊤} := by
  ext x
  rw [mem_effectiveDomain, and_iff_right (hf x)]
  rfl

/-- `effectiveDomain_coe_eq_univ`. The effective domain of a real-valued function coerced pointwise into `EReal` is the whole
carrier. -/
theorem effectiveDomain_coe_eq_univ {α : Type u} (f : α → ℝ) :
    effectiveDomain (fun x ↦ (f x : EReal)) = Set.univ := by
  -- Every coerced real is strictly between `⊥` and `⊤`, so every point is effective.
  rw [Set.eq_univ_iff_forall]
  intro x
  -- Membership is exactly the pair of strict bounds on the coerced value.
  rw [mem_effectiveDomain]
  exact ⟨EReal.bot_lt_coe (f x), EReal.coe_lt_top (f x)⟩
