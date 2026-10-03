import ReasLib.Analysis.Convex.Strong
noncomputable section
set_option autoImplicit false
universe u
example : {E : Type u} →
  [inst : NormedAddCommGroup.{u} E] →
    [@InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)] →
      (σ : Real) → (f : E → EReal) → Prop := @StrongConvex
