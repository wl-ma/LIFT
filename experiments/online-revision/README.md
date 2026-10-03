# Reuse during online revision

Ordered candidate events, source changes, and a checked Beck working state.

The [Beck project](../../examples/paper-cases/beck/README.md) retains both library states and all 22 original clients. `StrongConvexOn.congr` is accepted before the squared-norm revision. The broader first run subsequently failed final public-manifest validation; the second run accepted no mathematical update.

## Reproduction

From the repository root:

```bash
python3 scripts/check_case.py beck --output _runs/online-revision
```

Compiler checks require the case's fixed dependencies. [Environment setup](../../docs/reproducibility.md).

## Files

- [Input: online-events.json](data/online-events.json)
- [Input: online-revision.patch](data/online-revision.patch)
- [Result: online-checkpoint.json](results/online-checkpoint.json)
- [Result: online-trace.csv](results/online-trace.csv)
- [Result: package-checks.json](results/package-checks.json)

[Paper mapping](../../docs/experiments.md) · [Data dictionary](../README.md)
