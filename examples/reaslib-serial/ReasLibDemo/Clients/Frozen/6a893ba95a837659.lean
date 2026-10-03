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
  (hstrong : @StronglyMonotone.{u} E inst inst_1 β A),
  @LipschitzWith.{u, u} (@Set.Elem.{u} E (@resolventDomain.{u} E inst inst_1 A)) E
    (@instPseudoEMetricSpaceSubtype.{u} E
      (fun (x : E) =>
        @Membership.mem.{u, u} E (Set.{u} E) (@Set.instMembership.{u} E) (@resolventDomain.{u} E inst inst_1 A) x)
      (@EMetricSpace.toPseudoEMetricSpace.{u} E
        (@MetricSpace.toEMetricSpace.{u} E (@NormedAddCommGroup.toMetricSpace.{u} E inst))))
    (@EMetricSpace.toPseudoEMetricSpace.{u} E
      (@MetricSpace.toEMetricSpace.{u} E (@NormedAddCommGroup.toMetricSpace.{u} E inst)))
    (Real.toNNReal
      (@HDiv.hDiv.{0, 0, 0} Real Real Real (@instHDiv.{0} Real (@DivInvMonoid.toDiv.{0} Real Real.instDivInvMonoid))
        (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne))
        (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd) β
          (@OfNat.ofNat.{0} Real (nat_lit 1) (@One.toOfNat1.{0} Real Real.instOne)))))
    (@operatorResolvent.{u} E inst inst_1 A) := @resolvent_lipschitzWith
