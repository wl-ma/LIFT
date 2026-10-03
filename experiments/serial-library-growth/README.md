# Serial library growth

**Question:** Can successive textbook developments become one reusable Lean library while retaining all earlier source interfaces?

One Lean project grows through six batches from Beck, Bauschke–Combettes, and Nesterov. Each batch performs statement preparation, library integration, and proof with Grok 4.7, one model session at a time. The executable demo illustrates the paper's interface and source-recovery methodology; its measurements are separate from the paper's corpus tables.

[Lean project](../../examples/reaslib-serial/README.md) · [Interactive results](../../demo/serial.html) · [Source index](data/sources.json) · [Protocol](data/protocol.json) · [Supplementary cases](supplementary/README.md)

## Sources and accepted releases

| Release | Added material | Source units | Trusted declarations | Cumulative source interfaces | Representation obligations |
| --- | --- | ---: | ---: | ---: | ---: |
| R0 | Beck Definition 5.16; Theorem 5.17 | 2 | 38 | 5 | 0 |
| R1 | Bauschke–Combettes Definition 10.7; Proposition 10.8 | 2 | 51 | 7 | 0 |
| R2 | Nesterov Definition 2.1.3; Theorem 2.1.9 | 2 | 81 | 10 | 2 |
| R3 | Beck Lemma 5.20; Example 5.21 | 2 | 106 | 12 | 10 |
| R4 | Nesterov Lemma 2.1.6; Theorem 2.1.8; a representation bridge | 2 | 134 | 15 | 19 |
| R5 | Bauschke–Combettes Example 22.4(iv); Proposition 23.13 | 2 | 180 | 18 | 51 |

The 12 textbook units and the additional bridge are counted separately. Full inventories include private and compiler-generated declarations. The final project passes all 69 exact source/representation clients, 25 extension boundary examples, and the original 21 independent checks. Original interface types and mathematical proof bodies are retained; three public forwarding imports preserve the final source import surface.

## Mathematical interfaces and actual use

- **Extended-real strong convexity:** effective domains, quadratic shifts, and real/extended-real equivalences.
- **Addition and constraints:** the constrained quadratic proof calls the shared addition theorem.
- **Differentiable curvature:** nonnegative weighted combinations, stationary quadratic growth, and a real/extended-real bridge. The bridge consumes preceding equivalences; weighted-combination proofs use their differentiable interface.
- **Monotone operators:** the subdifferential strong-monotonicity proof calls the preceding strong-convexity equivalence. Graph monotonicity, range-defined resolvents and cocoercivity give the exact inverse-`(beta + 1)` norm bound.

[Compiled extension dependencies](results/extension-reuse.json) distinguish actual proof calls from imports. The independent quadratic client connects three source views; supplementary stability uses one representation equivalence. These are observed dependencies, without a measured paired-method speedup or independent reconstruction score.

## Construction accounting

| Batch, including source-interface recovery | Known settled tokens | Recorded calls | Recorded provider retries |
| --- | ---: | ---: | ---: |
| Beck initial | 4,797,780 | 34 | 1 |
| Bauschke–Combettes initial | 4,207,637 | 31 | 0 |
| Nesterov initial | 4,497,891 | 25 | 0 |
| Beck extension | 3,944,810 | 33 | 0 |
| Nesterov extension and bridge | 4,320,026 | 38 | 0 |
| Bauschke–Combettes extension | 3,914,496 | 24 | 0 |
| **Known subtotal** | **25,682,640** | **185** | **1** |

The subtotal includes recorded failed calls and interface recovery. Usage is unreported for one interrupted initial attempt and two extension calls; exact total tokens and calls are therefore unknown. Currency cost and evaluator usage are unmeasured. The B5 ledger already includes its earlier attempts, which are counted once. Supplementary-case costs are listed separately.

## Reproduce

```bash
python3 scripts/check_serial_demo.py --output _runs/reaslib-serial
python3 scripts/check_serial_cases.py --output _runs/reaslib-cases
python3 scripts/build_serial_demo.py --data experiments/serial-library-growth/results/demo.json --output _runs/reaslib-serial.html
```

Install the pinned dependencies in the [project guide](../../examples/reaslib-serial/README.md) and [case guide](supplementary/README.md). Checks build the distributed mathematical sources, verify complete declaration axioms and immutable clients, and make no model calls.

## Records

- `data/sources.json`, `data/extension-selection.json`: exact selections and source identities.
- `data/protocol.json`: model, serial execution, environment and release contract.
- `results/demo.json`: six accepted releases, complete types/dependencies and accounting.
- `results/initial-demo.json`: the original three-batch dataset, unchanged.
- `results/package.json`, `results/package-checks.json`: public source hashes and compiler checks.
- `results/reviews/`: portable final review summaries.
- `results/supplementary-cases.json`, `supplementary/`: separately reviewed source proofs.
