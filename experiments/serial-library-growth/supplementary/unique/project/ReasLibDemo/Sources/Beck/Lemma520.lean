module

public import ReasLib.Analysis.Convex.Strong

@[expose] public section

universe u

/-Beck Lemma520-/
#check (StrongConvex.add_convex : ∀ {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E] {σ : ℝ} {f g : E → EReal}, StrongConvex σ f → (∀ x, ⊥ < g x) → Convex ℝ (effectiveDomain g) → (∀ x ∈ effectiveDomain g, ∀ y ∈ effectiveDomain g, ∀ t ∈ Set.Icc (0 : ℝ) 1, g (t • x + (1 - t) • y) ≤ (t : EReal) * g x + ((1 - t) : EReal) * g y) → StrongConvex σ (f + g))
