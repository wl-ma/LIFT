module

public import ReasLib
public import ReasLibDemo.Sources.Nesterov.Theorem219
public import Mathlib.Analysis.Calculus.ContDiff.Operations
public import Mathlib.Analysis.Calculus.ContDiff.Basic
public import Mathlib.Tactic

@[expose] public section

/-!
A single quadratic function for independent source-view clients. These examples
consume the public library; they are evaluator-written tests, not model results.
-/

namespace ReasLibDemoClients

universe u

/-- The extended-real view of one half of the squared Hilbert norm. -/
noncomputable def halfNormSq {E : Type u} [NormedAddCommGroup E] (x : E) : EReal :=
  (((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ)

/-- The chosen quadratic is finite everywhere. -/
theorem halfNormSq_domain {E : Type u} [NormedAddCommGroup E] :
    effectiveDomain (halfNormSq (E := E)) = Set.univ := by
  ext x
  constructor
  · intro _
    exact Set.mem_univ x
  · intro _
    exact ⟨EReal.bot_lt_coe _, EReal.coe_lt_top _⟩

/-- The same function is proper on every real inner product space. -/
theorem halfNormSq_proper {E : Type u} [NormedAddCommGroup E] :
    (∀ x : E, ⊥ < halfNormSq x) ∧
      (effectiveDomain (halfNormSq (E := E))).Nonempty := by
  constructor
  · intro x
    exact EReal.bot_lt_coe _
  · rw [halfNormSq_domain]
    exact ⟨0, Set.mem_univ 0⟩

/-- The published extended-real bridge proves unit strong convexity of the quadratic. -/
theorem halfNormSq_strongConvex {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] : StrongConvex 1 (halfNormSq (E := E)) := by
  apply strongConvex_iff_strongConvexOn.mpr
  refine ⟨by norm_num, halfNormSq_proper.1, ?_⟩
  rw [halfNormSq_domain, strongConvexOn_iff_convex]
  convert convexOn_const (0 : ℝ) (convex_univ : Convex ℝ (Set.univ : Set E)) using 1
  ext x
  change (((((1 : ℝ) / 2) * ‖x‖ ^ 2 : ℝ) : EReal).toReal) -
    ((1 : ℝ) / 2) * ‖x‖ ^ 2 = 0
  rw [EReal.toReal_coe]
  exact sub_self _

/-- The Beck view is the full extended-real quadratic-shift conclusion. -/
theorem halfNormSq_beck {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] :
    Convex ℝ (effectiveDomain (subNormSq 1 (halfNormSq (E := E)))) ∧
      ∀ x ∈ effectiveDomain (subNormSq 1 (halfNormSq (E := E))),
      ∀ y ∈ effectiveDomain (subNormSq 1 (halfNormSq (E := E))),
      ∀ t ∈ Set.Icc (0 : ℝ) 1,
        subNormSq 1 halfNormSq (t • x + (1 - t) • y) ≤
          (t : EReal) * subNormSq 1 halfNormSq x +
            ((1 - t : ℝ) : EReal) * subNormSq 1 halfNormSq y := by
  exact (strongConvex_iff_convex_subNormSq (by norm_num) halfNormSq_proper.1).mp
    halfNormSq_strongConvex


/-- The Bauschke definition view uses the same quadratic on any real inner product space. -/
theorem halfNormSq_bauschke_inequality {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] :
    ∀ x ∈ effectiveDomain (halfNormSq (E := E)),
    ∀ y ∈ effectiveDomain (halfNormSq (E := E)), ∀ α ∈ Set.Ioo (0 : ℝ) 1,
      halfNormSq (α • x + (1 - α) • y) +
          ((α * (1 - α) * ((1 : ℝ) / 2) * ‖x - y‖ ^ 2 : ℝ) : EReal) ≤
        (α : EReal) * halfNormSq x + ((1 - α : ℝ) : EReal) * halfNormSq y := by
  exact ((StrongConvex.iff_proper_Ioo 1 (halfNormSq (E := E))).mp
    ⟨halfNormSq_strongConvex, halfNormSq_proper.2⟩).2.2.2

/-- The Bauschke proposition gives the global extended-real Jensen inequality for the shift. -/
theorem halfNormSq_bauschke_shift {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] :
    ∀ x y : E, ∀ α ∈ Set.Ioo (0 : ℝ) 1,
      subNormSq 1 halfNormSq (α • x + (1 - α) • y) ≤
        (α : EReal) * subNormSq 1 halfNormSq x +
          ((1 - α : ℝ) : EReal) * subNormSq 1 halfNormSq y := by
  exact (StrongConvex.leCombo_Ioo_iff_convex_subNormSq 1 (halfNormSq (E := E))
    (by norm_num) halfNormSq_proper.1 halfNormSq_proper.2).mp
      halfNormSq_bauschke_inequality

end ReasLibDemoClients

#print axioms ReasLibDemoClients.halfNormSq_domain
#print axioms ReasLibDemoClients.halfNormSq_proper
#print axioms ReasLibDemoClients.halfNormSq_strongConvex
#print axioms ReasLibDemoClients.halfNormSq_beck

#print axioms ReasLibDemoClients.halfNormSq_bauschke_inequality
#print axioms ReasLibDemoClients.halfNormSq_bauschke_shift

/-!
Independent consumers of the original Nesterov interfaces: empty and singleton
domains, a scalar quadratic, a lower-dimensional maximum-norm example, and
transport between real and extended-real values.
-/

namespace ReasLibNesterovClients

noncomputable def scalarQuadratic (x : ℝ) : ℝ := x ^ 2 / 2

/-- The same half-squared norm used for the earlier source views, now real-valued. -/
theorem scalarQuadratic_c1 : ContDiff ℝ 1 scalarQuadratic := by
  unfold scalarQuadratic
  fun_prop

/-- Empty domains are permitted, for every positive modulus and every function. -/
theorem empty_domain (μ : ℝ) (hμ : 0 < μ) (f : ℝ → ℝ) :
    StrongConvexC1On ∅ μ f := by
  refine StrongConvexC1On.ofConditions convex_empty hμ ?_ ?_
  · intro x hx
    exact False.elim hx
  · intro x hx
    exact False.elim hx

/-- A singleton has no nonzero segment directions and needs no open-domain premise. -/
theorem singleton_domain (μ : ℝ) (hμ : 0 < μ) (x : ℝ) :
    StrongConvexC1On {x} μ scalarQuadratic := by
  refine StrongConvexC1On.ofConditions (convex_singleton x) hμ
    scalarQuadratic_c1.contDiffOn ?_
  intro a ha b hb
  simp only [Set.mem_singleton_iff] at ha hb
  subst a
  subst b
  simp

/-- Source Jensen equivalence certifies the concrete unit-modulus quadratic. -/
theorem scalarQuadratic_strong : StrongConvexC1On Set.univ 1 scalarQuadratic := by
  apply (StrongConvexC1On.iff_convexCombo Set.univ 1 scalarQuadratic
    convex_univ (by norm_num) scalarQuadratic_c1.contDiffOn).mpr
  intro x hx y hy a ha
  simp only [scalarQuadratic, smul_eq_mul, Real.norm_eq_abs, sq_abs]
  nlinarith

/-- The derivative-monotonicity view concerns the same concrete function. -/
theorem scalarQuadratic_monotone (x y : ℝ) :
    ‖x - y‖ ^ 2 ≤
      (fderivWithin ℝ scalarQuadratic Set.univ x) (x - y) -
        (fderivWithin ℝ scalarQuadratic Set.univ y) (x - y) := by
  simpa using (StrongConvexC1On.iff_fderivMono Set.univ 1 scalarQuadratic
    convex_univ (by norm_num) scalarQuadratic_c1.contDiffOn).mp
      scalarQuadratic_strong x (Set.mem_univ x) y (Set.mem_univ y)

def axis : Set (ℝ × ℝ) := {p | p.2 = 0}
noncomputable def axisQuadratic (p : ℝ × ℝ) : ℝ := p.1 ^ 2 / 2
noncomputable def tiltedQuadratic (c : ℝ) (p : ℝ × ℝ) : ℝ := p.1 ^ 2 / 2 + c * p.2

/-- The ambient product norm is the maximum norm, not the Euclidean product norm. -/
theorem ambient_max_norm : ‖((1 : ℝ), (1 : ℝ))‖ = 1 := by
  norm_num [Prod.norm_def]

theorem axis_convex : Convex ℝ axis := by
  intro x hx y hy a b ha hb hab
  change x.2 = 0 at hx
  change y.2 = 0 at hy
  change a * x.2 + b * y.2 = 0
  simp [hx, hy]

theorem axisQuadratic_c1 : ContDiff ℝ 1 axisQuadratic := by
  unfold axisQuadratic
  fun_prop

/-- A lower-dimensional domain works in a genuinely non-inner-product ambient norm. -/
theorem axisQuadratic_strong : StrongConvexC1On axis 1 axisQuadratic := by
  apply (StrongConvexC1On.iff_convexCombo axis 1 axisQuadratic
    axis_convex (by norm_num) axisQuadratic_c1.contDiffOn).mpr
  intro x hx y hy a ha
  change x.2 = 0 at hx
  change y.2 = 0 at hy
  have hnorm : ‖x - y‖ ^ 2 = (x.1 - y.1) ^ 2 := by
    simp [Prod.norm_def, hx, hy, Real.norm_eq_abs, sq_abs]
  rw [hnorm]
  change (a * x.1 + (1 - a) * y.1) ^ 2 / 2 +
    a * (1 - a) * (1 / 2) * (x.1 - y.1) ^ 2 ≤
      a * (x.1 ^ 2 / 2) + (1 - a) * (y.1 ^ 2 / 2)
  nlinarith

/-- Changing the function off the axis does not change its strong convexity on it. -/
theorem tiltedQuadratic_strong (c : ℝ) : StrongConvexC1On axis 1 (tiltedQuadratic c) := by
  apply axisQuadratic_strong.congr
  intro p hp
  change p.2 = 0 at hp
  simp [axisQuadratic, tiltedQuadratic, hp]

/-- Any within-derivative witness, without global derivative uniqueness, is usable. -/
theorem axis_witness_bound (x y : ℝ × ℝ) (hx : x ∈ axis) (hy : y ∈ axis)
    (d : (ℝ × ℝ) →L[ℝ] ℝ) (hd : HasFDerivWithinAt axisQuadratic d axis x) :
    axisQuadratic x + d (y - x) + 1 / 2 * ‖y - x‖ ^ 2 ≤ axisQuadratic y := by
  exact axisQuadratic_strong.le_of_hasFDerivWithinAt hx hy hd

end ReasLibNesterovClients

#print axioms ReasLibNesterovClients.empty_domain
#print axioms ReasLibNesterovClients.singleton_domain
#print axioms ReasLibNesterovClients.scalarQuadratic_strong
#print axioms ReasLibNesterovClients.scalarQuadratic_monotone
#print axioms ReasLibNesterovClients.ambient_max_norm
#print axioms ReasLibNesterovClients.axisQuadratic_strong
#print axioms ReasLibNesterovClients.tiltedQuadratic_strong
#print axioms ReasLibNesterovClients.axis_witness_bound
namespace ReasLibThreeSourceClients

/-- The real-valued and extended-real clients use exactly the same function. -/
theorem same_quadratic (x : ℝ) :
    (ReasLibNesterovClients.scalarQuadratic x : EReal) =
      ReasLibDemoClients.halfNormSq x := by
  unfold ReasLibNesterovClients.scalarQuadratic ReasLibDemoClients.halfNormSq
  congr 1
  rw [Real.norm_eq_abs, sq_abs]
  ring

/-- Recovering real values from the extended-real representation is lossless here. -/
theorem same_real_values (x : ℝ) :
    (ReasLibDemoClients.halfNormSq x).toReal =
      ReasLibNesterovClients.scalarQuadratic x := by
  rw [← same_quadratic, EReal.toReal_coe]

/-- The concrete function satisfies both source representations at unit modulus. -/
theorem shared_quadratic_views :
    StrongConvex 1 (ReasLibDemoClients.halfNormSq (E := ℝ)) ∧
      StrongConvexC1On Set.univ 1 ReasLibNesterovClients.scalarQuadratic := by
  exact ⟨ReasLibDemoClients.halfNormSq_strongConvex,
    ReasLibNesterovClients.scalarQuadratic_strong⟩

end ReasLibThreeSourceClients

#print axioms ReasLibThreeSourceClients.same_quadratic
#print axioms ReasLibThreeSourceClients.same_real_values
#print axioms ReasLibThreeSourceClients.shared_quadratic_views
