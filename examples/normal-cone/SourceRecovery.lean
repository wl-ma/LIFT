import ReasLib.FunctionalAnalysis.SequenceSpace.C0.DualPairing.Surjective
import ReasLib.Analysis.Convex.NormalCone.ClosedBall

-- The historical source radius, with an explicit complete mathematical type.
example : Maximal C0Seq.coordinateDualPairing.IsMonotone
    (C0Seq.coordinateDualPairing.normalConeGraph
      (Metric.closedBall (0 : C0Seq) (1 / 2 : ℝ))) := by
  exact C0Seq.coordinateDualPairing.maximalMonotone_normalConeGraph_closedBall
    C0Seq.coordinateDualPairing_surjective (1 / 2) (by norm_num)
