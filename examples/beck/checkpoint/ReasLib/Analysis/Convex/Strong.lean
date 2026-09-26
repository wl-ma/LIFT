module

public import Mathlib.Analysis.Convex.Strong

/-!
# Strong convexity

Basic closure properties of `m`-strong convexity on a real normed space.
`x ↦ (m / 2) * ‖x‖ ^ 2` is `m`-strongly convex on a convex subset of a real inner product space.
-/

public section

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] {s t : Set E} {m : ℝ}
  {f g : E → ℝ}

namespace StrongConvexOn

/-- If `f` is `m`-strongly convex on `t` and `s ⊆ t` is convex, then `f` is `m`-strongly convex
on `s`. -/
theorem subset (hf : StrongConvexOn t m f) (hst : s ⊆ t) (hs : Convex ℝ s) :
    StrongConvexOn s m f := by
  unfold StrongConvexOn at hf ⊢
  exact ⟨hs, fun x hx y hy a b ha hb hab ↦ hf.2 (hst hx) (hst hy) ha hb hab⟩

/-- If `f` is `m`-strongly convex on `s` and `g` is convex on `s`, then `f + g` is `m`-strongly
convex on `s`. -/
theorem add_convexOn (hf : StrongConvexOn s m f) (hg : ConvexOn ℝ s g) :
    StrongConvexOn s m (f + g) := by
  unfold StrongConvexOn at hf ⊢
  have hfg := UniformConvexOn.add hf hg.uniformConvexOn_zero
  have hmod :
      (fun r : ℝ ↦ m / (2 : ℝ) * r ^ 2) + (0 : ℝ → ℝ) =
        fun r : ℝ ↦ m / (2 : ℝ) * r ^ 2 := by
    ext r
    exact add_zero _
  simpa [hmod] using hfg

/-- If `f` is `m`-strongly convex on `s` and `f` agrees with `g` on `s`, then `g` is
`m`-strongly convex on `s`. -/
theorem congr (hf : StrongConvexOn s m f) (hfg : Set.EqOn f g s) : StrongConvexOn s m g := by
  unfold StrongConvexOn at hf ⊢
  refine ⟨hf.1, fun x hx y hy a b ha hb hab ↦ ?_⟩
  simpa only [← hfg hx, ← hfg hy, ← hfg (hf.1 hx hy ha hb hab)] using hf.2 hx hy ha hb hab

section

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- `x ↦ (m / 2) * ‖x‖ ^ 2` is `m`-strongly convex on a convex subset of a real inner product
space. -/
theorem mul_sq_norm {s : Set E} (hs : Convex ℝ s) (m : ℝ) :
    StrongConvexOn s m (fun x ↦ m / (2 : ℝ) * ‖x‖ ^ 2) := by
  rw [strongConvexOn_iff_convex]
  have hconst : ConvexOn ℝ s (fun _ : E ↦ (0 : ℝ)) := convexOn_const (0 : ℝ) hs
  convert hconst using 1
  funext x
  ring

end

end StrongConvexOn

end
