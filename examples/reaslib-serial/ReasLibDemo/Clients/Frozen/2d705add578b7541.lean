import ReasLibDemo.Sources.Bauschke.Proposition2313_Cocoercive
noncomputable section
set_option autoImplicit false
universe u
example : {E : Type u} →
  [inst : NormedAddCommGroup.{u} E] →
    [@InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)] →
      (β : Real) → {s : Set.{u} E} → (f : @Set.Elem.{u} E s → E) → Prop := @Cocoercive
example : @Cocoercive = (fun {E : Type u} [inst : NormedAddCommGroup.{u} E]
    [inst_1 :
      @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
    (β : Real) {s : Set.{u} E} (f : @Set.Elem.{u} E s → E) =>
  ∀ (z w : @Set.Elem.{u} E s),
    @LE.le.{0} Real Real.instLE
      (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul) β
        (@HPow.hPow.{0, 0, 0} Real Nat Real (@instHPow.{0, 0} Real Nat (@Monoid.toPow.{0} Real Real.instMonoid))
          (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst)
            (@HSub.hSub.{u, u, u} E E E
              (@instHSub.{u} E
                (@SubNegMonoid.toSub.{u} E
                  (@AddGroup.toSubNegMonoid.{u} E
                    (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
              (f z) (f w)))
          (@OfNat.ofNat.{0} Nat (nat_lit 2) (instOfNatNat (nat_lit 2)))))
      (@Inner.inner.{0, u} Real E
        (@InnerProductSpace.toInner.{0, u} Real E Real.instRCLike
          (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
        (@HSub.hSub.{u, u, u} E E E
          (@instHSub.{u} E
            (@SubNegMonoid.toSub.{u} E
              (@AddGroup.toSubNegMonoid.{u} E
                (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
          (f z) (f w))
        (@HSub.hSub.{u, u, u} E E E
          (@instHSub.{u} E
            (@SubNegMonoid.toSub.{u} E
              (@AddGroup.toSubNegMonoid.{u} E
                (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
          (@Subtype.val.{u + 1} E (fun (x : E) => @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) s x)
            z)
          (@Subtype.val.{u + 1} E (fun (x : E) => @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) s x)
            w)))) := rfl
