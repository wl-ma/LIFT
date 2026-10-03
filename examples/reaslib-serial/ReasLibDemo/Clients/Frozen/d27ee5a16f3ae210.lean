import ReasLibDemo.Sources.Beck.Lemma520
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  [@FiniteDimensional.{0, u} Real E Real.instDivisionRing (@NormedAddCommGroup.toAddCommGroup.{u} E inst)
      (@NormedSpace.toModule.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)
        (@InnerProductSpace.toNormedSpace.{0, u} Real E Real.instRCLike
          (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1))]
  {σ : Real} {f g : E → EReal} (hf : @StrongConvex.{u} E inst inst_1 σ f)
  (hbot :
    ∀ (x : E),
      @LT.lt.{0} EReal (@Preorder.toLT.{0} EReal (@PartialOrder.toPreorder.{0} EReal instPartialOrderEReal))
        (@Bot.bot.{0} EReal instBotEReal) (g x))
  (hconvex :
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
      (@effectiveDomain.{u} E g))
  (hjensen :
    ∀ (x : E),
      @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@effectiveDomain.{u} E g) x →
        ∀ (y : E),
          @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@effectiveDomain.{u} E g) y →
            ∀ (t : Real),
              @Membership.mem.{0, 0} Real (Set.{0} Real) (@Set.instMembership.{0} Real)
                  (@Set.Icc.{0} Real Real.instPreorder
                    (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero))
                    (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)))
                  t →
                @LE.le.{0} EReal (@Preorder.toLE.{0} EReal (@PartialOrder.toPreorder.{0} EReal instPartialOrderEReal))
                  (g
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
                                      (@AddCommGroup.toAddGroup.{u} E
                                        (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))))
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
                                      (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)))))))
                        t x)
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
                                      (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)))))))
                        (@HSub.hSub.{0, 0, 0} Real Real Real (@instHSub.{0} Real Real.instSub)
                          (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)) t)
                        y)))
                  (@HAdd.hAdd.{0, 0, 0} EReal EReal EReal
                    (@instHAdd.{0} EReal
                      (@AddCommMagma.toAdd.{0} EReal
                        (@AddCommSemigroup.toAddCommMagma.{0} EReal
                          (@AddCommMonoid.toAddCommSemigroup.{0} EReal instAddCommMonoidEReal))))
                    (@HMul.hMul.{0, 0, 0} EReal EReal EReal (@instHMul.{0} EReal EReal.instMul) (Real.toEReal t) (g x))
                    (@HMul.hMul.{0, 0, 0} EReal EReal EReal (@instHMul.{0} EReal EReal.instMul)
                      (@HSub.hSub.{0, 0, 0} EReal EReal EReal
                        (@instHSub.{0} EReal
                          (@SubNegMonoid.toSub.{0} EReal
                            (@SubNegZeroMonoid.toSubNegMonoid.{0} EReal EReal.instSubNegZeroMonoid)))
                        (@OfNat.ofNat.{0} EReal (nat_lit 1) (@One.toOfNat1.{0} EReal instOneEReal)) (Real.toEReal t))
                      (g y)))),
  @StrongConvex.{u} E inst inst_1 σ
    (@HAdd.hAdd.{u, u, u} (E → EReal) (E → EReal) (E → EReal)
      (@instHAdd.{u} (E → EReal)
        (@Pi.instAdd.{u, 0} E (fun (a : E) => EReal) fun (i : E) =>
          @AddCommMagma.toAdd.{0} EReal
            (@AddCommSemigroup.toAddCommMagma.{0} EReal
              (@AddCommMonoid.toAddCommSemigroup.{0} EReal instAddCommMonoidEReal))))
      f g) := @StrongConvex.add_convex
