# LIFT

**Library Integration of Formalized Theorems for Reusable Mathematical Knowledge**

[中文说明](README.zh-CN.md) · [Experimental data](data/README.md) · [ReasLib examples](examples/reaslib/README.md) · [Lean → JSON](tools/lean_json/README.md) · [Toolchain alignment](tools/toolchain/README.md)

LIFT studies how independently formalized Lean developments can contribute reusable mathematical interfaces while retaining connections to their original specifications. A public theorem, definition, or structure is developed together with the adaptations that recover the source result. Candidates can be constructed concurrently and revised against an evolving library.

This repository contains the public experimental artifacts accompanying the paper: machine-readable tables, declaration-level examples, an offline ReasLib browser, compiler-based Lean-to-JSON extraction, and a toolchain-alignment helper. This release follows the **26 September 2026, version10 manuscript snapshot**. The exact manuscript hash and artifact origins are recorded in [release provenance](data/release-provenance.json).

The [manuscript-to-artifact map](docs/paper-artifact-map.md) connects the experimental tables and case studies to individual released files, including the Taylor obligation-to-proof chain.

## Start here

| Your goal | Entry point |
| --- | --- |
| Understand the method and the evidence | This README, then [method overview](docs/method.md) |
| Browse the corpus and mathematical cases | Download/clone the repository and open [demo/index.html](demo/index.html) locally |
| Inspect the paper's numerical results | [Data guide](data/README.md) and [construction.csv](data/construction.csv) |
| Compile the selected ReasLib interfaces | [Lean example project](examples/reaslib/README.md) |
| Export types, bodies, dependencies, and axioms from Lean | [Lean-to-JSON quick start](tools/lean_json/README.md) |
| Prepare a version migration and inspect interface drift | [Toolchain helper](tools/toolchain/README.md) |
| Check precisely what this release verifies | [Reproduction guide](docs/reproduce.md) and [release validation](docs/validation.md) |

```bash
git clone https://github.com/wl-ma/LIFT.git
cd LIFT
python3 scripts/verify_release.py
```

The table and integrity checks require **Python 3.10+**, with no third-party Python packages. Open `demo/index.html` directly in a browser for a searchable project table, mathematical examples, and the recorded online revision. The demo contains its data and needs no account, API key, server, or model. GitHub's file viewer displays its source; it is not a hosted application.

If you are reading a review mirror, use its download control and run the same commands from the extracted repository root. A redacted Git clone URL is not a clone endpoint. Keep the full directory layout so local documentation and demo links resolve.

## What LIFT does

Independently formalized sources can state related results with different parameters, assumptions, definitions, and representations. Merely collecting their files leaves these differences in place. LIFT organizes integration around two coupled objects:

1. **A public interface:** a theorem, definition, map, or structure suitable for reuse.
2. **A source recovery:** an explicit specialization or adaptation that returns the result or prescribed data required by the fixed source specification.

For a public result `g` and a source specification `U`, the intended relationship is `recovery(g) : U`. For constructions, recovering an arbitrary object of the same type is insufficient: defining equations and operation laws also matter.

Three mathematical choices guide integration:

- **Canonical alignment:** reuse an existing interface after matching its full type and assumptions to the source.
- **General interfaces:** expose an argument at a reusable level of generality and specialize it back to the source.
- **Representation transport:** provide concrete maps and the laws that make different mathematical representations interchangeable.

The asynchronous construction uses multiple producers and one consumer (MPSC). Producers construct candidates concurrently. The consumer reconciles each candidate with current library content; a revision may use mathematics accepted since its first attempt. Completed release conditions require the relevant proofs and historical recoveries, beyond intermediate construction checks. [Method details](docs/method.md).

## ReasLib and the experimental corpus

**ReasLib** denotes the project-level public mathematical components organized from the paper's selected formalized developments. This release includes a small, compiled example project drawn from those components. It does not merge every historical project into one jointly verified Lean library.

