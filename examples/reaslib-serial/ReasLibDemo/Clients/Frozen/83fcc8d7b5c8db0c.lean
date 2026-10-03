import ReasLibDemo.Sources.Bauschke.Proposition2313
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {β : Real} {A : E → Set.{u} E}
  (hA :
    @StronglyMonotone.{u} E inst inst_1 (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) A)
  (hβ : @LT.lt.{0} Real Real.instLT (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) β)
  (hf :
    @Cocoercive.{u} E inst inst_1
      (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd) β
        (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)))
      (@resolventDomain.{u} E inst inst_1 A) (@operatorResolvent.{u} E inst inst_1 A))
  (z w : @Set.Elem.{u} E (@resolventDomain.{u} E inst inst_1 A)),
  @LE.le.{0} Real Real.instLE
    (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst)
      (@HSub.hSub.{u, u, u} E E E
        (@instHSub.{u} E
          (@SubNegMonoid.toSub.{u} E
            (@AddGroup.toSubNegMonoid.{u} E
              (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
        (@operatorResolvent.{u} E inst inst_1 A z) (@operatorResolvent.{u} E inst inst_1 A w)))
    (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
      (@HDiv.hDiv.{0, 0, 0} Real Real Real (@instHDiv.{0} Real (@DivInvMonoid.toDiv.{0} Real Real.instDivInvMonoid))
        (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne))
        (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd) β
          (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne))))
      (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst)
        (@HSub.hSub.{u, u, u} E E E
          (@instHSub.{u} E
            (@SubNegMonoid.toSub.{u} E
              (@AddGroup.toSubNegMonoid.{u} E
                (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
          (@Subtype.val.{u + 1} E
            (fun (x : E) =>
              @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@resolventDomain.{u} E inst inst_1 A) x)
            z)
          (@Subtype.val.{u + 1} E
            (fun (x : E) =>
              @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@resolventDomain.{u} E inst inst_1 A) x)
            w)))) := @resolvent_norm_sub_le_of_cocoercive
