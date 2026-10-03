import ReasLibDemo.Sources.Beck.Example521_Indicator
noncomputable section
set_option autoImplicit false
universe u
example : {α : Type u} → (C : Set.{u} α) → α → EReal := @erealIndicator
example : @erealIndicator = (fun {α : Type u} (C : Set.{u} α) (x : α) =>
  @dite.{1} EReal (@Membership.mem.{u, u} α (Set.{u} α) (@Set.instMembership.{u} α) C x)
    (Classical.propDecidable (@Membership.mem.{u, u} α (Set.{u} α) (@Set.instMembership.{u} α) C x))
    (fun (x : @Membership.mem.{u, u} α (Set.{u} α) (@Set.instMembership.{u} α) C x) =>
      @OfNat.ofNat.{0} EReal (nat_lit 0) (@Zero.toOfNat0.{0} EReal instZeroEReal))
    fun (x : Not (@Membership.mem.{u, u} α (Set.{u} α) (@Set.instMembership.{u} α) C x)) =>
    @Top.top.{0} EReal instTopEReal) := rfl
