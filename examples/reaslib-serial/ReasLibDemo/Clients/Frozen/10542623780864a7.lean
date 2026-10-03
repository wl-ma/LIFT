import ReasLibDemo.Sources.Nesterov.Lemma216_Nonneg
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {Q : Set.{u} E} {μ : Real} {f : E → Real}
  (convexDomain :
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
                (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)))))
      Q)
  (muNonneg : @LE.le.{0} Real Real.instLE (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) μ)
  (contDiffOn :
    @ContDiffOn.{0, u, 0} Real (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField) E inst
      inst_1 Real Real.normedAddCommGroup
      (@InnerProductSpace.toNormedSpace.{0, 0} Real Real Real.instRCLike
        (@NormedAddCommGroup.toSeminormedAddCommGroup.{0} Real Real.normedAddCommGroup)
        (@RCLike.toInnerProductSpaceReal.{0} Real Real.instRCLike))
      (@OfNat.ofNat.{0} (WithTop.{0} ENat) (nat_lit 1)
        (@One.toOfNat1.{0} (WithTop.{0} ENat)
          (@WithTop.one.{0} ENat (@AddMonoidWithOne.toOne.{0} ENat instAddMonoidWithOneENat))))
      f Q)
  (lower :
    ∀ (x : E),
      @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) Q x →
        ∀ (y : E),
          @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) Q y →
            @LE.le.{0} Real Real.instLE
              (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd)
                (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd) (f x)
                  (@DFunLike.coe.{u + 1, u + 1, 1}
                    (@ContinuousLinearMap.{0, 0, u, 0} Real Real
                      (@DivisionSemiring.toSemiring.{0} Real
                        (@Semifield.toDivisionSemiring.{0} Real
                          (@Field.toSemifield.{0} Real
                            (@NormedField.toField.{0} Real
                              (@NontriviallyNormedField.toNormedField.{0} Real
                                (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField))))))
                      (@DivisionSemiring.toSemiring.{0} Real
                        (@Semifield.toDivisionSemiring.{0} Real
                          (@Field.toSemifield.{0} Real
                            (@NormedField.toField.{0} Real
                              (@NontriviallyNormedField.toNormedField.{0} Real
                                (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField))))))
                      (@RingHom.id.{0} Real
                        (@Semiring.toNonAssocSemiring.{0} Real
                          (@DivisionSemiring.toSemiring.{0} Real
                            (@Semifield.toDivisionSemiring.{0} Real
                              (@Field.toSemifield.{0} Real
                                (@NormedField.toField.{0} Real
                                  (@NontriviallyNormedField.toNormedField.{0} Real
                                    (@DenselyNormedField.toNontriviallyNormedField.{0} Real
                                      Real.denselyNormedField))))))))
                      E
                      (@UniformSpace.toTopologicalSpace.{u} E
                        (@PseudoMetricSpace.toUniformSpace.{u} E
                          (@SeminormedAddCommGroup.toPseudoMetricSpace.{u} E
                            (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst))))
                      (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)) Real
                      (@UniformSpace.toTopologicalSpace.{0} Real
                        (@PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))
                      (@AddCommGroup.toAddCommMonoid.{0} Real Real.instAddCommGroup)
                      (@NormedSpace.toModule.{0, u} Real E Real.normedField
                        (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
                      (@Semiring.toModule.{0} Real
                        (@DivisionSemiring.toSemiring.{0} Real
                          (@Semifield.toDivisionSemiring.{0} Real
                            (@Field.toSemifield.{0} Real
                              (@NormedField.toField.{0} Real
                                (@NontriviallyNormedField.toNormedField.{0} Real
                                  (@DenselyNormedField.toNontriviallyNormedField.{0} Real
                                    Real.denselyNormedField))))))))
                    E (fun (x : E) => Real)
                    (@ContinuousLinearMap.funLike.{0, 0, u, 0} Real Real
                      (@DivisionSemiring.toSemiring.{0} Real
                        (@Semifield.toDivisionSemiring.{0} Real
                          (@Field.toSemifield.{0} Real
                            (@NormedField.toField.{0} Real
                              (@NontriviallyNormedField.toNormedField.{0} Real
                                (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField))))))
                      (@DivisionSemiring.toSemiring.{0} Real
                        (@Semifield.toDivisionSemiring.{0} Real
                          (@Field.toSemifield.{0} Real
                            (@NormedField.toField.{0} Real
                              (@NontriviallyNormedField.toNormedField.{0} Real
                                (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField))))))
                      (@RingHom.id.{0} Real
                        (@Semiring.toNonAssocSemiring.{0} Real
                          (@DivisionSemiring.toSemiring.{0} Real
                            (@Semifield.toDivisionSemiring.{0} Real
                              (@Field.toSemifield.{0} Real
                                (@NormedField.toField.{0} Real
                                  (@NontriviallyNormedField.toNormedField.{0} Real
                                    (@DenselyNormedField.toNontriviallyNormedField.{0} Real
                                      Real.denselyNormedField))))))))
                      E
                      (@UniformSpace.toTopologicalSpace.{u} E
                        (@PseudoMetricSpace.toUniformSpace.{u} E
                          (@SeminormedAddCommGroup.toPseudoMetricSpace.{u} E
                            (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst))))
                      (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)) Real
                      (@UniformSpace.toTopologicalSpace.{0} Real
                        (@PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))
                      (@AddCommGroup.toAddCommMonoid.{0} Real Real.instAddCommGroup)
                      (@NormedSpace.toModule.{0, u} Real E Real.normedField
                        (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
                      (@Semiring.toModule.{0} Real
                        (@DivisionSemiring.toSemiring.{0} Real
                          (@Semifield.toDivisionSemiring.{0} Real
                            (@Field.toSemifield.{0} Real
                              (@NormedField.toField.{0} Real
                                (@NontriviallyNormedField.toNormedField.{0} Real
                                  (@DenselyNormedField.toNontriviallyNormedField.{0} Real
                                    Real.denselyNormedField))))))))
                    (@fderivWithin.{0, u, 0} Real
                      (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField) E
                      (@NormedAddCommGroup.toAddCommGroup.{u} E inst)
                      (@NormedSpace.toModule.{0, u} Real E Real.normedField
                        (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
                      (@UniformSpace.toTopologicalSpace.{u} E
                        (@PseudoMetricSpace.toUniformSpace.{u} E
                          (@SeminormedAddCommGroup.toPseudoMetricSpace.{u} E
                            (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst))))
                      Real Real.instAddCommGroup
                      (@Semiring.toModule.{0} Real
                        (@DivisionSemiring.toSemiring.{0} Real
                          (@Semifield.toDivisionSemiring.{0} Real
                            (@Field.toSemifield.{0} Real
                              (@NormedField.toField.{0} Real
                                (@NontriviallyNormedField.toNormedField.{0} Real
                                  (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField)))))))
                      (@UniformSpace.toTopologicalSpace.{0} Real
                        (@PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))
                      f Q x)
                    (@HSub.hSub.{u, u, u} E E E
                      (@instHSub.{u} E
                        (@SubNegMonoid.toSub.{u} E
                          (@AddGroup.toSubNegMonoid.{u} E
                            (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                      y x)))
                (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
                  (@HDiv.hDiv.{0, 0, 0} Real Real Real
                    (@instHDiv.{0} Real (@DivInvMonoid.toDiv.{0} Real Real.instDivInvMonoid)) μ
                    (@OfNat.ofNat.{0} Real (nat_lit 2)
                      (@instOfNatAtLeastTwo.{0} Real (nat_lit 2) Real.instNatCast
                        (@Nat.instAtLeastTwoHAddOfNat (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1)))
                          (@Nat.instNeZeroSucc (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))))))
                  (@HPow.hPow.{0, 0, 0} Real Nat Real
                    (@instHPow.{0, 0} Real Nat (@Monoid.toPow.{0} Real Real.instMonoid))
                    (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst)
                      (@HSub.hSub.{u, u, u} E E E
                        (@instHSub.{u} E
                          (@SubNegMonoid.toSub.{u} E
                            (@AddGroup.toSubNegMonoid.{u} E
                              (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                        y x))
                    (@OfNat.ofNat.{0} Nat (nat_lit 2) (instOfNatNat (nat_lit 2))))))
              (f y)),
  @StrongConvexC1NonnegOn.{u} E inst inst_1 Q μ f := @StrongConvexC1NonnegOn.ofConditions
example : @StrongConvexC1NonnegOn.ofConditions = (fun {E : Type u} [inst : NormedAddCommGroup.{u} E]
    [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
    {Q : Set.{u} E} {μ : Real} {f : E → Real}
    (convexDomain :
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
                  (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)))))
        Q)
    (muNonneg :
      @LE.le.{0} Real Real.instLE (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) μ)
    (contDiffOn :
      @ContDiffOn.{0, u, 0} Real (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField) E inst
        inst_1 Real Real.normedAddCommGroup
        (@InnerProductSpace.toNormedSpace.{0, 0} Real Real Real.instRCLike
          (@NormedAddCommGroup.toSeminormedAddCommGroup.{0} Real Real.normedAddCommGroup)
          (@RCLike.toInnerProductSpaceReal.{0} Real Real.instRCLike))
        (@OfNat.ofNat.{0} (WithTop.{0} ENat) (nat_lit 1)
          (@One.toOfNat1.{0} (WithTop.{0} ENat)
            (@WithTop.one.{0} ENat (@AddMonoidWithOne.toOne.{0} ENat instAddMonoidWithOneENat))))
        f Q)
    (lower :
      ∀ (x : E),
        @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) Q x →
          ∀ (y : E),
            @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) Q y →
              @LE.le.{0} Real Real.instLE
                (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd)
                  (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd) (f x)
                    (@DFunLike.coe.{u + 1, u + 1, 1}
                      (@ContinuousLinearMap.{0, 0, u, 0} Real Real
                        (@DivisionSemiring.toSemiring.{0} Real
                          (@Semifield.toDivisionSemiring.{0} Real
                            (@Field.toSemifield.{0} Real
                              (@NormedField.toField.{0} Real
                                (@NontriviallyNormedField.toNormedField.{0} Real
                                  (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField))))))
                        (@DivisionSemiring.toSemiring.{0} Real
                          (@Semifield.toDivisionSemiring.{0} Real
                            (@Field.toSemifield.{0} Real
                              (@NormedField.toField.{0} Real
                                (@NontriviallyNormedField.toNormedField.{0} Real
                                  (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField))))))
                        (@RingHom.id.{0} Real
                          (@Semiring.toNonAssocSemiring.{0} Real
                            (@DivisionSemiring.toSemiring.{0} Real
                              (@Semifield.toDivisionSemiring.{0} Real
                                (@Field.toSemifield.{0} Real
                                  (@NormedField.toField.{0} Real
                                    (@NontriviallyNormedField.toNormedField.{0} Real
                                      (@DenselyNormedField.toNontriviallyNormedField.{0} Real
                                        Real.denselyNormedField))))))))
                        E
                        (@UniformSpace.toTopologicalSpace.{u} E
                          (@PseudoMetricSpace.toUniformSpace.{u} E
                            (@SeminormedAddCommGroup.toPseudoMetricSpace.{u} E
                              (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst))))
                        (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)) Real
                        (@UniformSpace.toTopologicalSpace.{0} Real
                          (@PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))
                        (@AddCommGroup.toAddCommMonoid.{0} Real Real.instAddCommGroup)
                        (@NormedSpace.toModule.{0, u} Real E Real.normedField
                          (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
                        (@Semiring.toModule.{0} Real
                          (@DivisionSemiring.toSemiring.{0} Real
                            (@Semifield.toDivisionSemiring.{0} Real
                              (@Field.toSemifield.{0} Real
                                (@NormedField.toField.{0} Real
                                  (@NontriviallyNormedField.toNormedField.{0} Real
                                    (@DenselyNormedField.toNontriviallyNormedField.{0} Real
                                      Real.denselyNormedField))))))))
                      E (fun (x : E) => Real)
                      (@ContinuousLinearMap.funLike.{0, 0, u, 0} Real Real
                        (@DivisionSemiring.toSemiring.{0} Real
                          (@Semifield.toDivisionSemiring.{0} Real
                            (@Field.toSemifield.{0} Real
                              (@NormedField.toField.{0} Real
                                (@NontriviallyNormedField.toNormedField.{0} Real
                                  (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField))))))
                        (@DivisionSemiring.toSemiring.{0} Real
                          (@Semifield.toDivisionSemiring.{0} Real
                            (@Field.toSemifield.{0} Real
                              (@NormedField.toField.{0} Real
                                (@NontriviallyNormedField.toNormedField.{0} Real
                                  (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField))))))
                        (@RingHom.id.{0} Real
                          (@Semiring.toNonAssocSemiring.{0} Real
                            (@DivisionSemiring.toSemiring.{0} Real
                              (@Semifield.toDivisionSemiring.{0} Real
                                (@Field.toSemifield.{0} Real
                                  (@NormedField.toField.{0} Real
                                    (@NontriviallyNormedField.toNormedField.{0} Real
                                      (@DenselyNormedField.toNontriviallyNormedField.{0} Real
                                        Real.denselyNormedField))))))))
                        E
                        (@UniformSpace.toTopologicalSpace.{u} E
                          (@PseudoMetricSpace.toUniformSpace.{u} E
                            (@SeminormedAddCommGroup.toPseudoMetricSpace.{u} E
                              (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst))))
                        (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)) Real
                        (@UniformSpace.toTopologicalSpace.{0} Real
                          (@PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))
                        (@AddCommGroup.toAddCommMonoid.{0} Real Real.instAddCommGroup)
                        (@NormedSpace.toModule.{0, u} Real E Real.normedField
                          (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
                        (@Semiring.toModule.{0} Real
                          (@DivisionSemiring.toSemiring.{0} Real
                            (@Semifield.toDivisionSemiring.{0} Real
                              (@Field.toSemifield.{0} Real
                                (@NormedField.toField.{0} Real
                                  (@NontriviallyNormedField.toNormedField.{0} Real
                                    (@DenselyNormedField.toNontriviallyNormedField.{0} Real
                                      Real.denselyNormedField))))))))
                      (@fderivWithin.{0, u, 0} Real
                        (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField) E
                        (@NormedAddCommGroup.toAddCommGroup.{u} E inst)
                        (@NormedSpace.toModule.{0, u} Real E Real.normedField
                          (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
                        (@UniformSpace.toTopologicalSpace.{u} E
                          (@PseudoMetricSpace.toUniformSpace.{u} E
                            (@SeminormedAddCommGroup.toPseudoMetricSpace.{u} E
                              (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst))))
                        Real Real.instAddCommGroup
                        (@Semiring.toModule.{0} Real
                          (@DivisionSemiring.toSemiring.{0} Real
                            (@Semifield.toDivisionSemiring.{0} Real
                              (@Field.toSemifield.{0} Real
                                (@NormedField.toField.{0} Real
                                  (@NontriviallyNormedField.toNormedField.{0} Real
                                    (@DenselyNormedField.toNontriviallyNormedField.{0} Real
                                      Real.denselyNormedField)))))))
                        (@UniformSpace.toTopologicalSpace.{0} Real
                          (@PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))
                        f Q x)
                      (@HSub.hSub.{u, u, u} E E E
                        (@instHSub.{u} E
                          (@SubNegMonoid.toSub.{u} E
                            (@AddGroup.toSubNegMonoid.{u} E
                              (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                        y x)))
                  (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
                    (@HDiv.hDiv.{0, 0, 0} Real Real Real
                      (@instHDiv.{0} Real (@DivInvMonoid.toDiv.{0} Real Real.instDivInvMonoid)) μ
                      (@OfNat.ofNat.{0} Real (nat_lit 2)
                        (@instOfNatAtLeastTwo.{0} Real (nat_lit 2) Real.instNatCast
                          (@Nat.instAtLeastTwoHAddOfNat (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1)))
                            (@Nat.instNeZeroSucc (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))))))
                    (@HPow.hPow.{0, 0, 0} Real Nat Real
                      (@instHPow.{0, 0} Real Nat (@Monoid.toPow.{0} Real Real.instMonoid))
                      (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst)
                        (@HSub.hSub.{u, u, u} E E E
                          (@instHSub.{u} E
                            (@SubNegMonoid.toSub.{u} E
                              (@AddGroup.toSubNegMonoid.{u} E
                                (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                          y x))
                      (@OfNat.ofNat.{0} Nat (nat_lit 2) (instOfNatNat (nat_lit 2))))))
                (f y)) =>
  @StrongConvexC1NonnegOn.mk.{u} E inst inst_1 Q μ f convexDomain muNonneg contDiffOn lower) := rfl
