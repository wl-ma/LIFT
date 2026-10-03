import ReasLibDemo.Sources.Bauschke.Proposition2313_Cocoercive
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  {β : Real} {s : Set.{u} E} {f : @Set.Elem.{u} E s → E}
  (hβ : @LT.lt.{0} Real Real.instLT (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) β)
  (hf : @Cocoercive.{u} E inst inst_1 β s f),
  @LipschitzWith.{u, u} (@Set.Elem.{u} E s) E
    (@instPseudoEMetricSpaceSubtype.{u} E
      (fun (x : E) => @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) s x)
      (@EMetricSpace.toPseudoEMetricSpace.{u} E
        (@MetricSpace.toEMetricSpace.{u} E (@NormedAddCommGroup.toMetricSpace.{u} E inst))))
    (@EMetricSpace.toPseudoEMetricSpace.{u} E
      (@MetricSpace.toEMetricSpace.{u} E (@NormedAddCommGroup.toMetricSpace.{u} E inst)))
    (Real.toNNReal (@Inv.inv.{0} Real Real.instInv β)) f := @Cocoercive.lipschitzWith
