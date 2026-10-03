import ReasLibDemo.Sources.Bauschke.Proposition2313_Resolvent
noncomputable section
set_option autoImplicit false
universe u
example : {E : Type u} →
  [inst : NormedAddCommGroup.{u} E] →
    [inst_1 :
        @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)] →
      (A : E → Set.{u} E) → (z : @Set.Elem.{u} E (@resolventDomain.{u} E inst inst_1 A)) → E := @operatorResolvent
example : @operatorResolvent = (fun {E : Type u} [inst : NormedAddCommGroup.{u} E]
    [inst_1 :
      @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
    (A : E → Set.{u} E) (z : @Set.Elem.{u} E (@resolventDomain.{u} E inst inst_1 A)) =>
  @Classical.choose.{u + 1} E
    (fun (x : E) =>
      @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@idAdd.{u} E inst inst_1 A x)
        (@Subtype.val.{u + 1} E
          (fun (x : E) =>
            @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@resolventDomain.{u} E inst inst_1 A) x)
          z))
    (@operatorResolvent._proof_1.{u} E inst inst_1 A z)) := rfl
