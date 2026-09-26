import FirstOrderMethodsOptimization_Beck_2017.Chap05.Definition_5_16
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {f : E → EReal} {σ : Real} (hf : @is_strongly_convex_function.{u} E inst inst_1 f σ),
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
    (@effective_domain.{u} E f) := @is_strongly_convex_function.convex_effective_domain
