/-
Copyright (c) 2026 Zichen Wang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Zichen Wang
-/
module

public import ReasLib.Analysis.C0Seq.NormalCone.ClosedBall

/-!
# Maximal monotonicity of the fixed-ball normal cone

This module exposes maximality, domain, and origin formulas for the normal cone
of `C0Seq.finalConstraint`.
-/

public section

/- Theorem 7.12 (Maximal monotonicity of the normal cone) (1): the normal-cone
graph of `C0Seq.finalConstraint` for the canonical `C0Seq`–`L1Seq` pairing is
maximally monotone. -/
#check (DualPairing.maximalMonotone_normalConeGraph_closedBall
    C0Seq.coordinateDualPairing C0Seq.coordinateDualPairing_surjective
    (1 / 2) one_half_pos :
  Maximal C0Seq.coordinateDualPairing.IsMonotone
    (C0Seq.coordinateDualPairing.normalConeGraph C0Seq.finalConstraint))

/- Theorem 7.12 (Maximal monotonicity of the normal cone) (2): the domain of the
normal cone of `C0Seq.finalConstraint` is exactly `C0Seq.finalConstraint`. -/
#check (C0Seq.normalConeDom_finalConstraint C0Seq.coordinateDualPairing :
  C0Seq.coordinateDualPairing.normalConeDom C0Seq.finalConstraint =
    C0Seq.finalConstraint)

/- Theorem 7.12 (Maximal monotonicity of the normal cone) (3): the normal cone of
`C0Seq.finalConstraint` at zero is the singleton containing zero. -/
#check (C0Seq.normalCone_finalConstraint_zero C0Seq.coordinateDualPairing :
  C0Seq.coordinateDualPairing.normalCone C0Seq.finalConstraint 0 = {0})
