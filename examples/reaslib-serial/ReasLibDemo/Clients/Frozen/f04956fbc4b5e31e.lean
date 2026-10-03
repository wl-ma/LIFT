import ReasLibDemo.Sources.Beck.Example521_Indicator
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {α : Type u} {C : Set.{u} α} {x : α} (hx : @Membership.mem.{u, u} α (Set.{u} α) (@Set.instMembership.{u} α) C x),
  @Eq.{1} EReal (@erealIndicator.{u} α C x)
    (@OfNat.ofNat.{0} EReal (nat_lit 0) (@Zero.toOfNat0.{0} EReal instZeroEReal)) := @erealIndicator_of_mem
