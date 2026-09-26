# Release validation — 26 September 2026

This record describes checks of the public package. Historical paper evidence remains separately identified in `data/`; the checks below are not new model experiments.

| Check | Result | Scope |
| --- | --- | --- |
| Paper table consistency | Passed | 20 projects, 10,922 catalogue items, 5,061 integrations, 15,716 module occurrences; all five action-category totals |
| Proof handoff consistency | Passed | 7 batches, 118 successful integration items, 135 successful proof tasks, 249 obligation links |
| Source-byte preservation | Passed | Five released Lean files match their historical SHA-256 hashes |
| ReasLib compilation | Passed | Five files, sequentially compiled with installed Lean 4.32.0 and the pinned Mathlib cache |
| Declaration axiom audit | Passed | Nine named declarations; only `propext`, `Classical.choice`, `Quot.sound` |
| Original Beck checkpoint | Rechecked from retained records | All 20 type hashes match baseline; 15 theorem-kind declarations have trusted-proof flags; all 22 recorded clients pass |
| Lean-to-JSON fixture | Passed | Three declarations exported with Lean 4.26.0, 4.30.0, and 4.32.0 |
| Cross-version fixture comparison | Passed | Selected types, definition bodies, axiom sets and trust flags unchanged in 4.26→4.30 and 4.26→4.32 exports |
| Missing exact declaration | Correctly rejected | An unknown fully qualified name causes failure and no output artifact |
| Regression tests | Passed, 6 tests | Definition/kind drift, new axioms, missing/duplicate identities, empty exports, isolated preparation and explicit Mathlib pins |
| Formatting and static checks | Passed | Ruff format/check on public Python tools, scripts, and tests |
| Offline demo | Passed | Search narrows the corpus; case controls switch content; timeline reaches the recorded checkpoint; desktop page visually inspected |
| Public-package hygiene | Passed | Curated files only; no service credentials, raw backend logs, local absolute paths, caches, or original textbooks |

The complete fresh-install Lake dependency download was not repeated. ReasLib was compiled from the released source files against the matching existing dependency cache; no new toolchain, Mathlib cache, or model call was needed for those checks. The small fixture's Lake build path was exercised for each of the three compiler versions.

The original Lean extractor was retained byte-for-byte. This release adds a tested standalone wrapper; compatibility on a three-declaration fixture is narrower than validating every declaration kind or every external project on those compilers.

The toolchain helper is a new preparation/comparison utility, not evidence of a previously completed automated whole-project migration system. It detects selected textual fact changes and leaves arbitrary API repair and original-client verification explicit.

No full corpus proof audit, new integration campaign, model benchmark, comparative runtime experiment, or remote deployment was performed for this release.

## Version10 completeness review

The latest manuscript keeps the numerical evidence unchanged. The [artifact map](paper-artifact-map.md) now locates its four experimental subsections and the Taylor recovery chain. A new curated table preserves 258 obligation–task links covering the same 249 obligations and 72 linked task aliases; the 135 successful-task batch total remains a distinct measure.

The package verifier now also checks these links, the shared Taylor task, every file hash in release provenance, summary action totals, and exact regeneration of the offline demo from its template and released tables. The migration comparator now rejects empty exports and detects declaration-kind changes. These close packaging and validation gaps without changing the historical mathematical evidence.

## Version13 fresh checks

The version13 refresh additionally recompiles the normal-cone import closure (60 original modules, a full-type source specialization, and the named audit) and the Beck checkpoint (17 original modules, audit, and all 22 original hash-bound clients). Five normal-cone and 15 Beck theorem identities pass the exact-name axiom allowlist. The original 20 Beck type-hash comparison remains retained historical evidence; the fresh checks do not claim to have rerun that complete type-hash extractor.

The expanded Lean-to-JSON fixture exports 36 declarations on each of Lean 4.26.0, 4.30.0 and 4.32.0, covering structures, instances, private/generated declarations and cross-module dependencies. The real Mathlib norm-interface example passes original scalar and pair clients on pinned 4.30 and 4.32 dependencies; selected declaration facts, including dependencies, agree. This is one validated migration example, not automatic repair of arbitrary projects.

All six numerical CSV tables regenerate from portable released records. Plot generation uses those tables, normalizes declaration-action shares and combines the two retention categories. Twelve regression tests and scoped Ruff checks pass. Detailed case/tool reports are in data/validation; commands are in reproduce-v13.md. Local compilation used matching installed dependency caches. The new CI workflow exercises clean-checkout dependency setup; its hosted result must be checked separately.

Two local packaging checks failed before being corrected: the normal-cone driver initially omitted the upstream Lean options; the Beck compiler's initial 4 GiB limit was insufficient. The driver now preserves the original options and allows 8 GiB for Beck. No mathematical source was changed to make either check pass. These were zero-model packaging checks, not additional experimental trials.

Version13 adds source-level Apache-2.0 notices for the upstream normal-cone files and retains ReasBook attribution. No blanket license is inferred for material without an explicit grant; see LICENSES.md.

The first hosted CI run passed data regeneration and detected a missing dependency lock in the original example bundle. The exact pinned Mathlib dependency lock is now included; the first failure remains visible in CI history.

## Completed clean-checkout CI

[Run 36249511312](https://github.com/wl-ma/LIFT/actions/runs/36249511312) passed all five jobs on commit 76eeae114b65c554074e98fa264a04e1d314056f: data, original ReasLib examples, normal-cone, Beck and tools. Dependency setup used a fresh hosted checkout. The final publication commit only adds this result, mirror download/checksum notes and their refreshed manifest; executable source is unchanged from the checked commit. The paper-v13 tag fixes that final package. See data/validation/ci.json for job identities. No model experiment was run.
