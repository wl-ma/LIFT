module

public import Mathlib.AlgebraicTopology.FundamentalGroupoid.FundamentalGroup
public import Mathlib.AlgebraicTopology.FundamentalGroupoid.Product

@[expose] public section

noncomputable section

universe u v

variable {X : Type u} {Y : Type v} [TopologicalSpace X] [TopologicalSpace Y]

namespace FundamentalGroup

/-- The homomorphism on fundamental groups induced by the two projections from a product. -/
def prodProjectionHom (x : X) (y : Y) :
    FundamentalGroup (X × Y) (x, y) →* FundamentalGroup X x × FundamentalGroup Y y :=
  MonoidHom.prod (map ContinuousMap.fst (x, y)) (map ContinuousMap.snd (x, y))

/-- The product projection homomorphism sends a loop class to its two projected classes. -/
theorem prodProjectionHom_apply (x : X) (y : Y) (γ : FundamentalGroup (X × Y) (x, y)) :
    prodProjectionHom x y γ =
      (fromPath (Path.Homotopic.projLeft (toPath γ)),
        fromPath (Path.Homotopic.projRight (toPath γ))) := by
  -- Unfolding the induced maps computes their two components as the projected path classes.
  rfl

/-- The homomorphism that forms a loop in a product from a pair of loop classes. -/
def prodPathHom (x : X) (y : Y) :
    FundamentalGroup X x × FundamentalGroup Y y →* FundamentalGroup (X × Y) (x, y) :=
  (FundamentalGroupoidFunctor.prodToProdTop (TopCat.of X) (TopCat.of Y)).mapEnd
    (FundamentalGroupoid.mk x, FundamentalGroupoid.mk y)

/-- The product-loop homomorphism forms the product of its two input loop classes. -/
theorem prodPathHom_apply (x : X) (y : Y)
    (γ : FundamentalGroup X x × FundamentalGroup Y y) :
    prodPathHom x y γ =
      fromPath (Path.Homotopic.prod (toPath γ.1) (toPath γ.2)) := by
  -- The endomorphism map of the product functor is definitionally path product.
  rfl

/-- Forming a product loop after projecting a loop recovers the original loop class. -/
theorem prodPathHom_leftInverse (x : X) (y : Y)
    (γ : FundamentalGroup (X × Y) (x, y)) :
    prodPathHom x y (prodProjectionHom x y γ) = γ := by
  -- Product of the two projected path classes recovers the original class.
  rw [prodPathHom_apply, prodProjectionHom_apply]
  exact Path.Homotopic.prod_projLeft_projRight (toPath γ)

/-- Projecting a product loop recovers the original pair of loop classes. -/
theorem prodPathHom_rightInverse (x : X) (y : Y)
    (γ : FundamentalGroup X x × FundamentalGroup Y y) :
    prodProjectionHom x y (prodPathHom x y γ) = γ := by
  -- Each projection of a product path class is its corresponding factor.
  rw [prodPathHom_apply, prodProjectionHom_apply,
    Path.Homotopic.projLeft_prod, Path.Homotopic.projRight_prod]

/-- The canonical pointed multiplicative equivalence between the fundamental group of a
product and the product of the two fundamental groups. -/
def prodMulEquiv (x : X) (y : Y) :
    FundamentalGroup (X × Y) (x, y) ≃* FundamentalGroup X x × FundamentalGroup Y y where
  toFun := prodProjectionHom x y
  invFun := prodPathHom x y
  left_inv := prodPathHom_leftInverse x y
  right_inv := prodPathHom_rightInverse x y
  map_mul' := (prodProjectionHom x y).map_mul

/-- The forward map of `prodMulEquiv` is the homomorphism induced by the projections. -/
theorem prodMulEquiv_apply (x : X) (y : Y) (γ : FundamentalGroup (X × Y) (x, y)) :
    prodMulEquiv x y γ = prodProjectionHom x y γ := by
  -- The forward function of the equivalence is the projection homomorphism.
  rfl

/-- The inverse of `prodMulEquiv` forms the product of two loop classes. -/
theorem prodMulEquiv_symm_apply (x : X) (y : Y)
    (γ : FundamentalGroup X x × FundamentalGroup Y y) :
    (prodMulEquiv x y).symm γ =
      fromPath (Path.Homotopic.prod (toPath γ.1) (toPath γ.2)) := by
  -- The inverse function is the product-path homomorphism.
  exact prodPathHom_apply x y γ

end FundamentalGroup
