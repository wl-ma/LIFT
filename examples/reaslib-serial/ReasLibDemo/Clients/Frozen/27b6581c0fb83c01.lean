import ReasLib.Analysis.Convex.StrongC1
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  [@FiniteDimensional.{0, u} Real E Real.instDivisionRing (@NormedAddCommGroup.toAddCommGroup.{u} E inst)
      (@NormedSpace.toModule.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)
        inst_1)]
  (Q : Set.{u} E) (μ : Real) (f : E → Real)
  (hQ :
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
  (hμ : @LT.lt.{0} Real Real.instLT (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) μ)
  (hf :
    @ContDiffOn.{0, u, 0} Real (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField) E inst
      inst_1 Real Real.normedAddCommGroup
      (@InnerProductSpace.toNormedSpace.{0, 0} Real Real Real.instRCLike
        (@NormedAddCommGroup.toSeminormedAddCommGroup.{0} Real Real.normedAddCommGroup)
        (@RCLike.toInnerProductSpaceReal.{0} Real Real.instRCLike))
      (@OfNat.ofNat.{0} (WithTop.{0} ENat) (nat_lit 1)
        (@One.toOfNat1.{0} (WithTop.{0} ENat)
          (@WithTop.one.{0} ENat (@AddMonoidWithOne.toOne.{0} ENat instAddMonoidWithOneENat))))
      f Q),
  Iff (@StrongConvexC1On.{u} E inst inst_1 Q μ f)
    (∀ (x : E),
      @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) Q x →
        ∀ (y : E),
          @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) Q y →
            ∀ (α : Real),
              @Membership.mem.{0, 0} Real (Set.{0} Real) (@Set.instMembership.{0} Real)
                  (@Set.Icc.{0} Real Real.instPreorder
                    (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero))
                    (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)))
                  α →
                @LE.le.{0} Real Real.instLE
                  (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd)
                    (f
                      (@HAdd.hAdd.{u, u, u} E E E
                        (@instHAdd.{u} E
                          (@AddCommMagma.toAdd.{u} E
                            (@AddCommSemigroup.toAddCommMagma.{u} E
                              (@AddCommMonoid.toAddCommSemigroup.{u} E
                                (@AddCommGroup.toAddCommMonoid.{u} E
                                  (@NormedAddCommGroup.toAddCommGroup.{u} E inst))))))
                        (@HSMul.hSMul.{0, u, u} Real E E
                          (@instHSMul.{0, u} Real E
                            (@SMulZeroClass.toSMul.{0, u} Real E
                              (@AddZero.toZero.{u} E
                                (@AddZeroClass.toAddZero.{u} E
                                  (@AddMonoid.toAddZeroClass.{u} E
                                    (@SubNegMonoid.toAddMonoid.{u} E
                                      (@AddGroup.toSubNegMonoid.{u} E
                                        (@AddCommGroup.toAddGroup.{u} E
                                          (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))))
                              (@DistribSMul.toSMulZeroClass.{0, u} Real E
                                (@AddMonoid.toAddZeroClass.{u} E
                                  (@SubNegMonoid.toAddMonoid.{u} E
                                    (@AddGroup.toSubNegMonoid.{u} E
                                      (@AddCommGroup.toAddGroup.{u} E
                                        (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                                (@DistribMulAction.toDistribSMul.{0, u} Real E Real.instMonoid
                                  (@SubNegMonoid.toAddMonoid.{u} E
                                    (@AddGroup.toSubNegMonoid.{u} E
                                      (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst))))
                                  (@Module.toDistribMulAction.{0, u} Real E Real.semiring
                                    (@AddCommGroup.toAddCommMonoid.{u} E
                                      (@NormedAddCommGroup.toAddCommGroup.{u} E inst))
                                    (@NormedSpace.toModule.{0, u} Real E Real.normedField
                                      (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1))))))
                          α x)
                        (@HSMul.hSMul.{0, u, u} Real E E
                          (@instHSMul.{0, u} Real E
                            (@SMulZeroClass.toSMul.{0, u} Real E
                              (@AddZero.toZero.{u} E
                                (@AddZeroClass.toAddZero.{u} E
                                  (@AddMonoid.toAddZeroClass.{u} E
                                    (@SubNegMonoid.toAddMonoid.{u} E
                                      (@AddGroup.toSubNegMonoid.{u} E
                                        (@AddCommGroup.toAddGroup.{u} E
                                          (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))))
                              (@DistribSMul.toSMulZeroClass.{0, u} Real E
                                (@AddMonoid.toAddZeroClass.{u} E
                                  (@SubNegMonoid.toAddMonoid.{u} E
                                    (@AddGroup.toSubNegMonoid.{u} E
                                      (@AddCommGroup.toAddGroup.{u} E
                                        (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                                (@DistribMulAction.toDistribSMul.{0, u} Real E Real.instMonoid
                                  (@SubNegMonoid.toAddMonoid.{u} E
                                    (@AddGroup.toSubNegMonoid.{u} E
                                      (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst))))
                                  (@Module.toDistribMulAction.{0, u} Real E Real.semiring
                                    (@AddCommGroup.toAddCommMonoid.{u} E
                                      (@NormedAddCommGroup.toAddCommGroup.{u} E inst))
                                    (@NormedSpace.toModule.{0, u} Real E Real.normedField
                                      (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1))))))
                          (@HSub.hSub.{0, 0, 0} Real Real Real (@instHSub.{0} Real Real.instSub)
                            (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)) α)
                          y)))
                    (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
                      (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
                        (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul) α
                          (@HSub.hSub.{0, 0, 0} Real Real Real (@instHSub.{0} Real Real.instSub)
                            (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)) α))
                        (@HDiv.hDiv.{0, 0, 0} Real Real Real
                          (@instHDiv.{0} Real (@DivInvMonoid.toDiv.{0} Real Real.instDivInvMonoid)) μ
                          (@OfNat.ofNat.{0} Real (nat_lit 2)
                            (@instOfNatAtLeastTwo.{0} Real (nat_lit 2) Real.instNatCast
                              (@Nat.instAtLeastTwoHAddOfNat
                                (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1)))
                                (@Nat.instNeZeroSucc (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0)))))))))
                      (@HPow.hPow.{0, 0, 0} Real Nat Real
                        (@instHPow.{0, 0} Real Nat (@Monoid.toPow.{0} Real Real.instMonoid))
                        (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst)
                          (@HSub.hSub.{u, u, u} E E E
                            (@instHSub.{u} E
                              (@SubNegMonoid.toSub.{u} E
                                (@AddGroup.toSubNegMonoid.{u} E
                                  (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                            x y))
                        (@OfNat.ofNat.{0} Nat (nat_lit 2) (instOfNatNat (nat_lit 2))))))
                  (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd)
                    (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul) α (f x))
                    (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
                      (@HSub.hSub.{0, 0, 0} Real Real Real (@instHSub.{0} Real Real.instSub)
                        (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)) α)
                      (f y)))) := @StrongConvexC1On.iff_convexCombo
