import ReasLibDemo.Sources.Bauschke.Proposition2313_Resolvent
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {A : E → Set.{u} E} (z : @Set.Elem.{u} E (@resolventDomain.{u} E inst inst_1 A)),
  @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (A (@operatorResolvent.{u} E inst inst_1 A z))
    (@HSub.hSub.{u, u, u} E E E
      (@instHSub.{u} E
        (@SubNegMonoid.toSub.{u} E
          (@AddGroup.toSubNegMonoid.{u} E
            (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
      (@Subtype.val.{u + 1} E
        (fun (x : E) =>
          @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@resolventDomain.{u} E inst inst_1 A) x)
        z)
      (@operatorResolvent.{u} E inst inst_1 A z)) := @resolvent_spec
