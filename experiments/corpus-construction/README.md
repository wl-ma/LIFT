# Construction across mathematical domains

Recorded construction, declaration decisions, and public-module occurrences.

Selection, stages, individual actions, module records, and integration manifests feed the three aggregate CSV tables. Run `python3 scripts/plot_results.py --output _runs/figures` to reproduce the decision profile.

## Reproduction

From the repository root:

```bash
python3 scripts/reproduce_tables.py --check
```

Compiler checks require the case's fixed dependencies. [Environment setup](../../docs/reproducibility.md).

## Files

- [Input: actions.csv](data/actions.csv)
- [Input: integration-manifests.csv](data/integration-manifests.csv)
- [Input: modules.csv](data/modules.csv)
- [Input: project-metadata.json](data/project-metadata.json)
- [Input: provenance.json](data/provenance.json)
- [Input: selection.csv](data/selection.csv)
- [Input: stage-counts.csv](data/stage-counts.csv)
- [Result: construction.csv](results/construction.csv)
- [Result: declaration-actions.csv](results/declaration-actions.csv)
- [Result: module-profile.csv](results/module-profile.csv)

[Paper mapping](../../docs/experiments.md) · [Data dictionary](../README.md)
