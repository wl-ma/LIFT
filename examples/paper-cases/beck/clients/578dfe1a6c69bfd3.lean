import FirstOrderMethodsOptimization_Beck_2017.Chap05.Definition_5_16
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {f : E → EReal} {σ : Real} (hf : @is_strongly_convex_function.{u} E inst inst_1 f σ),
  @StrongConvexOn.{u} E inst inst_1 (@effective_domain.{u} E f) σ fun (x : E) => EReal.toReal (f x) := @strongConvexOn_toReal_of_is_strongly_convex_function
