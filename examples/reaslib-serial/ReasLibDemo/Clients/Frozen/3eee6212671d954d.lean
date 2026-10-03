import ReasLibDemo.Sources.Beck.Example521_Indicator
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {α : Type u} {C : Set.{u} α} {x : α},
  Iff
    (@Membership.mem.{u, u} α (Set.{u} α) (@Set.instMembership.{u} α) (@effectiveDomain.{u} α (@erealIndicator.{u} α C))
      x)
    (@Membership.mem.{u, u} α (Set.{u} α) (@Set.instMembership.{u} α) C x) := @mem_effectiveDomain_erealIndicator
