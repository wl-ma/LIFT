import FirstOrderMethodsOptimization_Beck_2017.Chap05.Theorem_5_17
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [@InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  (f : E → EReal) (q : E → Real) (h_ne_bot : ∀ (x : E), @Ne.{1} EReal (f x) (@Bot.bot.{0} EReal instBotEReal)) {x : E}
  (hx : @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@effective_domain.{u} E f) x),
  @Eq.{1} Real
    (EReal.toReal
      (@HSub.hSub.{0, 0, 0} EReal EReal EReal
        (@instHSub.{0} EReal
          (@SubNegMonoid.toSub.{0} EReal (@SubNegZeroMonoid.toSubNegMonoid.{0} EReal EReal.instSubNegZeroMonoid)))
        (f x) (Real.toEReal (q x))))
    (@HSub.hSub.{0, 0, 0} Real Real Real (@instHSub.{0} Real Real.instSub) (EReal.toReal (f x)) (q x)) := @toReal_sub_coe_eq
