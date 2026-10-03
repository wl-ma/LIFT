import ReasLibDemo.Sources.Bauschke.Example224iv
import ReasLibDemo.Sources.Bauschke.Proposition2313
import Mathlib

open scoped InnerProductSpace

-- The theorem remains usable without completeness, finite dimension, or smoothness.
example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {β : ℝ} {f : E → EReal} (hf : StrongConvex β f)
    (hdom : (effectiveDomain f).Nonempty) :
    StronglyMonotone β (subdifferential f) :=
  StrongConvex.subdifferential_stronglyMonotone hf hdom

-- Positive-infinity points are outside the subdifferential domain.
example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {f : E → EReal} {x : E} (hx : f x = ⊤) : subdifferential f x = ∅ := by
  apply subdifferential_eq_empty_of_notMem_effectiveDomain
  simp [effectiveDomain, hx]

-- The representation also excludes negative-infinity points.
example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {f : E → EReal} {x : E} (hx : f x = ⊥) : subdifferential f x = ∅ := by
  apply subdifferential_eq_empty_of_notMem_effectiveDomain
  simp [effectiveDomain, hx]

-- Empty graphs need no artificial nonemptiness or total-domain premise.
example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ) :
    StronglyMonotone β (fun _ : E => ∅) := by
  intro x y u v hu hv
  exact False.elim hu

example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] :
    resolventDomain (fun _ : E => ∅) = ∅ := by
  ext z
  simp [resolventDomain, idAdd]

-- A genuine proper resolvent domain is permitted: the one-point graph.
example : resolventDomain (fun x : ℝ => if x = 0 then {0} else ∅) = {0} := by
  ext z
  simp [resolventDomain, idAdd]

-- Cocoercivity on an empty subtype is a vacuous property, not a total-map claim.
example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ) :
    Cocoercive β (fun z : (∅ : Set E) => (z : E)) := by
  intro z
  exact False.elim z.property

-- Both directions retain merely monotone A, without maximal monotonicity.
example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {β : ℝ} {A : E → Set E} (hA : StronglyMonotone 0 A) (hβ : 0 < β)
    (hstrong : StronglyMonotone β A) :
    Cocoercive (β + 1) (operatorResolvent A) :=
  StronglyMonotone.resolvent_cocoercive hA hβ hstrong

example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {β : ℝ} {A : E → Set E} (hA : StronglyMonotone 0 A) (hβ : 0 < β)
    (hcoco : Cocoercive (β + 1) (operatorResolvent A)) :
    StronglyMonotone β A :=
  Cocoercive.stronglyMonotone_resolvent hA hβ hcoco

-- Any graph witness recovers the chosen resolver on its exact subtype domain.
example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {A : E → Set E} (hA : StronglyMonotone 0 A) {z x : E} (hx : z - x ∈ A x) :
    ∃ hz : z ∈ resolventDomain A, operatorResolvent A ⟨z, hz⟩ = x := by
  refine ⟨exists_mem_resolventDomain_of_sub_mem hx, ?_⟩
  exact resolvent_eq_of_sub_mem hA hx _

-- The sharp source constant is retained, for arbitrary positive beta.
example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {β : ℝ} {A : E → Set E} (hA : StronglyMonotone 0 A) (hβ : 0 < β)
    (hcoco : Cocoercive (β + 1) (operatorResolvent A)) (z w : resolventDomain A) :
    ‖operatorResolvent A z - operatorResolvent A w‖ ≤
      (1 / (β + 1)) * ‖(z : E) - (w : E)‖ :=
  resolvent_norm_sub_le_of_cocoercive hA hβ hcoco z w

example {β : ℝ} (hβ : 0 < β) :
    (Real.toNNReal (1 / (β + 1)) : ℝ) = 1 / (β + 1) :=
  resolvent_lipschitzWith_coe hβ
