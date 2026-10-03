import FirstOrderMethodsOptimization_Beck_2017.Chap05.Definition_5_16
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} {inst : NormedAddCommGroup.{u} E}
  {inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)}
  {f : E → EReal} (σ : Real) [self : @is_strongly_convex_function.{u} E inst inst_1 f σ] (x : E),
  @Ne.{1} EReal (f x) (@Bot.bot.{0} EReal instBotEReal) := @is_strongly_convex_function.ne_bot
