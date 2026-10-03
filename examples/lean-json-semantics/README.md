# Structured mathematical translation

This Lean 4.32.0 example needs no Mathlib. It covers three distinct translation tasks:

- `SemanticExample.QuadraticModel`: a structure carrying a natural curvature, its positivity proof, and an integer center.
- `SemanticExample.energy`: a definition with an explicit natural-to-integer coercion and a quadratic expression.
- `SemanticExample.add_order`: an order theorem whose conclusion depends on the hypothesis `n ≤ m`.

Run the standalone translator with a configured model adapter:

```bash
python3 tools/lean_json/translate.py examples/lean-json-semantics \
  --module Semantic \
  --name SemanticExample.QuadraticModel \
  --name SemanticExample.energy \
  --name SemanticExample.add_order \
  --model-command '["python3", "tools/lean_json/model.py"]' \
  --output _runs/semantic-example
```

The compiler context includes the constructors and fields of referenced structures. The reviewer checks the full mathematical statement, including definition bodies and hypotheses. Every draft, review, context expansion and usage receipt is retained. See [tool validation](../../experiments/tool-validation/README.md).
