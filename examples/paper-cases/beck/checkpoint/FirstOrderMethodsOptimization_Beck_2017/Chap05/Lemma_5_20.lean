import FirstOrderMethodsOptimization_Beck_2017.Chap02.Definition_2_7
import FirstOrderMethodsOptimization_Beck_2017.Chap05.Definition_5_16
import ReasLib.Analysis.Convex.Strong

-- Declarations for this item will be appended below by the statement pipeline.

universe u

section

variable {E : Type u}

/- Lemma 5.20 is `source-facing` for the Chapter 5 owner
`is_strongly_convex_function`. The perturbation hypothesis should reuse the Chapter 2 convexity
owner `is_convex_function`; the explicit source codomain condition `g : E → (-∞, ∞]` remains a
separate hypothesis `hg_ne_bot` because the ambient codomain is still `EReal`. The lower-level
`ConvexOn` formulation of `x ↦ (g x).toReal` on `effective_domain g` is a `bridge/view`
companion, not the main public entry. -/

-- Proof sketch: use `hf.ne_bot` together with `hg_ne_bot` to rule out `-∞` for `f + g`, read
-- convexity of `effective_domain g` from the set component of `hg`, combine it with
-- `hf.convex_effective_domain` to control the domain of `f + g`, and then add the strong-convex
-- Jensen inequality for `f` to the convex Jensen inequality for the real-valued restriction of
-- `g`, coercing back to `EReal`.
-- Bridge companion for Lemma 5.20: the perturbation term may be supplied through convexity of
-- the finite-valued restriction `x ↦ (g x).toReal` on `effective_domain g`, together with the
-- explicit hypothesis that `g` never takes the value `-∞`.
/-- Helper for Lemma 5.20: excluding `⊥` for both summands identifies the finite domain of
`x ↦ f x + g x` with the intersection of the finite domains of `f` and `g`. -/
private theorem effective_domain_add_eq_inter
    {f g : E → EReal} (hf_ne_bot : ∀ x, f x ≠ ⊥) (hg_ne_bot : ∀ x, g x ≠ ⊥) :
    effective_domain (fun x ↦ f x + g x) = effective_domain f ∩ effective_domain g := by
  ext x
  constructor
  · intro hx
    refine ⟨?_, ?_⟩
    · refine mem_effective_domain.mpr ?_
      by_contra hfx
      have hfx_top : f x = ⊤ := le_antisymm le_top (not_lt.mp hfx)
      have hsum_top : f x + g x = ⊤ := by
        simpa [hfx_top] using EReal.top_add_of_ne_bot (hg_ne_bot x)
      exact (ne_of_lt (mem_effective_domain.mp hx)) hsum_top
    · refine mem_effective_domain.mpr ?_
      by_contra hgx
      have hgx_top : g x = ⊤ := le_antisymm le_top (not_lt.mp hgx)
      have hsum_top : f x + g x = ⊤ := by
        simpa [hgx_top] using EReal.add_top_of_ne_bot (hf_ne_bot x)
      exact (ne_of_lt (mem_effective_domain.mp hx)) hsum_top
  · rintro ⟨hx, hy⟩
    -- Finite summands have a finite sum in `EReal`.
    exact mem_effective_domain.mpr <|
      EReal.add_lt_top (ne_of_lt (mem_effective_domain.mp hx))
        (ne_of_lt (mem_effective_domain.mp hy))

/-- Helper for Lemma 5.20: on the effective domain of `f + g`, `toReal` splits the sum into the
sum of the finite `toReal` values of `f` and `g`. -/
private theorem toReal_add_eq_of_mem_effective_domain_add
    {f g : E → EReal} (hf_ne_bot : ∀ x, f x ≠ ⊥) (hg_ne_bot : ∀ x, g x ≠ ⊥)
    {x : E} (hx : x ∈ effective_domain (fun z ↦ f z + g z)) :
    (f x + g x).toReal = (f x).toReal + (g x).toReal := by
  have hx_fg : x ∈ effective_domain f ∩ effective_domain g := by
    simpa [effective_domain_add_eq_inter hf_ne_bot hg_ne_bot] using hx
  rcases hx_fg with ⟨hx_f, hx_g⟩
  -- Membership in the effective domains excludes `⊤`, while the hypotheses exclude `⊥`.
  exact
    EReal.toReal_add (ne_of_lt (mem_effective_domain.mp hx_f)) (hf_ne_bot x)
      (ne_of_lt (mem_effective_domain.mp hx_g)) (hg_ne_bot x)

variable [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- Lemma 5.20: if `f` is `σ`-strongly convex and the finite-valued restriction
`x ↦ (g x).toReal` is convex on `effective_domain g`, with `g` never equal to `⊥`, then `f + g`
is `σ`-strongly convex. -/
theorem is_strongly_convex_function_add_of_convexOn_toReal
    {f g : E → EReal} {σ : ℝ} (hf : is_strongly_convex_function f σ)
    (hg_ne_bot : ∀ x, g x ≠ ⊥)
    (hg : ConvexOn ℝ (effective_domain g) (fun x ↦ (g x).toReal)) :
    is_strongly_convex_function (fun x ↦ f x + g x) σ := by
  let s : Set E := effective_domain (fun z ↦ f z + g z)
  have hdom_eq : s = effective_domain f ∩ effective_domain g := by
    simpa [s] using effective_domain_add_eq_inter hf.ne_bot hg_ne_bot
  refine is_strongly_convex_function_iff_strongConvexOn_toReal.mpr ?_
  refine ⟨hf.sigma_pos, ?_, ?_⟩
  · intro x
    -- The sum never takes the value `⊥` because neither summand does.
    exact EReal.add_ne_bot_iff.mpr ⟨hf.ne_bot x, hg_ne_bot x⟩
  · change StrongConvexOn s σ (fun x ↦ (f x + g x).toReal)
    rw [hdom_eq]
    have hs_convex : Convex ℝ (effective_domain f ∩ effective_domain g) :=
      Convex.inter hf.convex_effective_domain hg.1
    have hf_inter :=
      (strongConvexOn_toReal_of_is_strongly_convex_function hf).subset
        (Set.inter_subset_left (s := effective_domain f) (t := effective_domain g)) hs_convex
    have hg_inter :=
      hg.subset (Set.inter_subset_right (s := effective_domain f) (t := effective_domain g))
        hs_convex
    refine (hf_inter.add_convexOn hg_inter).congr ?_
    intro x hx
    rw [Pi.add_apply]
    have hx_sum : x ∈ s := by
      simpa [hdom_eq] using hx
    exact (toReal_add_eq_of_mem_effective_domain_add hf.ne_bot hg_ne_bot hx_sum).symm

/-- beck-strong-convexity:Lemma_5_20
If `f` is σ-strongly convex and `g : E → (-∞, ∞]` is convex, then `f + g` is σ-strongly convex. -/
theorem is_strongly_convex_function_add_of_is_convex_function
    {f g : E → EReal} {σ : ℝ} (hf : is_strongly_convex_function f σ)
    (hg : is_convex_function g) (hg_ne_bot : ∀ x, g x ≠ ⊥) :
    is_strongly_convex_function (fun x ↦ f x + g x) σ := by
  refine is_strongly_convex_function_add_of_convexOn_toReal hf hg_ne_bot ?_
  exact convexOn_toReal_of_is_convex_function hg (fun x _ ↦ hg_ne_bot x)

end
