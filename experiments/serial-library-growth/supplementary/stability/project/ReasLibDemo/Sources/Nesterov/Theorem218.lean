module

public import ReasLib.Analysis.Convex.StrongC1

@[expose] public section

universe u

namespace Nesterov

/-- Nesterov Theorem218. Let `E` be a finite-dimensional real normed space with an arbitrary norm,
and let `f` lie in `S¹_μ(E, ‖·‖)`, that is `StrongConvexC1On Set.univ μ f`. Then `0 < μ` and `f` is
`ContDiffOn ℝ 1` on the whole space. If `xStar : E` is an arbitrary point whose derivative vanishes,
`fderiv ℝ f xStar = 0`, then for every `x : E`,
`f xStar + μ / 2 * ‖x - xStar‖ ^ 2 ≤ f x`. Existence of such an `xStar` is not asserted.

Under `hf`, this premise is the zero derivative: `contDiffOn_univ` together with
`DifferentiableAt.hasFDerivAt` and `HasFDerivAt.fderiv` give
`HasFDerivAt f (0 : E →L[ℝ] ℝ) xStar`, and `hasFDerivWithinAt_univ` matches the witness used by
`StrongConvexC1On.le_of_hasFDerivWithinAt`. For any finite basis `b : Basis ι ℝ E`, the same
premise is equivalent to `(fderiv ℝ f xStar) (b i) = 0` for every `i`, the coordinate partials,
because a continuous linear map is determined by its values on a basis via
`ContinuousLinearMap.ext_iff`. It is not `gradient` and does not need `InnerProductSpace`.
`fderivWithin ℝ f Set.univ` agrees with `fderiv` by `fderivWithin_univ`; the public premise uses
`fderiv`. -/
theorem StrongConvexC1On.le_of_fderiv_eq_zero
    {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    {μ : ℝ} {f : E → ℝ} {xStar : E}
    (hf : StrongConvexC1On Set.univ μ f) (hderiv : fderiv ℝ f xStar = 0) :
    ∀ x : E, f xStar + μ / 2 * ‖x - xStar‖ ^ 2 ≤ f x := _root_.StrongConvexC1On.le_of_fderiv_eq_zero hf hderiv

end Nesterov

end