| Evidence | Reported result | Public artifact |
| --- | ---: | --- |
| Construction corpus | 20 mathematical developments | [construction.csv](data/construction.csv) |
| Source catalogue | 10,922 items | [construction.csv](data/construction.csv) |
| Accepted source-item integrations | 5,061 items | [construction.csv](data/construction.csv) |
| Public modules across project exports | 15,716 occurrences | [module-profile.csv](data/module-profile.csv) |
| Recorded declaration reuse | 8,854 actions | [declaration-actions.csv](data/declaration-actions.csv) |
| Recorded publication | 19,253 actions | [declaration-actions.csv](data/declaration-actions.csv) |
| Local retention | 2,568 actions | [declaration-actions.csv](data/declaration-actions.csv) |
| Recorded removal | 3,283 actions | [declaration-actions.csv](data/declaration-actions.csv) |
| Linked proof batches | 7 batches; 118 integration items; 135 successful proof tasks | [proof-handoff.csv](data/proof-handoff.csv) |
| Individual proof handoffs | 249 obligations linked to successful task records | [proof-obligations.csv](data/proof-obligations.csv) |
| Selected Lean case study | 5 compiled files; 9 declarations checked without `sorryAx` | [historical checks](data/lean-checks-historical.json) |
| Beck revision checkpoint | 20 source declarations; 15 trusted source theorems; 22 passing clients | [online checkpoint](data/online-checkpoint.json) |

These units serve different purposes. Integration items are source entries, module counts include repeated and inherited content, and action counts can include repeated treatment of a declaration. A successful proof-task link is a recorded handoff, while a Lean axiom check examines the dependencies of a particular declaration. The [data dictionary](data/README.md) preserves these distinctions.

The corpus spans optimization, convex analysis, number theory, representation theory, topology, linear algebra, algebraic geometry, and mixed mathematical collections. Stacks accounts for a large part of the module-occurrence count. Some historical public modules contain unfinished proofs; the complete corpus count is not a count of new trusted theorems.

![Integration decision profiles](docs/figures/result-action-profile.svg)

## Three executable mathematical cases

The [ReasLib example project](examples/reaslib/README.md) packages the two public modules and their three source applications with the original source bytes and recorded hashes.

| Case | Mathematical change | Public entry point |
| --- | --- | --- |
| First-order optimality | Match the source's Euclidean-space type to an existing derivative theorem | `IsLocalMin.fderiv_eq_zero` |
| Taylor formulas | Expose calculus in general real normed spaces, then specialize to finite-dimensional coordinates | `Taylor.existsFirstOrder`, `Taylor.fderivAddEqIntegral`, `Taylor.existsSecondOrder` |
| Product fundamental group | Construct projection and pairing homomorphisms, prove inverse laws, and assemble a multiplicative equivalence | `FundamentalGroup.prodProjectionHom`, `prodPathHom`, `prodMulEquiv` |

The first case retains the mathematical meaning of the smooth source condition: Lean's total `fderiv` interface must not be read as asserting classical differentiability of every nonsmooth function. The Taylor case exhibits generalization and source specialization; it does not by itself establish an abstraction independently induced by multiple sources. The topology case retains fixed base points and exposes usable maps, not just an existence proposition.

