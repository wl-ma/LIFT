import ReasLib.Analysis.Convex.StrongC1
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {Q : Set.{u} E} {μ : Real} {f : E → Real} (hf : @StrongConvexC1On.{u} E inst inst_1 Q μ f) {x y : E}
  (hx : @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) Q x)
  (hy : @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) Q y)
  {f' :
    @ContinuousLinearMap.{0, 0, u, 0} Real Real Real.semiring Real.semiring
      (@RingHom.id.{0} Real (@Semiring.toNonAssocSemiring.{0} Real Real.semiring)) E
      (@UniformSpace.toTopologicalSpace.{u} E
        (@PseudoMetricSpace.toUniformSpace.{u} E
          (@SeminormedAddCommGroup.toPseudoMetricSpace.{u} E
            (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst))))
      (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)) Real
      (@UniformSpace.toTopologicalSpace.{0} Real (@PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))
      Real.instAddCommMonoid
      (@NormedSpace.toModule.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)
        inst_1)
      (@Semiring.toModule.{0} Real Real.semiring)}
  (hf' :
    @HasFDerivWithinAt.{0, u, 0} Real (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField) E
      (@NormedAddCommGroup.toAddCommGroup.{u} E inst)
      (@NormedSpace.toModule.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)
        inst_1)
      (@UniformSpace.toTopologicalSpace.{u} E
        (@PseudoMetricSpace.toUniformSpace.{u} E
          (@SeminormedAddCommGroup.toPseudoMetricSpace.{u} E
            (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst))))
      Real Real.instAddCommGroup (@Semiring.toModule.{0} Real Real.semiring)
      (@UniformSpace.toTopologicalSpace.{0} Real (@PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) f
      f' Q x),
  @LE.le.{0} Real Real.instLE
    (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd)
      (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd) (f x)
        (@DFunLike.coe.{u + 1, u + 1, 1}
          (@ContinuousLinearMap.{0, 0, u, 0} Real Real Real.semiring Real.semiring
            (@RingHom.id.{0} Real (@Semiring.toNonAssocSemiring.{0} Real Real.semiring)) E
            (@UniformSpace.toTopologicalSpace.{u} E
              (@PseudoMetricSpace.toUniformSpace.{u} E
                (@SeminormedAddCommGroup.toPseudoMetricSpace.{u} E
                  (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst))))
            (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)) Real
            (@UniformSpace.toTopologicalSpace.{0} Real
              (@PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))
            Real.instAddCommMonoid
            (@NormedSpace.toModule.{0, u} Real E Real.normedField
              (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
            (@Semiring.toModule.{0} Real Real.semiring))
          E (fun (x : E) => Real)
          (@ContinuousLinearMap.funLike.{0, 0, u, 0} Real Real Real.semiring Real.semiring
            (@RingHom.id.{0} Real (@Semiring.toNonAssocSemiring.{0} Real Real.semiring)) E
            (@UniformSpace.toTopologicalSpace.{u} E
              (@PseudoMetricSpace.toUniformSpace.{u} E
                (@SeminormedAddCommGroup.toPseudoMetricSpace.{u} E
                  (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst))))
            (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)) Real
            (@UniformSpace.toTopologicalSpace.{0} Real
              (@PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))
            Real.instAddCommMonoid
            (@NormedSpace.toModule.{0, u} Real E Real.normedField
              (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
            (@Semiring.toModule.{0} Real Real.semiring))
          f'
          (@HSub.hSub.{u, u, u} E E E
            (@instHSub.{u} E
              (@SubNegMonoid.toSub.{u} E
                (@AddGroup.toSubNegMonoid.{u} E
                  (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
            y x)))
      (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
        (@HDiv.hDiv.{0, 0, 0} Real Real Real (@instHDiv.{0} Real (@DivInvMonoid.toDiv.{0} Real Real.instDivInvMonoid)) μ
          (@OfNat.ofNat.{0} Real (nat_lit 2)
            (@instOfNatAtLeastTwo.{0} Real (nat_lit 2) Real.instNatCast
              (@Nat.instAtLeastTwoHAddOfNat (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1)))
                (@Nat.instNeZeroSucc (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))))))
        (@HPow.hPow.{0, 0, 0} Real Nat Real (@instHPow.{0, 0} Real Nat (@Monoid.toPow.{0} Real Real.instMonoid))
          (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst)
            (@HSub.hSub.{u, u, u} E E E
              (@instHSub.{u} E
                (@SubNegMonoid.toSub.{u} E
                  (@AddGroup.toSubNegMonoid.{u} E
                    (@AddCommGroup.toAddGroup.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)))))
              y x))
          (@OfNat.ofNat.{0} Nat (nat_lit 2) (instOfNatNat (nat_lit 2))))))
    (f y) := @StrongConvexC1On.le_of_hasFDerivWithinAt
