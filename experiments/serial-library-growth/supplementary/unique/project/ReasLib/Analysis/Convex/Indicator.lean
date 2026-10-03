module

public import Mathlib.Data.EReal.Basic

@[expose] public section

namespace ReasLib.Analysis.Convex

open Classical

/-- The extended-real indicator of a set `C`, equal to `0` on `C` and `⊤` outside `C`. -/
noncomputable def erealIndicator {E : Type*} (C : Set E) (x : E) : EReal :=
  if x ∈ C then 0 else ⊤

end ReasLib.Analysis.Convex

