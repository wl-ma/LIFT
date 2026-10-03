# Provenance and reuse

[Provenance](../metadata/provenance.json) binds the paper source identity, curated evidence inputs, and selected mathematical exports by SHA-256. [The artifact registry](../metadata/artifacts.json) resolves logical data names to their experiment directories. [The integrity manifest](../metadata/artifact-manifest.json) binds the public files.

## Experimental records

Construction and decision data come from retained formalization-project exports. Selection, stage counts, actions, modules, integration manifests, and proof-stage projections support aggregate regeneration. Release-local project and task labels preserve relationships without service identifiers. The records retain their counting units and original outcomes.

## Mathematical sources

The two public modules and three source applications in the calculus/topology bundle come from the Nocedal numerical-optimization and Riemann-surfaces developments. Their original source bytes and hashes are preserved.

The Beck sources derive from ReasBook, revision `f9674e6420188b5921fdbff7917aaf0e10cfa8a0`. Before and checkpoint states, original clients, and the source-context patch are retained. [ReasBook's Apache-2.0 license](../third_party/ReasBook-LICENSE) accompanies them.

The normal-cone bundle preserves the mathematical bodies of 60 source modules with Apache-2.0 contributor headers. [Its provenance](../experiments/downstream-reuse/data/normal-cone.json) binds the source, four unchanged core modules, and later caller. The upstream verification excerpt and the local compiler report are identified separately.

Mathlib and its dependencies are resolved at the projects' fixed revisions. Their upstream terms apply to the downloaded packages.

## Software and publication materials

The shared artifact utilities implement table reconstruction, case compilation, axiom auditing, plotting, and integrity checks. `HarnessFacts.lean` records its original source identity and the public expression-dependency extension; translator/verifier role instructions retain their source identities. Public wrappers provide standalone entry points.

[LICENSES.md](../LICENSES.md) defines the Apache-2.0 and CC BY 4.0 scopes for software, documentation and data. Third-party notices accompany the corresponding material.

[Source publication bindings](../metadata/source-publication.json) record attribution-only header changes, original report hashes, distributed file hashes, and unchanged body hashes. Historical compilation reports keep their original source identities.
