module

import ReasLibDemo.Sources.Synthesis.C1ERealBridge
import ReasLibDemo.Sources.Nesterov.Lemma216
import ReasLibDemo.Sources.Nesterov.Theorem218

universe u

-- Both zero weights are permitted on arbitrary, potentially disjoint domains.
example {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    (Q1 Q2 : Set E) (mu1 mu2 : ℝ) (f1 f2 : E → ℝ)
    (hf1 : StrongConvexC1NonnegOn Q1 mu1 f1) (hf2 : StrongConvexC1NonnegOn Q2 mu2 f2) :
    StrongConvexC1NonnegOn (Q1 ∩ Q2) 0 (fun _ : E ↦ 0) := by
  simpa using StrongConvexC1NonnegOn.nonnegCombination Q1 Q2 mu1 mu2 0 0 f1 f2 hf1 hf2 (le_refl 0) (le_refl 0)

-- Zero curvature is retained for both summands, without an inner-product instance.
example {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    (Q1 Q2 : Set E) (a b : ℝ) (f1 f2 : E → ℝ)
    (hf1 : ConvexC1On Q1 f1) (hf2 : ConvexC1On Q2 f2) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    ConvexC1On (Q1 ∩ Q2) (fun x ↦ a * f1 x + b * f2 x) := by
  simpa [ConvexC1On] using StrongConvexC1NonnegOn.nonnegCombination Q1 Q2 0 0 a b f1 f2 hf1 hf2 ha hb

-- Empty-domain membership is constructible, not an excluded premise.
example {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] :
    StrongConvexC1NonnegOn (∅ : Set E) 0 (fun _ : E ↦ (0 : ℝ)) := by
  refine StrongConvexC1NonnegOn.ofConditions convex_empty (le_refl 0) ?_ ?_
  · intro x hx
    exact False.elim hx
  · intro x hx
    exact False.elim hx

-- A lower-dimensional singleton is accepted without UniqueDiffOn or openness.
example {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    (z : E) (f g : E → ℝ) (m n : ℝ)
    (hf : StrongConvexC1NonnegOn ({z} : Set E) m f)
    (hg : StrongConvexC1NonnegOn ({z} : Set E) n g) :
    StrongConvexC1NonnegOn ({z} : Set E) (m + n) (fun x ↦ f x + g x) := by
  simpa using StrongConvexC1NonnegOn.nonnegCombination ({z} : Set E) ({z} : Set E) m n 1 1 f g hf hg zero_le_one zero_le_one

-- The positive-parameter representation agrees in both directions with the old interface.
example {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (Q : Set E) (m : ℝ) (f : E → ℝ) :
    StrongConvexC1On Q m f ↔ StrongConvexC1NonnegOn Q m f ∧ 0 < m :=
  strongConvexC1On_iff_nonneg_and_pos Q m f

-- The derived bridge exposes both directions only in its explicit inner-product scope.
example {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
    {m : ℝ} {f : E → ℝ} (hm : 0 < m) (hf : ContDiff ℝ 1 f) :
    (StrongConvexC1On Set.univ m f → StrongConvex m (fun x ↦ (f x : EReal))) ∧
    (StrongConvex m (fun x ↦ (f x : EReal)) → StrongConvexC1On Set.univ m f) :=
  ⟨(StrongConvexC1On.iff_strongConvex_coe hm hf).mp,
    (StrongConvexC1On.iff_strongConvex_coe hm hf).mpr⟩

-- Stationarity is a premise at a given point, with the arbitrary norm unchanged.
example {E : Type u} [NormedAddCommGroup E] [NormedSpace ℝ E] [FiniteDimensional ℝ E]
    {m : ℝ} {f : E → ℝ} (hf : StrongConvexC1On Set.univ m f) {xStar : E}
    (hz : fderiv ℝ f xStar = 0) (x : E) :
    f xStar + m / 2 * ‖x - xStar‖ ^ 2 ≤ f x :=
  hf.le_of_fderiv_eq_zero hz x
