import FirstOrderMethodsOptimization_Beck_2017.Chap05.Proposition_5_13
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  (C : Set.{u} E)
  (hC :
    @Convex.{0, u} Real E Real.semiring Real.partialOrder
      (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst))
      (@SMulZeroClass.toSMul.{0, u} Real E
        (@AddZero.toZero.{u} E
          (@AddZeroClass.toAddZero.{u} E
            (@AddMonoid.toAddZeroClass.{u} E
              (@SubNegMonoid.toAddMonoid.{u} E
                (@AddGroup.toSubNegMonoid.{u} E
                  (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))))
        (@DistribSMul.toSMulZeroClass.{0, u} Real E
          (@AddMonoid.toAddZeroClass.{u} E
            (@SubNegMonoid.toAddMonoid.{u} E
              (@AddGroup.toSubNegMonoid.{u} E
                (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
          (@DistribMulAction.toDistribSMul.{0, u} Real E Real.instMonoid
            (@SubNegMonoid.toAddMonoid.{u} E
              (@AddGroup.toSubNegMonoid.{u} E
                (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst))))
            (@Module.toDistribMulAction.{0, u} Real E Real.semiring
              (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst))
              (@NormedSpace.toModule.{0, u} Real E Real.normedField
                (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)
                (@InnerProductSpace.toNormedSpace.{0, u} Real E Real.instRCLike
                  (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1))))))
      C),
  @StrongConvexOn.{u} E inst
    (@InnerProductSpace.toNormedSpace.{0, u} Real E Real.instRCLike
      (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
    C (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)) fun (x : E) =>
    @HDiv.hDiv.{0, 0, 0} Real Real Real (@instHDiv.{0} Real (@DivInvMonoid.toDiv.{0} Real Real.instDivInvMonoid))
      (@HPow.hPow.{0, 0, 0} Real Nat Real (@instHPow.{0, 0} Real Nat (@Monoid.toPow.{0} Real Real.instMonoid))
        (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst) x)
        (@OfNat.ofNat.{0} Nat (nat_lit 2) (instOfNatNat (nat_lit 2))))
      (@OfNat.ofNat.{0} Real (nat_lit 2)
        (@instOfNatAtLeastTwo.{0} Real (nat_lit 2) Real.instNatCast
          (@Nat.instAtLeastTwoHAddOfNat (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1)))
            (@Nat.instNeZeroSucc (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))))) := @half_squared_norm_is_one_strongly_convex_on
