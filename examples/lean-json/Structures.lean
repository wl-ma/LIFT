namespace LIFTFixture
universe u
structure Box (α : Type u) where
  value : α
class HasValue (α : Type u) where
  value : α
instance : HasValue Nat := ⟨7⟩
private theorem hidden (n : Nat) : n = n := rfl
theorem usesPrivate (n : Nat) : n = n := hidden n
def project {α : Type u} (box : Box α) : α := box.value
end LIFTFixture
