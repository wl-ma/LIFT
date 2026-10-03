import FirstOrderMethodsOptimization_Beck_2017.Chap05.Lemma_5_20
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {f g : E → EReal} {σ : Real} (hf : @is_strongly_convex_function.{u} E inst inst_1 f σ)
  (hg :
    @is_convex_function.{u} E (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst))
      (@NormedSpace.toModule.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)
        inst_1)
      g)
  (hg_ne_bot : ∀ (x : E), @Ne.{1} EReal (g x) (@Bot.bot.{0} EReal instBotEReal)),
  @is_strongly_convex_function.{u} E inst inst_1
    (fun (x : E) =>
      @HAdd.hAdd.{0, 0, 0} EReal EReal EReal
        (@instHAdd.{0} EReal
          (@AddCommMagma.toAdd.{0} EReal
            (@AddCommSemigroup.toAddCommMagma.{0} EReal
              (@AddCommMonoid.toAddCommSemigroup.{0} EReal instAddCommMonoidEReal))))
        (f x) (g x))
    σ := @is_strongly_convex_function_add_of_is_convex_function
