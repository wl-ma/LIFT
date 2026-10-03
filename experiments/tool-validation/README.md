# Compiler extraction and toolchain alignment

Supporting-tool validation, separate from paper model experiments.

The fixture covers 36 declarations on three compiler versions. A Mathlib norm-interface example checks a 4.30-to-4.32 migration with original scalar and pair clients. [Extraction](../../tools/lean_json/README.md) and [alignment](../../tools/toolchain/README.md) document the standalone tools.

## Reproduction

From the repository root:

```bash
python3 scripts/validate_tools.py --output _runs/tool-validation
```

Compiler checks require the case's fixed dependencies. [Environment setup](../../docs/reproducibility.md).

## Files


- [Result: package-checks.json](results/package-checks.json)

[Paper mapping](../../docs/experiments.md) · [Data dictionary](../README.md)

## Translation/review and automatic repair

[Workflow results](results/workflows.json) record two complementary checks:

- Real Lean extraction plus a labelled scripted provider exercises a wrong-formula rejection, one revision and two complete reviews. Fifty-five regression tests cover the public tools and artifact checks. This verifies protocol behavior; live model translation quality remains unevaluated in this run.
- A real Mathlib 4.30 → 4.32 migration first fails on the removed `NormedSpace.Extr` import. One diagnostic-gated rule repairs it. The full selected theorem type and trust checks pass, along with both original scalar and pair clients. The original project remains unchanged; no model calls are used.

The workflow record also retains the fixture/import setup errors and the corrected relative-output-path issue. They are development diagnostics, not source construction outcomes.

```bash
python3 scripts/validate_workflows.py --output _runs/workflow-validation
```

For the real automatic repair case, follow [the pinned example](../../tools/toolchain/README.md).

## Live model qualification

The [live workflow report](results/live-workflows.json) records real a hosted Responses API calls requesting `grok-4.7`. [Mathematical evidence](data/live-natural-evidence.json) contains the complete compiler context, generated text and hash-bound semantic reviews. A separate [source comparison](data/independent-live-review.json) checks all six cases against their actual mathematical inputs and compiler evidence.

| Case | Result | What was checked |
| --- | --- | --- |
| Positive-curvature structure | Accepted | Constructor, natural curvature, positivity field and integer center |
| Integer quadratic energy | Accepted | Complete definition, integer coercion and quadratic formula |
| Order preserved by addition | Accepted | Natural-number domains, all quantifiers and the required order hypothesis |
| ReasLib `StrongConvexC1On` | Accepted | General real normed space, convex domain, positive modulus, continuous differentiability and the every-pair lower bound |
| Deliberately omitted order hypothesis | Rejected | Removing `n ≤ m` makes the proposed statement false |
| Mathlib 4.30 → 4.32 import migration | Accepted | One model-proposed import repair, successful build, preserved declaration inventory/type/body/trust and both original clients |

The ReasLib case uses the existing accepted library source; its input remained unchanged. The migration starts from an actual failed build and supplies no replacement rule to the model. The proposed import change is applied only after matching a failed diagnostic; the final compiler and client checks determine acceptance.

The energy workflow initially remained undecided about its structure's proof field. The completed implementation includes compiler-identified constructors and fields of referenced structures before translation. A fresh translation and complete review then passed. Earlier protocol-invalid replies, the undecided reviews and one provider command failure remain in the accounting and evidence.

Across this qualification, 21 completed provider responses report 241,429 tokens. One additional provider attempt has unknown usage, so the exact total remains unknown. A separate launcher import failure occurred before any provider call. Implementation and independent audit usage are recorded separately and remain unknown. There were no automatic transport retries.

Sixty-nine regression tests pass. The [package qualification](data/package-qualification.json) also verifies an installed wheel in isolated WSL Python, without the construction backend: all five command-line entry points load successfully and packaged source bytes match the tested implementation. These live cases test meaningful structured definitions, a hypothesis-sensitive theorem and a real migration repair; they do not establish corpus-wide translation accuracy or formal equivalence between English and Lean.
