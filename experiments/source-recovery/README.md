# Interfaces and source recovery

Obligation–task links and compiled source applications.

The selected Lean bundle is in [examples](../../examples/paper-cases/reaslib/README.md). After installing its pinned dependencies, run `python3 scripts/check_lean.py --output _runs/source-recovery`. Recorded handoffs and named Lean axiom checks remain distinct evidence.

## Reproduction

From the repository root:

```bash
python3 scripts/reproduce_tables.py --check
```

Compiler checks require the case's fixed dependencies. [Environment setup](../../docs/reproducibility.md).

## Files

- [Input: obligation-identities.json](data/obligation-identities.json)
- [Input: proof-stages.json](data/proof-stages.json)
- [Result: lean-checks-historical.json](results/lean-checks-historical.json)
- [Result: lean-checks-release.json](results/lean-checks-release.json)
- [Result: package-checks.json](results/package-checks.json)
- [Result: proof-handoff.csv](results/proof-handoff.csv)
- [Result: proof-obligations.csv](results/proof-obligations.csv)
- [Result: proof-task-links.csv](results/proof-task-links.csv)

[Paper mapping](../../docs/experiments.md) · [Data dictionary](../README.md)
