import ReasLibDemo.Sources.Bauschke.Proposition2313_Resolvent
noncomputable section
set_option autoImplicit false
universe u_1
example : ∀ {E : Type u_1} [inst : NormedAddCommGroup.{u_1} E]
  [inst_1 :
    @InnerProductSpace.{0, u_1} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u_1} E inst)]
  (A : E → Set.{u_1} E) (z : @Set.Elem.{u_1} E (@resolventDomain.{u_1} E inst inst_1 A)),
  @Exists.{u_1 + 1} E fun (i : E) =>
    @Membership.mem.{u_1, u_1} E (Set.{u_1} E) (@Set.instMembership.{u_1} E) (@idAdd.{u_1} E inst inst_1 A i)
      (@Subtype.val.{u_1 + 1} E
        (fun (x : E) =>
          @Membership.mem.{u_1, u_1} E (Set.{u_1} E) (@Set.instMembership.{u_1} E)
            (@resolventDomain.{u_1} E inst inst_1 A) x)
        z) := @operatorResolvent._proof_1
