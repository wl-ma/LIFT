module

public import ReasLib.Analysis.Convex.Strong

/- Beck Definition516 (1). In the book the ambient space is a finite-dimensional real inner product
space. A function `f` with values in `(-∞, ∞]` is `σ`-strongly convex when `0 < σ`, `f` never takes
the value `⊥`, `effectiveDomain f` is convex, and the quadratic deficit inequality holds for every
`x, y` in that domain and every weight `t ∈ Set.Icc (0 : ℝ) 1`. The weight `t` stands for the
source parameter λ, and `σ` is taken with respect to the endowed norm `‖·‖`. -/
#check (strongConvex_iff :
  ∀ {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E] (σ : ℝ) (f : E → EReal),
    StrongConvex σ f ↔
      0 < σ ∧ (∀ x, ⊥ < f x) ∧ Convex ℝ (effectiveDomain f) ∧
        ∀ x ∈ effectiveDomain f, ∀ y ∈ effectiveDomain f, ∀ t ∈ Set.Icc (0 : ℝ) 1,
          f (t • x + (1 - t) • y) ≤
            (t : EReal) * f x + ((1 - t) : EReal) * f y -
              ((σ / 2 * t * (1 - t) * ‖x - y‖ ^ 2 : ℝ) : EReal))

/- Beck Definition516 (2). Strong convexity implies Jensen's inequality on the effective domain:
for `x, y` in `effectiveDomain f` and every weight `t ∈ Set.Icc (0 : ℝ) 1`,
`f (t • x + (1 - t) • y) ≤ (t : EReal) * f x + ((1 - t) : EReal) * f y`. -/
#check (StrongConvex.jensen :
  ∀ {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {σ : ℝ} {f : E → EReal},
    StrongConvex σ f →
      ∀ {x y : E}, x ∈ effectiveDomain f → y ∈ effectiveDomain f →
        ∀ {t : ℝ}, t ∈ Set.Icc (0 : ℝ) 1 →
          f (t • x + (1 - t) • y) ≤ (t : EReal) * f x + ((1 - t) : EReal) * f y)
