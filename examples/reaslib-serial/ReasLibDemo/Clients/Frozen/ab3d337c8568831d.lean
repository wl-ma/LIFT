import ReasLibDemo.Sources.Synthesis.C1ERealBridge
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  [@FiniteDimensional.{0, u} Real E Real.instDivisionRing (@NormedAddCommGroup.toAddCommGroup.{u} E inst)
      (@NormedSpace.toModule.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)
        (@InnerProductSpace.toNormedSpace.{0, u} Real E Real.instRCLike
          (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1))]
  {μ : Real} {f : E → Real}
  (hμ : @LT.lt.{0} Real Real.instLT (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) μ)
  (hf :
    @ContDiff.{0, u, 0} Real (@DenselyNormedField.toNontriviallyNormedField.{0} Real Real.denselyNormedField) E inst
      (@InnerProductSpace.toNormedSpace.{0, u} Real E Real.instRCLike
        (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
      Real Real.normedAddCommGroup
      (@InnerProductSpace.toNormedSpace.{0, 0} Real Real Real.instRCLike
        (@NormedAddCommGroup.toSeminormedAddCommGroup.{0} Real Real.normedAddCommGroup)
        (@RCLike.toInnerProductSpaceReal.{0} Real Real.instRCLike))
      (@OfNat.ofNat.{0} (WithTop.{0} ENat) (nat_lit 1)
        (@One.toOfNat1.{0} (WithTop.{0} ENat)
          (@WithTop.one.{0} ENat (@AddMonoidWithOne.toOne.{0} ENat instAddMonoidWithOneENat))))
      f),
  Iff
    (@StrongConvexC1On.{u} E inst
      (@InnerProductSpace.toNormedSpace.{0, u} Real E Real.instRCLike
        (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
      (@Set.univ.{u} E) μ f)
    (@StrongConvex.{u} E inst inst_1 μ fun (x : E) => Real.toEReal (f x)) := @StrongConvexC1On.iff_strongConvex_coe
