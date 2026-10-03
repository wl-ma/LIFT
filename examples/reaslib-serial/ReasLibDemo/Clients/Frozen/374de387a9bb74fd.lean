import ReasLibDemo.Sources.Bauschke.Example224iv_Subdifferential
noncomputable section
set_option autoImplicit false
universe u
example : {E : Type u} →
  [inst : NormedAddCommGroup.{u} E] →
    [@InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)] →
      (f : E → EReal) → E → Set.{u} E := @subdifferential
example : @subdifferential = (fun {E : Type u} [inst : NormedAddCommGroup.{u} E]
    [inst_1 :
      @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
    (f : E → EReal) (x : E) =>
  @setOf.{u} E fun (u : E) =>
    And (@Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@effectiveDomain.{u} E f) x)
      (∀ (z : E),
        @LE.le.{0} EReal (@Preorder.toLE.{0} EReal (@PartialOrder.toPreorder.{0} EReal instPartialOrderEReal))
          (@HAdd.hAdd.{0, 0, 0} EReal EReal EReal
            (@instHAdd.{0} EReal
              (@AddCommMagma.toAdd.{0} EReal
                (@AddCommSemigroup.toAddCommMagma.{0} EReal
                  (@AddCommMonoid.toAddCommSemigroup.{0} EReal instAddCommMonoidEReal))))
            (f x)
            (Real.toEReal
              (@Inner.inner.{0, u} Real E
                (@InnerProductSpace.toInner.{0, u} Real E Real.instRCLike
                  (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
                u
                (@HSub.hSub.{u, u, u} E E E
                  (@instHSub.{u} E
                    (@SubNegMonoid.toSub.{u} E
                      (@AddGroup.toSubNegMonoid.{u} E
                        (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                  z x))))
          (f z))) := rfl