With [Elan](https://github.com/leanprover/elan) and Git installed:

```bash
cd examples/reaslib
lake update
lake exe cache get
lake build
lake env lean Audit.lean
```

This pins **Lean 4.32.0** and **Mathlib `81a5d257c8e410db227a6665ed08f64fea08e997`**. Initial dependency setup downloads Mathlib and its cache. The nine `#print axioms` results should contain only the permitted standard axioms `propext`, `Classical.choice`, and `Quot.sound`. A cache-based, sequential verification route is documented in [reproduction](docs/reproduce.md).

## Online reuse: a recorded Beck revision

The recorded example concerns strong convexity. Lemma 5.20 introduces `StrongConvexOn.congr`, transferring the property along pointwise equality on a set. A candidate for Proposition 5.13 returns for revision and resumes with that interface available. Its real-valued source companion then uses:

```lean
exact (StrongConvexOn.mul_sq_norm hC 1).congr fun x _ ↦ by ring
```

The general squared-norm result is specialized to the coefficient `1`; congruence reconciles two equivalent expressions for half the squared norm.

| Recorded event | Meaning |
| --- | --- |
| 3–4 | Both candidates start from the same library context |
| 15 | The congruence interface is accepted |
| 18–19 | The other candidate is rejected and a revision is requested |
| 20 | Revision starts from the updated context |
| 24–25 | The revised candidate is accepted and the historical source checkpoint passes |

The [event table](data/online-trace.csv), [actual source patch](data/online-revision.patch), and [checkpoint details](data/online-checkpoint.json) make this trace inspectable. It is source-local reuse within Beck's development. The checkpoint's 20/15/22 counts are not a completed whole-library release: the broader first run later failed its final public-manifest check, and the second run accepted no mathematical update. This release makes no general speedup or Online-versus-Frozen performance claim.

## Lean → JSON

[The extraction tool](tools/lean_json/README.md) reads the **compiled Lean environment**. It exports declaration identities, complete pretty-printed types, definition bodies, source ranges, constructors/fields, dependencies, and axiom information. The extractor comes from the existing Leantegrate implementation; the public wrapper makes the compiler path independently runnable.

```bash
python3 tools/lean_json/extract.py examples/lean-json \
  --module Fixture --output _runs/fixture-facts.json
```

The dependency-free example uses Lean 4.26.0. Supported compiler versions and exercised paths are listed in the [tool guide](tools/lean_json/README.md). `--name Namespace.name` selects an exact declaration within one module. Exported references can point outside the selected modules; this is not an assertion that all dependencies were exported.

This command makes **no model calls**. The existing [translator](tools/lean_json/prompts/translator.md) and [verifier](tools/lean_json/prompts/verifier.md) role instructions are included for inspection. Natural-language generation and review are a separate layer; this release does not label the compiler export as a completed natural-language or backend-ready conversion.

## Toolchain alignment

[The alignment helper](tools/toolchain/README.md) supports a concrete preparation and inspection workflow:

1. Export baseline declarations under the original environment.
2. Copy the mathematical project into a new directory and pin the target Lean/Mathlib versions.
3. Build the candidate and use diagnostics to repair version-specific code.
4. Export the same declarations, compare types/bodies/axioms, and run original clients separately.

```bash
python3 tools/toolchain/upgrade.py prepare examples/lean-json _runs/fixture-430 \
  --target leanprover/lean4:v4.30.0
python3 tools/toolchain/upgrade.py build _runs/fixture-430
python3 tools/lean_json/extract.py _runs/fixture-430 \
  --module Fixture --output _runs/fixture-430-facts.json
python3 tools/toolchain/upgrade.py compare \
  _runs/fixture-facts.json _runs/fixture-430-facts.json
```

Preparation leaves the original source unchanged. For a Mathlib project, pass an explicit target `--mathlib-rev` commit. The helper currently accepts `lakefile.toml` projects; it reports other configurations as unsupported. It assists migration and checks for textual fact drift; it does not automatically repair arbitrary API changes or prove cross-version semantic equivalence. [Lake's documentation](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/) explains the build and dependency layer.

## Repository map

```text
data/                  Paper tables, obligation links, trace, provenance
demo/index.html        Standalone interactive ReasLib evidence browser
docs/                  Method, reproduction, validation, release scope
examples/reaslib/      Two public Lean modules and three source applications
examples/lean-json/    Small dependency-free compiler extraction example
tools/lean_json/       Compiler extractor, wrapper, and role instructions
tools/toolchain/       Isolated upgrade preparation and fact comparison
scripts/               Data verification, Lean checks, and demo generation
tests/                 Focused checks for migration and extraction boundaries
```

## Availability and scope

Available now: the tables reported above, all 249 selected obligation links, selected source code, historical checks, an offline demo, and locally executable support tools. New packaging checks are recorded separately from the historical paper evidence in [validation](docs/validation.md).

The full 20-project raw exports, original textbooks, backend service implementation, private endpoint configuration, raw model/session logs, and full orchestration runtime are not distributed in this release. The historical corpus covers different project environments; the small demo is a selected Lean 4.32.0 project. See [provenance and reuse](docs/provenance-and-reuse.md) for source attribution and licensing status.

## Related resources and citation

- [ReasBook](https://github.com/optpku/ReasBook): the versioned formalized source collection used by the Beck example. Its upstream library is distinct from this selected ReasLib demonstration.
- [Mathlib](https://github.com/leanprover-community/mathlib4): the mathematical library underlying the Lean examples.
- [Lean](https://lean-lang.org/): the theorem prover used for elaboration and proof checking.

The manuscript title is **LIFT: Library Integration of Formalized Theorems for Reusable Mathematical Knowledge**. A public paper URL and finalized bibliographic metadata will be added when available. To reference this artifact meanwhile, cite the repository URL and the exact Git commit used; do not infer publication or acceptance from this repository's existence.

Issues with a table, example, or tool are welcome through [GitHub Issues](https://github.com/wl-ma/LIFT/issues). Include the repository commit, Lean version, command, and a minimal diagnostic, without credentials or private source material.
