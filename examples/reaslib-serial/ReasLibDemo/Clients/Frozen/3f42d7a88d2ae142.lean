import ReasLibDemo.Sources.Bauschke.Example224iv_Subdifferential
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {f : E → EReal} {x : E}
  (hx : Not (@Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@effectiveDomain.{u} E f) x)),
  @Eq.{u + 1} (Set.{u} E) (@subdifferential.{u} E inst inst_1 f x)
    (@EmptyCollection.emptyCollection.{u} (Set.{u} E) (@Set.instEmptyCollection.{u} E)) := @subdifferential_eq_empty_of_notMem_effectiveDomain
