import FirstOrderMethodsOptimization_Beck_2017.Chap05.Definition_5_16
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} {inst : NormedAddCommGroup.{u} E}
  {inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)}
  {f : E → EReal} {σ : Real} [self : @is_strongly_convex_function.{u} E inst inst_1 f σ] ⦃x : E⦄,
  @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@effective_domain.{u} E f) x →
    ∀ ⦃y : E⦄,
      @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@effective_domain.{u} E f) y →
        ∀ ⦃t : Real⦄,
          @Membership.mem.{0, 0} Real (Set.{0} Real) (@Set.instMembership.{0} Real)
              (@Set.Icc.{0} Real Real.instPreorder
                (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero))
                (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)))
              t →
            @LE.le.{0} EReal (@Preorder.toLE.{0} EReal (@PartialOrder.toPreorder.{0} EReal instPartialOrderEReal))
              (f
                (@HAdd.hAdd.{u, u, u} E E E
                  (@instHAdd.{u} E
                    (@AddCommMagma.toAdd.{u} E
                      (@AddCommSemigroup.toAddCommMagma.{u} E
                        (@AddCommMonoid.toAddCommSemigroup.{u} E
                          (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst))))))
                  (@HSMul.hSMul.{0, u, u} Real E E
                    (@instHSMul.{0, u} Real E
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
                                (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1))))))
                    t x)
                  (@HSMul.hSMul.{0, u, u} Real E E
                    (@instHSMul.{0, u} Real E
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
                                (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1))))))
                    (@HSub.hSub.{0, 0, 0} Real Real Real (@instHSub.{0} Real Real.instSub)
                      (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)) t)
                    y)))
              (@HSub.hSub.{0, 0, 0} EReal EReal EReal
                (@instHSub.{0} EReal
                  (@SubNegMonoid.toSub.{0} EReal
                    (@SubNegZeroMonoid.toSubNegMonoid.{0} EReal EReal.instSubNegZeroMonoid)))
                (@HAdd.hAdd.{0, 0, 0} EReal EReal EReal
                  (@instHAdd.{0} EReal
                    (@AddCommMagma.toAdd.{0} EReal
                      (@AddCommSemigroup.toAddCommMagma.{0} EReal
                        (@AddCommMonoid.toAddCommSemigroup.{0} EReal instAddCommMonoidEReal))))
                  (@HMul.hMul.{0, 0, 0} EReal EReal EReal (@instHMul.{0} EReal EReal.instMul) (Real.toEReal t) (f x))
                  (@HMul.hMul.{0, 0, 0} EReal EReal EReal (@instHMul.{0} EReal EReal.instMul)
                    (Real.toEReal
                      (@HSub.hSub.{0, 0, 0} Real Real Real (@instHSub.{0} Real Real.instSub)
                        (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)) t))
                    (f y)))
                (Real.toEReal
                  (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
                    (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
                      (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
                        (@HDiv.hDiv.{0, 0, 0} Real Real Real
                          (@instHDiv.{0} Real (@DivInvMonoid.toDiv.{0} Real Real.instDivInvMonoid)) σ
                          (@OfNat.ofNat.{0} Real (nat_lit 2)
                            (@instOfNatAtLeastTwo.{0} Real (nat_lit 2) Real.instNatCast
                              (@Nat.instAtLeastTwoHAddOfNat
                                (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1)))
                                (@Nat.instNeZeroSucc (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))))))
                        t)
                      (@HSub.hSub.{0, 0, 0} Real Real Real (@instHSub.{0} Real Real.instSub)
                        (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)) t))
                    (@HPow.hPow.{0, 0, 0} Real Nat Real
                      (@instHPow.{0, 0} Real Nat (@Monoid.toPow.{0} Real Real.instMonoid))
                      (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst)
                        (@HSub.hSub.{u, u, u} E E E
                          (@instHSub.{u} E
                            (@SubNegMonoid.toSub.{u} E
                              (@AddGroup.toSubNegMonoid.{u} E
                                (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
                          x y))
                      (@OfNat.ofNat.{0} Nat (nat_lit 2) (instOfNatNat (nat_lit 2))))))) := @is_strongly_convex_function.segment_ineq
