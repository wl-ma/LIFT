module

public import ReasLib.Analysis.Convex.Strong
public import Mathlib.LinearAlgebra.FiniteDimensional.Defs

public section

#check (effectiveDomain : {α : Type*} → (α → EReal) → Set α)

#check (StrongConvex :
  {E : Type*} → [NormedAddCommGroup E] → [InnerProductSpace ℝ E] → ℝ → (E → EReal) → Prop)

#check (FiniteDimensional :
  (K V : Type*) → [DivisionRing K] → [AddCommGroup V] → [Module K V] → Prop)
