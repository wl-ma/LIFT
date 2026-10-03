import ReasLibDemo.Sources.Bauschke.Proposition2313
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {β : Real} {A : E → Set.{u} E}
  (hA :
    @StronglyMonotone.{u} E inst inst_1 (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) A)
  (hβ : @LT.lt.{0} Real Real.instLT (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) β)
  (hf :
    @Cocoercive.{u} E inst inst_1
      (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd) β
        (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)))
      (@resolventDomain.{u} E inst inst_1 A) (@operatorResolvent.{u} E inst inst_1 A)),
  @StronglyMonotone.{u} E inst inst_1 β A := @Cocoercive.stronglyMonotone_resolvent
