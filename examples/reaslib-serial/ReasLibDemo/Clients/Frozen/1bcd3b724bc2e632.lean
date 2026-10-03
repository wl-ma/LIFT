import ReasLibDemo.Sources.Nesterov.Lemma216_Nonneg
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  (Q : Set.{u} E) (μ : Real) (f : E → Real),
  Iff (@StrongConvexC1On.{u} E inst inst_1 Q μ f)
    (And (@StrongConvexC1NonnegOn.{u} E inst inst_1 Q μ f)
      (@LT.lt.{0} Real Real.instLT (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) μ)) := @strongConvexC1On_iff_nonneg_and_pos
