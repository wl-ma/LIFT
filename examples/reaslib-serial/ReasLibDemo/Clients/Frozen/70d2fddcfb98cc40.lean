import ReasLibDemo.Sources.Nesterov.Lemma216_Nonneg
noncomputable section
set_option autoImplicit false
universe u
example : {E : Type u} →
  [inst : NormedAddCommGroup.{u} E] →
    [@NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)] →
      (Q : Set.{u} E) → (f : E → Real) → Prop := @ConvexC1On
example : @ConvexC1On = (fun {E : Type u} [inst : NormedAddCommGroup.{u} E]
    [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
    (Q : Set.{u} E) (f : E → Real) =>
  @StrongConvexC1NonnegOn.{u} E inst inst_1 Q
    (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) f) := rfl
