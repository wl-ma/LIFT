import FirstOrderMethodsOptimization_Beck_2017.Chap05.Theorem_5_17
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [@InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  (f : E → EReal) (q : E → Real) (h_ne_bot : ∀ (x : E), @Ne.{1} EReal (f x) (@Bot.bot.{0} EReal instBotEReal)),
  @Eq.{u + 1} (Set.{u} E)
    (@effective_domain.{u} E fun (x : E) =>
      @HSub.hSub.{0, 0, 0} EReal EReal EReal
        (@instHSub.{0} EReal
          (@SubNegMonoid.toSub.{0} EReal (@SubNegZeroMonoid.toSubNegMonoid.{0} EReal EReal.instSubNegZeroMonoid)))
        (f x) (Real.toEReal (q x)))
    (@effective_domain.{u} E f) := @effective_domain_sub_coe_eq
