module

public import Mathlib.Data.EReal.Operations
public import ReasLib.Analysis.Convex.EffectiveDomain

@[expose] public section

universe u

/-- The extended-real indicator of a set: `0` at points of the set and `⊤` outside it. -/
noncomputable def erealIndicator {α : Type u} (C : Set α) : α → EReal :=
  fun x ↦ @dite EReal (x ∈ C) (Classical.propDecidable (x ∈ C)) (fun _ ↦ 0) (fun _ ↦ ⊤)

/-- `erealIndicator_of_mem`. On the set, the extended-real indicator equals `0`. -/
theorem erealIndicator_of_mem {α : Type u} {C : Set α} {x : α} (hx : x ∈ C) :
    erealIndicator C x = 0 := by
  -- Membership selects the zero branch of the dependent conditional.
  simp only [erealIndicator, dif_pos hx]

/-- Outside the set, the extended-real indicator equals `⊤`. -/
theorem erealIndicator_of_notMem {α : Type u} {C : Set α} {x : α} (hx : x ∉ C) :
    erealIndicator C x = ⊤ := by
  -- Nonmembership selects the top branch of the dependent conditional.
  simp only [erealIndicator, dif_neg hx]

/-- The extended-real indicator never takes the value `⊥`. -/
theorem bot_lt_erealIndicator {α : Type u} (C : Set α) (x : α) :
    ⊥ < erealIndicator C x := by
  -- The indicator is `0` on the set and `⊤` off it, and both values sit strictly above `⊥`.
  by_cases hx : x ∈ C
  · rw [erealIndicator_of_mem hx]
    exact EReal.bot_lt_zero
  · rw [erealIndicator_of_notMem hx]
    exact bot_lt_top

/-- A point lies in the effective domain of the extended-real indicator exactly when it lies in the
set. -/
theorem mem_effectiveDomain_erealIndicator {α : Type u} {C : Set α} {x : α} :
    x ∈ effectiveDomain (erealIndicator C) ↔ x ∈ C := by
  -- Properness turns effective-domain membership into the strict inequality below `⊤`.
  rw [effectiveDomain_eq_lt_top (bot_lt_erealIndicator C), Set.mem_setOf_eq]
  constructor
  · intro hlt
    -- Off the set the indicator is `⊤`, which is not strictly below itself.
    by_contra hx
    rw [erealIndicator_of_notMem hx] at hlt
    exact lt_irrefl _ hlt
  · intro hx
    -- On the set the indicator is `0`, which is strictly below `⊤`.
    rw [erealIndicator_of_mem hx]
    exact EReal.zero_lt_top

