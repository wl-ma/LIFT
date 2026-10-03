import FirstOrderMethodsOptimization_Beck_2017.Chap05.Lemma_5_20
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {f g : E → EReal} {σ : Real} (hf : @is_strongly_convex_function.{u} E inst inst_1 f σ)
  (hg_ne_bot : ∀ (x : E), @Ne.{1} EReal (g x) (@Bot.bot.{0} EReal instBotEReal))
  (hg :
    @ConvexOn.{0, u, 0} Real E Real Real.semiring Real.partialOrder
      (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst)) Real.instAddCommMonoid
      Real.partialOrder
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
      (@instSMulOfMul.{0} Real Real.instMul) (@effective_domain.{u} E g) fun (x : E) => EReal.toReal (g x)),
  @is_strongly_convex_function.{u} E inst inst_1
    (fun (x : E) =>
      @HAdd.hAdd.{0, 0, 0} EReal EReal EReal
        (@instHAdd.{0} EReal
          (@AddCommMagma.toAdd.{0} EReal
            (@AddCommSemigroup.toAddCommMagma.{0} EReal
              (@AddCommMonoid.toAddCommSemigroup.{0} EReal instAddCommMonoidEReal))))
        (f x) (g x))
    σ := @is_strongly_convex_function_add_of_convexOn_toReal
