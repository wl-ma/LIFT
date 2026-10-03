# A public interface in a later proof

Normal-cone source recovery, representation map, and actual research-proof caller.

The [normal-cone project](../../examples/paper-cases/normal-cone/README.md) recovers the source at radius 1/2 and supplies a research proof at radius 12. Input metadata binds the unchanged core modules and original upstream versions.

## Reproduction

From the repository root:

```bash
python3 scripts/check_case.py normal-cone --output _runs/downstream-reuse
```

Compiler checks require the case's fixed dependencies. [Environment setup](../../docs/reproducibility.md).

## Files

- [Input: normal-cone-comparator-upstream.md](data/normal-cone-comparator-upstream.md)
- [Input: normal-cone-integration.json](data/normal-cone-integration.json)
- [Input: normal-cone.json](data/normal-cone.json)
- [Result: package-checks.json](results/package-checks.json)

[Paper mapping](../../docs/experiments.md) · [Data dictionary](../README.md)
