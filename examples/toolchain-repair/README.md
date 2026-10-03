# Removed-import migration case

A generic norm-nonnegativity interface imports the deprecated `Mathlib.Analysis.NormedSpace.Extr` module under Lean/Mathlib 4.30. The 4.32 target no longer contains that module. The checked repair replaces it with the actual norm dependency, `Mathlib.Analysis.Normed.Group.Basic`.

The theorem's full type stays fixed. Original clients instantiate it for real scalars and pairs. Their hashes are in `clients.json`; version-specific replacements are in `rules.json`. [Run the migration](../../tools/toolchain/README.md).
