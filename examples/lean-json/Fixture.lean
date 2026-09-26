namespace LIFTExample

/-- A tiny data construction used to demonstrate body extraction. -/
def twice (n : Nat) : Nat := n + n

/-- The public equation preserves the prescribed data of the construction. -/
theorem twice_eq (n : Nat) : twice n = n + n := rfl

/-- A caller reuses the public equation at a concrete input. -/
theorem twice_three : twice 3 = 6 := by
  rw [twice_eq]

end LIFTExample
