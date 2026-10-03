import ReasLib.Analysis.Convex.StrongC1
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {Q : Set.{u} E} {μ : Real} {f g : E → Real} (hf : @StrongConvexC1On.{u} E inst inst_1 Q μ f)
  (hfg : @Set.EqOn.{u, 0} E Real f g Q), @StrongConvexC1On.{u} E inst inst_1 Q μ g := @StrongConvexC1On.congr
