import Mathlib.Analysis.NormedSpace.Extr
import Mathlib.Analysis.Normed.Group.Real

namespace MigrationExample

theorem norm_nonnegative {E : Type*} [SeminormedAddCommGroup E] (x : E) :
    0 ≤ ‖x‖ := norm_nonneg x

end MigrationExample
