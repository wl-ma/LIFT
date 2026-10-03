# Reproduction records

[The experiment registry](../metadata/experiments.json) maps paper labels to input files, result files, configuration, commands, and counting units.

New table and figure generation also emits `reproduction.json`, following the [common schema](schemas/reproduction.schema.json). It records the evidence kind, status, input hashes, output hashes, and the command-specific details. The report identifies these runs as `reproduction_check` with zero model calls.

Historical compiler and experimental reports retain their existing schemas. Their per-module results, source identities, axioms, clients, and original outcomes are preserved. New compiler runs write a separate directory using the commands in [reproduction](reproducibility.md).

File digests bind the evidence to its precise inputs. A passed aggregation check confirms a table reconstruction; its evidence kind does not turn it into a new model experiment or a full-corpus proof audit.
