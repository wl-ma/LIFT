import ReasLib

namespace SerialBoundaryChecks

universe u
variable {E : Type u} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- Beck does not impose nonempty effective domain. -/
theorem top_allowed (σ : ℝ) (hσ : 0 < σ) :
    StrongConvex σ (fun _ : E => (⊤ : EReal)) := by
  refine ⟨hσ, (fun _ => bot_lt_top), ?_, ?_⟩
  · intro x hx
    exact False.elim ((lt_irrefl (⊤ : EReal)) hx.2)
  · intro x hx
    exact False.elim ((lt_irrefl (⊤ : EReal)) hx.2)

/-- The excluded bottom value cannot satisfy the source predicate. -/
theorem bottom_rejected (σ : ℝ) :
    ¬ StrongConvex σ (fun _ : ℝ => (⊥ : EReal)) := by
  intro h
  exact (lt_irrefl (⊥ : EReal)) (h.botLt 0)

/-- A zero modulus does not meet the source's positive-parameter convention. -/
theorem zero_rejected (f : E → EReal) : ¬ StrongConvex 0 f := by
  intro h
  exact (lt_irrefl (0 : ℝ)) h.sigmaPos

/-- This check fixes the complete prescribed shift, including the factor 1/2. -/
theorem exact_shift (σ : ℝ) (f : E → EReal) (x : E) :
    subNormSq σ f x = f x - ((σ / (2 : ℝ) * ‖x‖ ^ 2 : ℝ) : EReal) := rfl

#print axioms top_allowed
#print axioms bottom_rejected
#print axioms zero_rejected
#print axioms exact_shift

end SerialBoundaryChecks
