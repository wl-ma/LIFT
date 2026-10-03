import ReasLibDemo.Sources.Bauschke.Proposition2313_Resolvent
noncomputable section
set_option autoImplicit false
universe u
example : {E : Type u} →
  [inst : NormedAddCommGroup.{u} E] →
    [@InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)] →
      (A : E → Set.{u} E) → E → Set.{u} E := @idAdd
example : @idAdd = (fun {E : Type u} [inst : NormedAddCommGroup.{u} E]
    [@InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
    (A : E → Set.{u} E) (x : E) =>
  @Set.image.{u, u} E E
    (fun (u : E) =>
      @HAdd.hAdd.{u, u, u} E E E
        (@instHAdd.{u} E
          (@AddCommMagma.toAdd.{u} E
            (@AddCommSemigroup.toAddCommMagma.{u} E
              (@AddCommMonoid.toAddCommSemigroup.{u} E
                (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst))))))
        x u)
    (A x)) := rfl
