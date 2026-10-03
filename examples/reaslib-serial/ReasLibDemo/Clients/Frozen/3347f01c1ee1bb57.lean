import ReasLibDemo.Sources.Synthesis.C1ERealBridge
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {α : Type u} (f : α → Real),
  @Eq.{u + 1} (Set.{u} α) (@effectiveDomain.{u} α fun (x : α) => Real.toEReal (f x)) (@Set.univ.{u} α) := @effectiveDomain_coe_eq_univ
