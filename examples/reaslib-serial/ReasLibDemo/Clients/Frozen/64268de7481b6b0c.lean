import ReasLib.Analysis.Convex.QuadraticShift
noncomputable section
set_option autoImplicit false
universe u
example : {E : Type u} → [NormedAddCommGroup.{u} E] → (σ : Real) → (f : E → EReal) → E → EReal := @subNormSq
example : @subNormSq = (fun {E : Type u} [inst : NormedAddCommGroup E] (σ : ℝ) (f : E → EReal) (x : E) => f x - ((σ / (2 : ℝ) * ‖x‖ ^ 2 : ℝ) : EReal)) := rfl
