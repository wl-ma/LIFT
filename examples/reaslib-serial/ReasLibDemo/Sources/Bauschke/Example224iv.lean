module

public import ReasLib.Analysis.Convex.Subdifferential

@[expose] public section

open scoped InnerProductSpace

universe u

/- Bauschke Example224iv
If `f : E → EReal` is proper and `β`-strongly convex, then `subdifferential f` is `β`-strongly
monotone. Properness means `(effectiveDomain f).Nonempty` together with `StrongConvex β f`, which
excludes the value `⊥`. Equivalently, for all `x y u v` with `u ∈ subdifferential f x` and
`v ∈ subdifferential f y`, `β * ‖x - y‖ ^ 2 ≤ ⟪x - y, u - v⟫_ℝ`. -/
#check (StrongConvex.subdifferential_stronglyMonotone :
  ∀ {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {β : ℝ} {f : E → EReal},
    StrongConvex β f → (effectiveDomain f).Nonempty →
      StronglyMonotone β (subdifferential f))

#check (StrongConvex.le_inner_subdifferential :
  ∀ {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {β : ℝ} {f : E → EReal},
    StrongConvex β f → (effectiveDomain f).Nonempty →
      ∀ {x y u v : E}, u ∈ subdifferential f x → v ∈ subdifferential f y →
        β * ‖x - y‖ ^ 2 ≤ ⟪x - y, u - v⟫_ℝ)
