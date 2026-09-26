# Lean-to-JSON compiler extraction

`extract.py` exports facts from Lean's compiled environment, using the retained `HarnessFacts.lean` extractor. It is a deterministic preparation tool, independent of the private integration backend and model services.

## Requirements and quick start

- Python 3.10+ and Elan/Lake on `PATH`.
- A project pinned to Lean **4.26.0, 4.30.0, or 4.32.0**.
- Matching project dependencies. The supplied small example needs no Mathlib.

From the repository root:

```bash
python3 tools/lean_json/extract.py examples/lean-json \
  --module Fixture --output _runs/fixture-facts.json

python3 tools/lean_json/extract.py examples/lean-json \
  --module Fixture --name LIFTExample.twice_eq \
  --output _runs/one-theorem.json
```

`--module` may be repeated. `--name` requires exactly one module and an exact fully qualified declaration name. Omit it to export all compiler declarations owned by that module, including generated names. `--skip-build` uses existing build products; the caller is responsible for their freshness. The default builds the selected modules before extraction. Existing output files are refused.

The original extractor was developed for 4.26.0. This public wrapper has also been exercised on the supplied fixture under 4.30.0 and 4.32.0. That compatibility check does not imply validation on every project or Lean release. Unsupported versions fail explicitly before extraction.

## Data contract

The JSON envelope has schema identifier `lift.compiler-facts.v1`, compiler version, module scope, input hashes, extractor hash, and `records`. Each record contains:

| Field | Source and interpretation |
| --- | --- |
| `declaration_key` | `Module::fully.qualified.name`; identity within the exported scope |
| `name`, `module`, `kind` | Compiler declaration identity and kind |
| `type` | Full pretty-printed elaborated type, including dependent parameters |
| `definition_value` | Pretty-printed body for definitions; null for other kinds |
| `type_dependencies`, `value_dependencies` | Constants used in elaborated expressions |
| `dependency_modules` | Owning modules of those referenced constants |
| `constructors`, `structure_fields` | Constructor names / structure projection functions |
| `mutual_family` | Compiler-associated mutually defined family |
| `axioms`, `is_unsafe`, `is_partial` | Trust-related information |
| `source_range`, `selection_range` | Compiler source positions, when available |

The export is scoped to selected modules; references outside it remain references rather than silently fabricated nodes. Types are pretty-printed representations, not serialized kernel expressions. Formatting can change between compiler versions. The wrapper fingerprints Lean sources and environment files, checks the selected compiler, and rejects changes during extraction.

See [the fixture output](../../examples/lean-json/expected-facts.json) for an actual output. It contains a definition, a public equation, and a caller that reuses it.

## Natural-language layer

The existing [translator](prompts/translator.md) and [verifier](prompts/verifier.md) instructions document the separate generation/review roles. They are shipped as reference instructions, with their original contract-specific terminology. This standalone command does not implement those model calls, the full natural-language schema, semantic review, or backend submission.

Compiler facts and generated prose must remain distinct. A complete natural-language workflow should retain the identity and formal specification, record context selection, and review generated prose against the actual hypotheses, conclusions, and prescribed data. Structural JSON validity alone does not establish mathematical correspondence.
