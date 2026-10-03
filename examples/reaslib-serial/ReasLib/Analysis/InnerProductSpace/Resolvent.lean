module

public import ReasLib.Analysis.InnerProductSpace.StronglyMonotone
public import ReasLib.Analysis.InnerProductSpace.Cocoercive

@[expose] public section

open Set
open scoped InnerProductSpace

universe u

/-- The operator `Id + A`, sending each `x` to the image of `A x` under addition of `x`. -/
def idAdd {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (A : E → Set E) :
    E → Set E :=
  fun x ↦ (fun u ↦ x + u) '' A x

/-- `mem_idAdd`. Membership in `idAdd A x` is existence of `u ∈ A x` with `z = x + u`. -/
theorem mem_idAdd {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] {A : E → Set E}
    {x z : E} : z ∈ idAdd A x ↔ ∃ u, u ∈ A x ∧ z = x + u := by
  -- Image membership is a fiber witness; commute the sum so `z` stands on the left.
  rw [idAdd, mem_image]
  constructor
  · rintro ⟨u, hu, hz⟩
    exact ⟨u, hu, hz.symm⟩
  · rintro ⟨u, hu, hz⟩
    exact ⟨u, hu, hz.symm⟩

/-- The resolvent domain `ran (Id + A)`, equal to `⋃ x, idAdd A x`. -/
def resolventDomain {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (A : E → Set E) : Set E :=
  ⋃ x, idAdd A x

/-- A point lies in `resolventDomain A` exactly when `z = x + u` for some `u ∈ A x`. -/
theorem mem_resolventDomain {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {A : E → Set E} {z : E} :
    z ∈ resolventDomain A ↔ ∃ x, ∃ u, u ∈ A x ∧ z = x + u := by
  -- The resolvent domain is the union of the translated fibers of `A`.
  simp only [resolventDomain, mem_iUnion, mem_idAdd]

/-- A point lies in `resolventDomain A` exactly when `z - x ∈ A x` for some `x`. -/
theorem mem_resolventDomain_iff_sub_mem {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {A : E → Set E} {z : E} : z ∈ resolventDomain A ↔ ∃ x, z - x ∈ A x := by
  -- A sum witness `z = x + u` is exactly the subtraction witness `u = z - x`.
  rw [mem_resolventDomain]
  constructor
  · rintro ⟨x, u, hu, hz⟩
    refine ⟨x, ?_⟩
    rw [hz, add_sub_cancel_left]
    exact hu
  · rintro ⟨x, hx⟩
    refine ⟨x, z - x, hx, ?_⟩
    exact (sub_eq_iff_eq_add').mp rfl

/-- The resolvent of `A` on `resolventDomain A`, chosen as a preimage under `Id + A`.
Monotonicity is not used to choose the value; it is the hypothesis that makes the value unique. -/
noncomputable def operatorResolvent {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (A : E → Set E) (z : resolventDomain A) : E :=
  Classical.choose (Set.mem_iUnion.mp z.property)

/-- The chosen resolvent satisfies `Subtype.val z - operatorResolvent A z ∈ A (operatorResolvent A z)`. -/
theorem resolvent_spec {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {A : E → Set E} (z : resolventDomain A) :
    Subtype.val z - operatorResolvent A z ∈ A (operatorResolvent A z) := by
  -- Choice supplies one `Id + A` fiber; subtracting the index recovers the graph value.
  have hz : Subtype.val z ∈ idAdd A (operatorResolvent A z) :=
    Classical.choose_spec (Set.mem_iUnion.mp z.property)
  rcases mem_idAdd.mp hz with ⟨u, hu, hz⟩
  rw [hz, add_sub_cancel_left]
  exact hu

/-- The ambient point lies in `idAdd A` at the chosen resolvent value. -/
theorem resolvent_mem_idAdd {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {A : E → Set E} (z : resolventDomain A) : Subtype.val z ∈ idAdd A (operatorResolvent A z) := by
  -- The spec witness sums back to the ambient point.
  rw [mem_idAdd]
  refine ⟨Subtype.val z - operatorResolvent A z, resolvent_spec z, ?_⟩
  exact (sub_eq_iff_eq_add').mp rfl

/-- If `z - x ∈ A x`, then `z` belongs to `resolventDomain A`. -/
theorem exists_mem_resolventDomain_of_sub_mem {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {A : E → Set E} {z x : E} (hx : z - x ∈ A x) :
    z ∈ resolventDomain A := by
  -- A subtraction witness is the right-hand side of the domain characterization.
  exact mem_resolventDomain_iff_sub_mem.2 ⟨x, hx⟩

/-- Monotonicity makes the resolvent single-valued: the two graph witnesses `x` and `y` agree. -/
theorem resolvent_unique {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {A : E → Set E} (hA : StronglyMonotone 0 A) {z x y : E} (hx : z - x ∈ A x)
    (hy : z - y ∈ A y) : x = y := by
  -- Zero-modulus monotonicity makes the squared distance of the two witnesses nonpositive.
  have hle : 0 ≤ ⟪x - y, (z - x) - (z - y)⟫_ℝ := by
    simpa only [zero_mul] using hA.le_inner hx hy
  have hdiff : (z - x) - (z - y) = -(x - y) := by
    rw [sub_sub_sub_cancel_left, ← neg_sub]
  rw [hdiff, inner_neg_right, real_inner_self_eq_norm_sq] at hle
  have hsq : ‖x - y‖ ^ 2 = 0 := le_antisymm (neg_nonneg.mp hle) (sq_nonneg _)
  exact sub_eq_zero.mp (norm_eq_zero.mp (sq_eq_zero_iff.mp hsq))

/-- Under monotonicity, every point satisfying `z - x ∈ A x` equals `operatorResolvent A` at `z`. -/
theorem resolvent_eq_of_sub_mem {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {A : E → Set E} (hA : StronglyMonotone 0 A) {z x : E} (hx : z - x ∈ A x)
    (hz : z ∈ resolventDomain A) : operatorResolvent A ⟨z, hz⟩ = x := by
  -- The chosen resolvent and the given witness are both preimages of the same point.
  exact resolvent_unique hA (resolvent_spec ⟨z, hz⟩) hx

/-- Under monotonicity, `z - x ∈ A x` if and only if `x` is the resolvent of `A` at `z`. -/
theorem sub_mem_iff_eq_resolvent {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {A : E → Set E} (hA : StronglyMonotone 0 A) {z x : E} (hz : z ∈ resolventDomain A) :
    z - x ∈ A x ↔ x = operatorResolvent A ⟨z, hz⟩ := by
  constructor
  · intro hx
    -- Uniqueness identifies this graph witness with the chosen resolvent.
    exact (resolvent_eq_of_sub_mem hA hx hz).symm
  · intro hx
    -- Transport the resolvent specification along the witness equality.
    rw [hx]
    exact resolvent_spec ⟨z, hz⟩

/-- For vectors in a real inner product space,
`β * ‖x - y‖ ^ 2 ≤ ⟪x - y, (z - x) - (w - y)⟫_ℝ` if and only if
`(β + 1) * ‖x - y‖ ^ 2 ≤ ⟪x - y, z - w⟫_ℝ`. -/
private lemma mul_normSq_le_inner_sub_iff {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] (β : ℝ) (x y z w : E) :
    β * ‖x - y‖ ^ 2 ≤ ⟪x - y, (z - x) - (w - y)⟫_ℝ ↔
      (β + 1) * ‖x - y‖ ^ 2 ≤ ⟪x - y, z - w⟫_ℝ := by
  -- Move the witness difference into the ambient difference and absorb the squared norm.
  rw [sub_sub_sub_comm, inner_sub_right, real_inner_self_eq_norm_sq, le_sub_iff_add_le]
  have hmul : β * ‖x - y‖ ^ 2 + ‖x - y‖ ^ 2 = (β + 1) * ‖x - y‖ ^ 2 := by
    ring
  rw [hmul]

/-- On a real inner product space, let `A : E → Set E` be monotone and let `0 < β`. Then `A` is
`β`-strongly monotone if and only if `operatorResolvent A` is `(β + 1)`-cocoercive:
`StronglyMonotone β A ↔ Cocoercive (β + 1) (operatorResolvent A)`. Cocoercivity means that for all
`z w : resolventDomain A`,
`(β + 1) * ‖operatorResolvent A z - operatorResolvent A w‖ ^ 2 ≤
  ⟪operatorResolvent A z - operatorResolvent A w, Subtype.val z - Subtype.val w⟫_ℝ`. -/
theorem stronglyMonotone_iff_resolvent_cocoercive {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] (β : ℝ) (A : E → Set E) (hA : StronglyMonotone 0 A) (hβ : 0 < β) :
    StronglyMonotone β A ↔ Cocoercive (β + 1) (operatorResolvent A) := by
  constructor
  · intro hstrong
    -- Strong monotonicity on the two resolvent graph witnesses is cocoercivity.
    rw [cocoercive_iff]
    intro z w
    exact (mul_normSq_le_inner_sub_iff β (operatorResolvent A z) (operatorResolvent A w)
      (Subtype.val z) (Subtype.val w)).mp (hstrong.le_inner (resolvent_spec z) (resolvent_spec w))
  · intro hf
    -- Each graph pair is the resolvent pair of the translated points `x + u` and `y + v`.
    rw [stronglyMonotone_iff]
    intro x y u v hu hv
    have hxu : (x + u) - x ∈ A x := by
      rw [add_sub_cancel_left]
      exact hu
    have hyv : (y + v) - y ∈ A y := by
      rw [add_sub_cancel_left]
      exact hv
    have hz : x + u ∈ resolventDomain A := exists_mem_resolventDomain_of_sub_mem hxu
    have hw : y + v ∈ resolventDomain A := exists_mem_resolventDomain_of_sub_mem hyv
    have hJx : operatorResolvent A ⟨x + u, hz⟩ = x := resolvent_eq_of_sub_mem hA hxu hz
    have hJy : operatorResolvent A ⟨y + v, hw⟩ = y := resolvent_eq_of_sub_mem hA hyv hw
    have hcoc : (β + 1) * ‖x - y‖ ^ 2 ≤ ⟪x - y, (x + u) - (y + v)⟫_ℝ := by
      simpa only [hJx, hJy] using hf ⟨x + u, hz⟩ ⟨y + v, hw⟩
    -- Transport cocoercivity back to the original graph increments `u` and `v`.
    simpa only [add_sub_cancel_left] using
      (mul_normSq_le_inner_sub_iff β x y (x + u) (y + v)).mpr hcoc

/-- `β`-strong monotonicity of a monotone operator yields `(β + 1)`-cocoercivity of its
resolvent. -/
theorem StronglyMonotone.resolvent_cocoercive {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {β : ℝ} {A : E → Set E} (hA : StronglyMonotone 0 A) (hβ : 0 < β)
    (hstrong : StronglyMonotone β A) : Cocoercive (β + 1) (operatorResolvent A) := by
  -- This is the forward direction of the resolvent characterization.
  exact (stronglyMonotone_iff_resolvent_cocoercive β A hA hβ).mp hstrong

/-- `(β + 1)`-cocoercivity of the resolvent of a monotone operator yields `β`-strong
monotonicity. -/
theorem Cocoercive.stronglyMonotone_resolvent {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {β : ℝ} {A : E → Set E} (hA : StronglyMonotone 0 A) (hβ : 0 < β)
    (hf : Cocoercive (β + 1) (operatorResolvent A)) : StronglyMonotone β A := by
  -- This is the reverse direction of the resolvent characterization.
  exact (stronglyMonotone_iff_resolvent_cocoercive β A hA hβ).mpr hf

/-- `(β + 1)`-cocoercivity of `operatorResolvent A` yields the Lipschitz bound with constant
`1 / (β + 1)`. -/
theorem resolvent_norm_sub_le_of_cocoercive {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {β : ℝ} {A : E → Set E} (hA : StronglyMonotone 0 A) (hβ : 0 < β)
    (hf : Cocoercive (β + 1) (operatorResolvent A)) :
    ∀ z w : resolventDomain A,
      ‖operatorResolvent A z - operatorResolvent A w‖ ≤ (1 / (β + 1)) * ‖Subtype.val z - Subtype.val w‖ := by
  intro z w
  -- Cocoercivity of modulus `β + 1` is the comparison with constant `(β + 1)⁻¹`.
  simpa only [one_div] using Cocoercive.norm_sub_le (add_pos hβ zero_lt_one) hf z w

/-- On a real inner product space, let `A : E → Set E` be monotone, let `0 < β`, and assume
`StronglyMonotone β A`. Then `operatorResolvent A` is Lipschitz on `resolventDomain A` with constant
`1 / (β + 1)`: for all `z w : resolventDomain A`,
`‖operatorResolvent A z - operatorResolvent A w‖ ≤ (1 / (β + 1)) * ‖Subtype.val z - Subtype.val w‖`. -/
theorem resolvent_norm_sub_le {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (β : ℝ)
    (A : E → Set E) (hA : StronglyMonotone 0 A) (hβ : 0 < β) (hstrong : StronglyMonotone β A) :
    ∀ z w : resolventDomain A,
      ‖operatorResolvent A z - operatorResolvent A w‖ ≤ (1 / (β + 1)) * ‖Subtype.val z - Subtype.val w‖ := by
  -- Strong monotonicity produces cocoercivity, which produces the norm bound.
  exact resolvent_norm_sub_le_of_cocoercive hA hβ
    (StronglyMonotone.resolvent_cocoercive hA hβ hstrong)

/-- For a monotone operator and `0 < β`, `β`-strong monotonicity is equivalent to the graph
inequality `(β + 1) * ‖x - y‖ ^ 2 ≤ ⟪x - y, z - w⟫_ℝ` whenever `z - x ∈ A x` and
`w - y ∈ A y`. -/
theorem stronglyMonotone_iff_resolvent_graph {E : Type u} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] {β : ℝ} {A : E → Set E} (hA : StronglyMonotone 0 A) (hβ : 0 < β) :
    StronglyMonotone β A ↔
      ∀ z w x y, z - x ∈ A x → w - y ∈ A y →
        (β + 1) * ‖x - y‖ ^ 2 ≤ ⟪x - y, z - w⟫_ℝ := by
  constructor
  · intro hstrong z w x y hx hy
    -- The graph inequality is the same rearrangement as strong monotonicity.
    exact (mul_normSq_le_inner_sub_iff β x y z w).mp (hstrong.le_inner hx hy)
  · intro hgraph
    rw [stronglyMonotone_iff]
    intro x y u v hu hv
    have hxu : (x + u) - x ∈ A x := by
      rw [add_sub_cancel_left]
      exact hu
    have hyv : (y + v) - y ∈ A y := by
      rw [add_sub_cancel_left]
      exact hv
    -- Instantiate the graph inequality at the translated points and return to `u - v`.
    simpa only [add_sub_cancel_left] using
      (mul_normSq_le_inner_sub_iff β x y (x + u) (y + v)).mpr
        (hgraph (x + u) (y + v) x y hxu hyv)

/-- For `0 < β`, `Real.toNNReal (1 / (β + 1))` equals `1 / (β + 1)`. -/
theorem resolvent_lipschitzWith_coe {β : ℝ} (hβ : 0 < β) :
    (Real.toNNReal (1 / (β + 1)) : ℝ) = 1 / (β + 1) := by
  -- The constant is positive, so truncating at zero does not change it.
  exact Real.coe_toNNReal _ (one_div_pos.mpr (add_pos hβ zero_lt_one)).le

/-- A `β`-strongly monotone operator has `LipschitzWith` resolvent of constant
`Real.toNNReal (1 / (β + 1))`. -/
theorem resolvent_lipschitzWith {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {β : ℝ} {A : E → Set E} (hA : StronglyMonotone 0 A) (hβ : 0 < β)
    (hstrong : StronglyMonotone β A) :
    LipschitzWith (Real.toNNReal (1 / (β + 1))) (operatorResolvent A) := by
  -- Package the pointwise norm bound as the distance inequality for `LipschitzWith`.
  refine LipschitzWith.of_dist_le_mul fun z w ↦ ?_
  rw [dist_eq_norm, Subtype.dist_eq, dist_eq_norm, resolvent_lipschitzWith_coe hβ]
  exact resolvent_norm_sub_le β A hA hβ hstrong z w

