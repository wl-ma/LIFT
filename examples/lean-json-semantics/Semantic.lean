namespace SemanticExample

/-- A quadratic with a natural curvature constrained to be positive. -/
structure QuadraticModel where
  curvature : Nat
  positive : 0 < curvature
  center : Int

/-- The integer-valued quadratic centered at the stored center. -/
def energy (q : QuadraticModel) (x : Int) : Int :=
  (q.curvature : Int) * (x - q.center) ^ 2

/-- Translation must retain the ordering premise and universal offset. -/
theorem add_order (n m k : Nat) (h : n ≤ m) : n + k ≤ m + k :=
  Nat.add_le_add_right h k

end SemanticExample
