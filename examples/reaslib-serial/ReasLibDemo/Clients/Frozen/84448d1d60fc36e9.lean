import ReasLibDemo.Sources.Bauschke.Example224iv_StronglyMonotone
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  (β : Real) (A : E → Set.{u} E),
  Iff (@StronglyMonotone.{u} E inst inst_1 β A)
    (∀ (x y u v : E),
      @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (A x) u →
        @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (A y) v →
          @LE.le.{0} Real Real.instLE
            (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul) β
              (@HPow.hPow.{0, 0, 0} Real Nat Real (@instHPow.{0, 0} Real Nat (@Monoid.toPow.{0} Real Real.instMonoid))
                (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst)
                  (@HSub.hSub.{u, u, u} E E E
                    (@instHSub.{u} E
                      (@SubNegMonoid.toSub.{u} E
                        (@AddGroup.toSubNegMonoid.{u} E
                          (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                    x y))
                (@OfNat.ofNat.{0} Nat (nat_lit 2) (instOfNatNat (nat_lit 2)))))
            (@Inner.inner.{0, u} Real E
              (@InnerProductSpace.toInner.{0, u} Real E Real.instRCLike
                (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
              (@HSub.hSub.{u, u, u} E E E
                (@instHSub.{u} E
                  (@SubNegMonoid.toSub.{u} E
                    (@AddGroup.toSubNegMonoid.{u} E
                      (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                x y)
              (@HSub.hSub.{u, u, u} E E E
                (@instHSub.{u} E
                  (@SubNegMonoid.toSub.{u} E
                    (@AddGroup.toSubNegMonoid.{u} E
                      (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                u v))) := @stronglyMonotone_iff
