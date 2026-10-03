import ReasLibDemo.Sources.Beck.Lemma520
import ReasLibDemo.Sources.Beck.Example521

/- These clients test source interfaces and boundary cases, not proof trust. -/

example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] {σ : ℝ} {f : E → EReal}
    (hf : StrongConvex σ f) :
    StrongConvex σ (f + fun _ => (⊤ : EReal)) := by
  apply StrongConvex.add_convex hf
  · intro x
    exact bot_lt_top
  · intro x hx
    exact (lt_irrefl (⊤ : EReal) hx.2).elim
  · intro x hx
    exact (lt_irrefl (⊤ : EReal) hx.2).elim

example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] {σ : ℝ} (hσ : 0 < σ) :
    StrongConvex σ ((fun _ : E => (⊤ : EReal)) + fun _ => (⊤ : EReal)) := by
  have hf : StrongConvex σ (fun _ : E => (⊤ : EReal)) :=
    { sigmaPos := hσ
      botLt := fun _ => bot_lt_top
      convexDomain := by
        intro x hx
        exact (lt_irrefl (⊤ : EReal) hx.2).elim
      leCombo := by
        intro x hx
        exact (lt_irrefl (⊤ : EReal) hx.2).elim }
  apply StrongConvex.add_convex hf
  · intro x
    exact bot_lt_top
  · intro x hx
    exact (lt_irrefl (⊤ : EReal) hx.2).elim
  · intro x hx
    exact (lt_irrefl (⊤ : EReal) hx.2).elim

example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] {σ : ℝ} {f g : E → EReal}
    (hf : StrongConvex σ f) (hbot : ∀ x, ⊥ < g x)
    (hconvex : Convex ℝ (effectiveDomain g))
    (hjensen : ∀ x ∈ effectiveDomain g, ∀ y ∈ effectiveDomain g,
      ∀ t ∈ Set.Icc (0 : ℝ) 1,
        g (t • x + (1 - t) • y) ≤
          (t : EReal) * g x + ((1 - t) : EReal) * g y)
    (_disjoint : Disjoint (effectiveDomain f) (effectiveDomain g)) :
    StrongConvex σ (f + g) :=
  StrongConvex.add_convex hf hbot hconvex hjensen

example : StrongConvex (1 : ℝ)
    (fun x : ℝ => ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal) +
      erealIndicator ({0} : Set ℝ) x) :=
  halfNormSq_add_erealIndicator_strongConvex (Set.singleton_nonempty 0)
    (convex_singleton 0)

example (x : ℝ) (hx : x ≠ 0) :
    ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal) +
      erealIndicator ({0} : Set ℝ) x = ⊤ :=
  halfNormSq_add_erealIndicator_eq_top_of_notMem
    (by simpa only [Set.mem_singleton_iff] using hx)

example (C : Set ℝ) :
    effectiveDomain (fun x : ℝ =>
      ((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal) + erealIndicator C x) = C :=
  effectiveDomain_halfNormSq_add_erealIndicator C
