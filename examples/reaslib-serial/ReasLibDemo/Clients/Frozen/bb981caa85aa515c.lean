import ReasLibDemo.Sources.Beck.Example521_Indicator
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {α : Type u} {C : Set.{u} α} {x : α}
  (hx : Not (@Membership.mem.{u, u} α (Set.{u} α) (@Set.instMembership.{u} α) C x)),
  @Eq.{1} EReal (@erealIndicator.{u} α C x) (@Top.top.{0} EReal instTopEReal) := @erealIndicator_of_notMem
