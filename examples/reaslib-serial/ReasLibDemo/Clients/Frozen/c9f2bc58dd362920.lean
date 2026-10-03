import ReasLibDemo.Sources.Bauschke.Proposition2313_Resolvent
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {A : E → Set.{u} E}
  (hA :
    @StronglyMonotone.{u} E inst inst_1 (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) A)
  {z x : E}
  (hx :
    @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (A x)
      (@HSub.hSub.{u, u, u} E E E
        (@instHSub.{u} E
          (@SubNegMonoid.toSub.{u} E
            (@AddGroup.toSubNegMonoid.{u} E
              (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
        z x))
  (hz : @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@resolventDomain.{u} E inst inst_1 A) z),
  @Eq.{u + 1} E
    (@operatorResolvent.{u} E inst inst_1 A
      (@Subtype.mk.{u + 1} E
        (fun (x : E) =>
          @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@resolventDomain.{u} E inst inst_1 A) x)
        z hz))
    x := @resolvent_eq_of_sub_mem
