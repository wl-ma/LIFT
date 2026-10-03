import ReasLibDemo.Sources.Synthesis.C1ERealBridge
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {μ : Real} {f : E → Real},
  Iff (@StrongConvex.{u} E inst inst_1 μ fun (x : E) => Real.toEReal (f x))
    (And (@LT.lt.{0} Real Real.instLT (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) μ)
      (@StrongConvexOn.{u} E inst
        (@InnerProductSpace.toNormedSpace.{0, u} Real E Real.instRCLike
          (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
        (@Set.univ.{u} E) μ f)) := @StrongConvex.coe_iff_strongConvexOn_univ
