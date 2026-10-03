import ReasLibDemo.Sources.Nesterov.Lemma216_Nonneg
noncomputable section
set_option autoImplicit false
universe u
example : {E : Type u} →
  [inst : NormedAddCommGroup.{u} E] →
    [@NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)] →
      (Q : Set.{u} E) → (μ : Real) → (f : E → Real) → Prop := @StrongConvexC1NonnegOn
