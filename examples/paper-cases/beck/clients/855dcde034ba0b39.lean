import FirstOrderMethodsOptimization_Beck_2017.Chap05.Theorem_5_17
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {E : Type u} [inst : NormedAddCommGroup.{u} E]
  [inst_1 : @InnerProductSpace.{0, u} Real E Real.instRCLike (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)]
  (f : E → EReal) (σ : Real)
  (hσ : @LT.lt.{0} Real Real.instLT (@OfNat.ofNat.{0} Real (nat_lit 0) (@Zero.toOfNat0.{0} Real Real.instZero)) σ)
  (h_ne_bot : ∀ (x : E), @Ne.{1} EReal (f x) (@Bot.bot.{0} EReal instBotEReal)),
  Iff
    (@is_strongly_convex_function.{u} E inst
      (@InnerProductSpace.toNormedSpace.{0, u} Real E Real.instRCLike
        (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1)
      f σ)
    (@is_convex_function.{u} E (@AddCommGroup.toAddCommMonoid.{u} E (@NormedAddCommGroup.toAddCommGroup.{u} E inst))
      (@NormedSpace.toModule.{0, u} Real E Real.normedField (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst)
        (@InnerProductSpace.toNormedSpace.{0, u} Real E Real.instRCLike
          (@NormedAddCommGroup.toSeminormedAddCommGroup.{u} E inst) inst_1))
      fun (x : E) =>
      @HSub.hSub.{0, 0, 0} EReal EReal EReal
        (@instHSub.{0} EReal
          (@SubNegMonoid.toSub.{0} EReal (@SubNegZeroMonoid.toSubNegMonoid.{0} EReal EReal.instSubNegZeroMonoid)))
        (f x)
        (Real.toEReal
          (@HMul.hMul.{0, 0, 0} Real Real Real (@instHMul.{0} Real Real.instMul)
            (@HDiv.hDiv.{0, 0, 0} Real Real Real
              (@instHDiv.{0} Real (@DivInvMonoid.toDiv.{0} Real Real.instDivInvMonoid)) σ
              (@OfNat.ofNat.{0} Real (nat_lit 2)
                (@instOfNatAtLeastTwo.{0} Real (nat_lit 2) Real.instNatCast
                  (@Nat.instAtLeastTwoHAddOfNat (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1)))
                    (@Nat.instNeZeroSucc (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))))))
            (@HPow.hPow.{0, 0, 0} Real Nat Real (@instHPow.{0, 0} Real Nat (@Monoid.toPow.{0} Real Real.instMonoid))
              (@Norm.norm.{u} E (@NormedAddCommGroup.toNorm.{u} E inst) x)
              (@OfNat.ofNat.{0} Nat (nat_lit 2) (instOfNatNat (nat_lit 2))))))) := @is_strongly_convex_function_iff_sub_half_sigma_norm_sq_is_convex
