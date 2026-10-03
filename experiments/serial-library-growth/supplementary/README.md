# Supplementary source proof cases

These executable cases accompany the serial ReasLib demonstration. They use source goals from Beck's optimization textbook and the Nesterov smoothing development. Each proof was generated against an accepted R4 library snapshot and independently checked against its complete original type. They are library reevaluations, recorded separately from the paper experiments.

| Case | Goal | Trusted owned declarations | Actual preceding-library use | Tokens / calls |
| --- | --- | ---: | --- | ---: |
| [Uniqueness](unique/project/Downstream/Unique.lean) | Supplied smoothed maximizers are equal | 8 | None | 294,201 / 2 |
| [Stability](stability/project/Downstream/Stability.lean) | Lipschitz bound between supplied maximizers | 22 | `strongConvexOn_iff_segment` through proof helpers | 756,702 / 3 |
| [Beck 5.25(b)](beck-525b/project/Downstream/Beck525b.lean) | Quadratic growth at a supplied global minimizer | 16 | None | 843,009 / 3 |
| [Existence](canonical-existence/project/Downstream/Existence.lean) | The continuous smoothed objective attains a maximum on nonempty compact data | 11 | None | 451,635 / 3 |

Uniqueness and stability retain their supplied-maximizer premises. Beck retains the supplied minimizer and extended-real domain; it adds no smoothness or finite-dimensionality hypothesis. Existence uses the original finite-dimensional closed, bounded, nonempty domain and continuity, with arbitrary real smoothing parameter. Its 451,635 tokens are additional source-interface construction, counted once and separately from downstream solving. The three solving cases cost 1,893,912 tokens / 8 calls; existence costs 451,635 / 3. Prior library construction is accounted in the [serial results](../README.md).

## Build and check

Each `project/` is a complete isolated Lean package with the same Lean 4.30.0 / Mathlib pin as the demo. For each case:

```bash
cd experiments/serial-library-growth/supplementary/stability/project
lake update
lake exe cache get
lake build Downstream
```

After installing dependencies in all four projects, from the repository root:

```bash
python3 scripts/check_serial_cases.py --output _runs/reaslib-cases
```

The checker recompiles every goal, captures the complete private/generated declaration inventory, compares original full types and direct dependencies, and allows only `propext`, `Classical.choice`, and `Quot.sound`. It makes no model calls. `review.json` binds the distributed bytes, exact target and cost; `facts.json` supplies complete formal types and actual dependencies.
