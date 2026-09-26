# ReasLib demo plan for version13

## What the manuscript actually describes

Version13 calls ReasLib the public mathematical components organized from the selected historical developments. The reproducibility paragraph names a ReasLib demo alongside experimental data, Lean-to-JSON extraction and toolchain-upgrade tools. It does not prescribe an online prover or promise that all 20 developments form one buildable release.

The manuscript presents three original executable examples: smooth optimality through an existing Mathlib interface, general Taylor interfaces with source specialization, and fundamental-group product maps with inverse laws. It also adds the normal-cone case: publication of an existing theorem followed by an actual radius-12 application in the same development. The Beck trace illustrates revision against an updated library context; its checked source checkpoint must remain distinct from the unsuccessful complete online release.

The appendix describes versioned shared-library releases with fixed project imports, public modules and source correspondences. This is the design target for a richer demo, not evidence that the complete corpus already satisfies that release contract.

## Proposed minimal demo

Use one offline static site with three views and downloadable independent Lean bundles. Keep it runnable without a model, account or server.

1. **Corpus view.** Search the 20 selected developments, see source catalogue and integration counts, inspect individual action and module records, and follow table provenance. Label module occurrences, inherited content and unfinished proofs explicitly. Do not display aggregate counts as counts of distinct new trusted theorems.
2. **Mathematical case view.** For each of the four cases, show the original requirement U, the exact full type of public interface g, the actual specialization or representation maps, and the source recovery/application. Put source code and the compilation/axiom evidence beside each claim. The normal-cone panel should distinguish source radius 1/2 from the actual later radius-12 caller, and show that the four core files were unchanged.
3. **Revision view.** Present the ordered Beck events, before/checkpoint source diff, accepted library context and original 22-client results. Clearly display the source checkpoint and complete-release outcomes separately, including failures. A selected event should reveal the corresponding source version and evidence.

The landing page should answer three questions immediately: what became public, where it was used, and what was checked.

## Implementation sequence

**A. Freeze the demo data contract.** Add a cases manifest containing exact declaration names, full types, source file/line links, immutable source hashes, source-to-interface relations, application/recovery declarations, toolchain/Mathlib pins, and check-report links. Existing CSV/JSON records remain the source of corpus statistics. Use explicit unknown values when recovery or dependency evidence is unavailable.

**B. Extend the existing static browser.** Reuse demo/template.html and scripts/build_demo.py. Add a source/interface/recovery comparison pane and evidence drawer, then a before/after Beck view. Keep data embedded so opening the generated HTML locally works. Download links point to independently pinned examples, rather than implying a single merged Lake project.

**C. Generate declaration-level evidence.** Use the expanded Lean-to-JSON tool to export the selected exact declarations and direct type/value dependencies. Build a small case dependency graph from those facts. A module-import graph must be labelled separately and cannot stand in for declaration dependencies or recovery evidence.

**D. Verify and package.** Regenerate HTML deterministically; test search, all four cases, event selection, relative links and downloads. Compile every independent bundle and original client set in CI. Bind the demo manifest and compiled reports to a fixed release tag. Refresh the anonymous mirror from that tag.

## Acceptance criteria

- Each mathematical claim links to exact source and a named declaration.
- Source recovery and later reuse are shown as distinct relations.
- Every trusted-proof badge comes from exact-name axiom checks and a pinned compilation.
- Missing, rejected and historical-only evidence stays visible.
- All counts regenerate from released inputs; all downloads work from an extracted mirror.
- Original three cases retain their five-file/nine-declaration scope; the additional normal-cone and Beck checks are reported separately.
- No live model calls or automatic experimental scheduling are introduced.

A hosted static copy can follow after this local artifact is accepted. Live editing/proving, full-corpus search and merging all historical projects are separate future work.
