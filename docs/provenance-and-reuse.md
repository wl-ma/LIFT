# Provenance and reuse

## Paper and data

The initial public package follows the version6 manuscript fixed on 26 September 2026 at 16:27 Beijing time. The paper source hash is recorded in [release-provenance.json](../data/release-provenance.json); the manuscript itself is not bundled here.

The construction and action tables derive from retained M2F project exports. The seven proof batches and 249 obligation links derive from recorded stage handoffs. Release-local project/obligation labels replace service identifiers; statistical units and values are retained. The raw action file is aggregated by project and decision. Complete logs, original textbook files, private service configuration, and full historical archives are outside this package.

## Selected Lean artifacts

The two public modules and three source applications were exported from the Nocedal numerical-optimization and Riemann-surfaces developments. They retain their original bytes, declarations, comments, and SHA-256 hashes. The public checks preserve the original relation between source file, module, and axiom output. Lake configuration and the small audit entry are new release packaging.

The Beck revision originates from an experiment on inputs drawn from [ReasBook](https://github.com/optpku/ReasBook), pinned at `f9674e6420188b5921fdbff7917aaf0e10cfa8a0`. The released patch includes original-source context and records how the generated public interface enters a source proof. ReasBook publishes under Apache-2.0; a copy is retained in [third_party/ReasBook-LICENSE](../third_party/ReasBook-LICENSE). The patch is experimental derived material, not an upstream ReasBook release.

Mathlib is resolved from its official repository at the explicit commit in the example project's Lake configuration. Its own license and dependency licenses remain with the downloaded upstream packages; those packages are not copied into this repository.

## Tooling

`HarnessFacts.lean` and the two role instructions come from the existing Leantegrate implementation. Their original hashes are recorded. The standalone extraction wrapper, alignment helper, demo, tests, and public documentation are new publication packaging. They do not expose the private M2F implementation or authenticate to any service.

The facts extractor's original supported environment was Lean 4.26.0. This package additionally exercises it on the supplied fixture with 4.30.0 and 4.32.0; that is the scope of the new compatibility evidence.

## Licensing status

This repository currently has **no blanket license grant** for newly released LIFT material or historical exported components without explicit upstream notices. Public availability alone does not establish permission to redistribute, sublicense, or incorporate all material into another project. Existing third-party terms remain intact. A project-wide code/data licensing decision will be added separately; this release does not invent one or relicense upstream work.

The published data and selected artifacts support inspection and reproducibility. For reuse beyond permissions already supplied by applicable upstream licenses, seek authorization from the relevant rights holders.
