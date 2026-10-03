import ReasLibDemo.Sources.Bauschke.Proposition2313_Resolvent
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {A : E → Set.{u} E} {x z : E},
  Iff (@Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@idAdd.{u} E inst inst_1 A x) z)
    (@Exists.{u + 1} E fun (u : E) =>
      And (@Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (A x) u)
        (@Eq.{u + 1} E z
          (@HAdd.hAdd.{u, u, u} E E E
            (@instHAdd.{u} E
              (@AddCommMagma.toAdd.{u} E
                (@AddCommSemigroup.toAddCommMagma.{u} E
                  (@AddCommMonoid.toAddCommSemigroup.{u} E
                    (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst))))))
            x u))) := @mem_idAdd
