import FirstOrderMethodsOptimization_Beck_2017.Chap05.Definition_5_16
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {f : E → EReal} {σ : Real},
  Iff (@is_strongly_convex_function.{u} E inst inst_1 f σ)
    (And (@LT.lt.{0} Real Real.instLT (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) σ)
      (And (∀ (x : E), @Ne.{1} EReal (f x) (@Bot.bot.{0} EReal instBotEReal))
        (@StrongConvexOn.{u} E inst inst_1 (@effective_domain.{u} E f) σ fun (x : E) => EReal.toReal (f x)))) := @is_strongly_convex_function_iff_strongConvexOn_toReal
