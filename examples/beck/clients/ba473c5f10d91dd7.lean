import FirstOrderMethodsOptimization_Beck_2017.Chap05.Theorem_5_17
noncomputable section
set_option autoImplicit false
example : ∀ {a : EReal} {r : Real} (ha : @Ne.{1} EReal a (@Bot.bot.{0} EReal instBotEReal)),
  @Ne.{1} EReal
    (@HSub.hSub.{0, 0, 0} EReal EReal EReal
      (@instHSub.{0} EReal
        (@SubNegMonoid.toSub.{0} EReal (@SubNegZeroMonoid.toSubNegMonoid.{0} EReal EReal.instSubNegZeroMonoid)))
      a (Real.toEReal r))
    (@Bot.bot.{0} EReal instBotEReal) := @sub_coe_neBot_of_neBot
