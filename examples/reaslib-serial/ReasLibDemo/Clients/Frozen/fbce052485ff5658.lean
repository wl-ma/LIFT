import ReasLibDemo.Sources.Bauschke.Example224iv
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {β : Real} {f : E → EReal} (hf : @StrongConvex.{u} E inst inst_1 β f)
  (hdom : @Set.Nonempty.{u} E (@effectiveDomain.{u} E f)),
  @StronglyMonotone.{u} E inst inst_1 β (@subdifferential.{u} E inst inst_1 f) := @StrongConvex.subdifferential_stronglyMonotone
