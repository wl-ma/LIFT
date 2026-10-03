import ReasLibDemo.Sources.Bauschke.Proposition2313_Cocoercive
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {β : Real} {s : Set.{u} E} {f : @Set.Elem.{u} E s → E}
  (hβ : @LT.lt.{0} Real Real.instLT (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) β)
  (hf : @Cocoercive.{u} E inst inst_1 β s f) (z w : @Set.Elem.{u} E s),
  @LE.le.{0} Real Real.instLE
    (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst)
      (@HSub.hSub.{u, u, u} E E E
        (@instHSub.{u} E
          (@SubNegMonoid.toSub.{u} E
            (@AddGroup.toSubNegMonoid.{u} E
              (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
        (f z) (f w)))
    (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul) (@Inv.inv.{0} Real Real.instInv β)
      (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst)
        (@HSub.hSub.{u, u, u} E E E
          (@instHSub.{u} E
            (@SubNegMonoid.toSub.{u} E
              (@AddGroup.toSubNegMonoid.{u} E
                (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
          (@Subtype.val.{u + 1} E (fun (x : E) => @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) s x)
            z)
          (@Subtype.val.{u + 1} E (fun (x : E) => @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) s x)
            w)))) := @Cocoercive.norm_sub_le
