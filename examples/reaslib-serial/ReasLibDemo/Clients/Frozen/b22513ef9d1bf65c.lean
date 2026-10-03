import ReasLibDemo.Sources.Nesterov.Lemma216
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @NormedSpace.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  [@FiniteDimensional.{0, u} Real E Real.instDivisionRing (@NormedAddCommGroup.toAddCommGroup.{u} E inst)
      (@NormedSpace.toModule.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)
        inst_1)]
  (Q1 Q2 : Set.{u} E) (mu1 mu2 alpha beta : Real) (f1 f2 : E → Real)
  (hf1 : @StrongConvexC1On.{u} E inst inst_1 Q1 mu1 f1) (hf2 : @StrongConvexC1On.{u} E inst inst_1 Q2 mu2 f2)
  (halpha :
    @LE.le.{0} Real Real.instLE (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) alpha)
  (hbeta : @LE.le.{0} Real Real.instLE (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) beta)
  (hmu :
    @LT.lt.{0} Real Real.instLT (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero))
      (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd)
        (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul) alpha mu1)
        (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul) beta mu2))),
  @StrongConvexC1On.{u} E inst inst_1 (@Inter.inter.{u} (Set.{u} E) (@Set.instInter.{u} E) Q1 Q2)
    (@HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd)
      (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul) alpha mu1)
      (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul) beta mu2))
    fun (x : E) =>
    @HAdd.hAdd.{0, 0, 0} Real Real Real (@instHAdd.{0} Real Real.instAdd)
      (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul) alpha (f1 x))
      (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul) beta (f2 x)) := @StrongConvexC1On.combination
