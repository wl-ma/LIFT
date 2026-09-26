import Mathlib.Analysis.Normed.Module.Basic
import Mathlib.Analysis.Normed.Group.Real

namespace LIFTNorm
theorem scale_norm {E : Type*} [SeminormedAddCommGroup E] [NormedSpace ℝ E]
    (a : ℝ) (x : E) : ‖a • x‖ = |a| * ‖x‖ := by
  simpa only [Real.norm_eq_abs] using norm_smul a x
end LIFTNorm
