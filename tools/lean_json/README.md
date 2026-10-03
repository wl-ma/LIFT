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

## Natural-language translation and semantic review

`translate.py` runs the complete natural-language workflow over real compiler facts:

1. Build and extract the selected modules, preserving all elaborated types and definition bodies.
2. Generate a complete mathematical statement with objects, assumptions, quantifiers, defining data and explicit uncertainties.
3. Include compiler-identified constructors and fields of structures appearing in the local dependency context. In a fresh invocation, review every dimension against the exact compiled context. Bind the report to hashes of both the draft and context, with exact type/body evidence for each check.
4. Resolve requested dependencies through Lean's compiled environment. Revise a rejected draft and review the entire result again, within the specified limits.
5. Save facts, every draft, review, context, per-call receipt and final result in a new output directory. Verify that the source project has not changed.

Configure the model adapter's runtime environment as described in [components and dependencies](../../docs/dependencies.md), then run:

```bash
python3 tools/lean_json/translate.py examples/lean-json \
  --module Fixture --name LIFTExample.twice_eq \
  --model-command '["python3", "tools/lean_json/model.py"]' \
  --max-repairs 2 --max-context-rounds 2 \
  --output _runs/natural-fixture
```

Omit `--name` to translate every declaration in the selected modules. Multiple modules and exact names are supported. `--context-bytes` sets the maximum serialized context size, default 250000 bytes; an excess fails explicitly rather than truncating mathematical data. The example model command is relative to the repository root. A custom provider command can route translator and verifier roles to different models.

`translation/result.json` uses schema `lift.natural-project.v1`; `validation.json` is the final unchanged-source check. Each record separates immutable `compiler` facts from generated `natural` content and its `review`. The mathematical fields are `statement`, `objects`, `assumptions`, `quantifiers`, `definition`, and `uncertainties`. Missing context, unresolved uncertainty or a failed check produces `needs_review`, never acceptance. A failed command records unknown usage rather than zero. Provider-returned usage remains recorded for incomplete or malformed replies. Malformed draft/review schemas trigger at most two explicit additional model calls, each retaining the original response and fee receipt; the program never reshapes an invalid reply into acceptance.

`accepted` denotes completion of the configured model review, not a formal proof that English and Lean are semantically equivalent. For publication, inspect the mathematical content and retain the review evidence. [Translation instructions](prompts/translator.md) and [review instructions](prompts/verifier.md) describe the roles; executable contracts reside in `src/lift_tools/natural.py`.

## Validation

```bash
python3 scripts/validate_tools.py --output _runs/tool-validation
python3 scripts/validate_workflows.py --output _runs/workflow-validation
python3 -m unittest discover -s tests -v
```

The first command checks real compiler extraction on three versions. The second combines real Lean extraction with an explicitly scripted provider to verify translation, rejection, repair, whole-draft review and recording. It makes no external model calls and measures workflow behavior, not translation quality. Regression tests also reject invented evidence, incorrect hashes, missing defining data, unauthorized context requests and repairs that merely erase uncertainties. [Recorded coverage](../../experiments/tool-validation/README.md).

The [live qualification](../../experiments/tool-validation/README.md#live-model-qualification) additionally uses real model calls for a structure, a quadratic definition, a theorem with a necessary hypothesis and ReasLib's strong-convexity predicate. Complete drafts, compiler context and semantic reviews are available with the results.

Compiler records also retain `expression_type_dependencies`, the constants present in the compiled type expression. The broader `type_dependencies` field additionally includes constructor and structure-field edges for navigation.
