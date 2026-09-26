module

public import ReasLib.AlgebraicTopology.FundamentalGroup.Product

@[expose] public section

noncomputable section

universe u v

#check (FundamentalGroup.prodProjectionHom :
  ∀ {X : Type u} {Y : Type v} [TopologicalSpace X] [TopologicalSpace Y]
    (x : X) (y : Y),
    FundamentalGroup (X × Y) (x, y) →*
      FundamentalGroup X x × FundamentalGroup Y y)

#check (FundamentalGroup.prodProjectionHom_apply :
  ∀ {X : Type u} {Y : Type v} [TopologicalSpace X] [TopologicalSpace Y]
    (x : X) (y : Y) (γ : FundamentalGroup (X × Y) (x, y)),
    FundamentalGroup.prodProjectionHom x y γ =
      (FundamentalGroup.fromPath (Path.Homotopic.projLeft (FundamentalGroup.toPath γ)),
        FundamentalGroup.fromPath (Path.Homotopic.projRight (FundamentalGroup.toPath γ))))

#check (FundamentalGroup.prodPathHom :
  ∀ {X : Type u} {Y : Type v} [TopologicalSpace X] [TopologicalSpace Y]
    (x : X) (y : Y),
    FundamentalGroup X x × FundamentalGroup Y y →*
      FundamentalGroup (X × Y) (x, y))

#check (FundamentalGroup.prodPathHom_apply :
  ∀ {X : Type u} {Y : Type v} [TopologicalSpace X] [TopologicalSpace Y]
    (x : X) (y : Y) (γ : FundamentalGroup X x × FundamentalGroup Y y),
    FundamentalGroup.prodPathHom x y γ =
      FundamentalGroup.fromPath
        (Path.Homotopic.prod (FundamentalGroup.toPath γ.1) (FundamentalGroup.toPath γ.2)))

#check (FundamentalGroup.prodPathHom_leftInverse :
  ∀ {X : Type u} {Y : Type v} [TopologicalSpace X] [TopologicalSpace Y]
    (x : X) (y : Y) (γ : FundamentalGroup (X × Y) (x, y)),
    FundamentalGroup.prodPathHom x y (FundamentalGroup.prodProjectionHom x y γ) = γ)

#check (FundamentalGroup.prodPathHom_rightInverse :
  ∀ {X : Type u} {Y : Type v} [TopologicalSpace X] [TopologicalSpace Y]
    (x : X) (y : Y) (γ : FundamentalGroup X x × FundamentalGroup Y y),
    FundamentalGroup.prodProjectionHom x y (FundamentalGroup.prodPathHom x y γ) = γ)

/- Exercise 3.2: For arcwise connected (that is, path-connected) topological spaces
`X` and `Y`, the fundamental group of `X × Y` at `(x, y)` is multiplicatively
equivalent to the product of the fundamental groups at `x` and `y`. -/
#check (FundamentalGroup.prodMulEquiv :
  ∀ {X : Type u} {Y : Type v} [TopologicalSpace X] [TopologicalSpace Y]
    (x : X) (y : Y),
    FundamentalGroup (X × Y) (x, y) ≃* FundamentalGroup X x × FundamentalGroup Y y)

#check (FundamentalGroup.prodMulEquiv_apply :
  ∀ {X : Type u} {Y : Type v} [TopologicalSpace X] [TopologicalSpace Y]
    (x : X) (y : Y) (γ : FundamentalGroup (X × Y) (x, y)),
    FundamentalGroup.prodMulEquiv x y γ = FundamentalGroup.prodProjectionHom x y γ)

#check (FundamentalGroup.prodMulEquiv_symm_apply :
  ∀ {X : Type u} {Y : Type v} [TopologicalSpace X] [TopologicalSpace Y]
    (x : X) (y : Y) (γ : FundamentalGroup X x × FundamentalGroup Y y),
    (FundamentalGroup.prodMulEquiv x y).symm γ =
      FundamentalGroup.fromPath
        (Path.Homotopic.prod (FundamentalGroup.toPath γ.1) (FundamentalGroup.toPath γ.2)))
