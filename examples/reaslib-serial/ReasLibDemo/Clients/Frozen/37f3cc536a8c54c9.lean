import ReasLibDemo.Sources.Beck.Example521
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  [@FiniteDimensional.{0, u} Real E Real.instDivisionRing (@NormedAddCommGroup.toAddCommGroup.{u} E inst)
      (@NormedSpace.toModule.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)
        (@InnerProductSpace.toNormedSpace.{0, u} Real E Real.instRCLike
          (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1))]
  {C : Set.{u} E} (hne : @Set.Nonempty.{u} E C)
  (hconv :
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
  @StrongConvex.{u} E inst inst_1 (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne))
    fun (x : E) =>
    @HAdd.hAdd.{0, 0, 0} EReal EReal EReal
      (@instHAdd.{0} EReal
        (@AddCommMagma.toAdd.{0} EReal
          (@AddCommSemigroup.toAddCommMagma.{0} EReal
            (@AddCommMonoid.toAddCommSemigroup.{0} EReal instAddCommMonoidEReal))))
      (Real.toEReal
        (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
          (@HDiv.hDiv.{0, 0, 0} Real Real Real (@instHDiv.{0} Real (@DivInvMonoid.toDiv.{0} Real Real.instDivInvMonoid))
            (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne))
            (@OfNat.ofNat.{0} Real (nat_lit 2)
              (@instOfNatAtLeastTwo.{0} Real (nat_lit 2) Real.instNatCast
                (@Nat.instAtLeastTwoHAddOfNat (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1)))
                  (@Nat.instNeZeroSucc (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))))))
          (@HPow.hPow.{0, 0, 0} Real Nat Real (@instHPow.{0, 0} Real Nat (@Monoid.toPow.{0} Real Real.instMonoid))
            (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst) x)
            (@OfNat.ofNat.{0} Nat (nat_lit 2) (instOfNatNat (nat_lit 2))))))
      (@erealIndicator.{u} E C x) := @halfNormSq_add_erealIndicator_strongConvex
