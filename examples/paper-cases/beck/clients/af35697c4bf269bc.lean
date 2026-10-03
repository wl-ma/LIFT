import FirstOrderMethodsOptimization_Beck_2017.Chap05.Definition_5_16
noncomputable section
set_option autoImplicit false
universe u
example : {E : Type u} →
  [inst : NormedAddCommGroup.{u} E] →
    [@NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)] →
      (f : E → EReal) → (σ : Real) → Prop := @is_strongly_convex_function
