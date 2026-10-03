import ReasLibDemo.Sources.Bauschke.Proposition2313_Resolvent
noncomputable section
set_option autoImplicit false
universe u
example : {E : Type u} →
  [inst : NormedAddCommGroup.{u} E] →
    [@InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)] →
      (A : E → Set.{u} E) → Set.{u} E := @resolventDomain
example : @resolventDomain = (fun {E : Type u} [inst : NormedAddCommGroup.{u} E]
    [inst_1 :
      @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
    (A : E → Set.{u} E) =>
  @Set.iUnion.{u, u + 1} E E fun (x : E) => @idAdd.{u} E inst inst_1 A x) := rfl
