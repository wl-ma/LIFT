# Reproduce the version13 artifact

## Data and figures

~~~sh
python3 scripts/verify_release.py
python3 scripts/reproduce_tables.py --check
python3 scripts/reproduce_tables.py --output _runs/tables
python3 -m pip install -r requirements-plots.txt
python3 scripts/plot_results.py --output _runs/figures
python3 -m unittest discover -s tests -v
~~~

Six CSV tables are independently recomputed from [portable records](../data/records/).
The output also contains LaTeX rows and a report. Stage counts remain recorded
backend aggregates; individual action/module rows and proof-stage records support
recomputation of their corresponding tables. No raw credential, endpoint, model
transcript, or textbook archive is needed. Figure typography is regenerated;
the numerical inputs are fixed.

The 61 retained snapshots are classified into 20 selected mathematical
developments, 17 related versions, four partial developments and 20 system tests.
Selection was based on available artifacts and mathematical coverage, not a random
sample. Repeated module occurrences and inherited content are not deduplicated
into new theorem counts. Proof matching tries exact obligation ID first, then
declaration plus owner: 246 exact links and three secondary links. The 258 links,
72 linked task aliases, and 135 successful tasks in seven batches are different units.

## Lean cases

The original [three-case project](../examples/reaslib/README.md),
[normal-cone case](../examples/normal-cone/README.md) and
[Beck checkpoint](../examples/beck/README.md) have separate environments and checks.
They are not merged into a single library.

## Extraction and migration

~~~sh
python3 scripts/validate_tools.py --output _runs/tool-validation
~~~

This exercises private/generated declarations, polymorphic structures, instances,
cross-module proof dependencies and exact missing-name rejection on Lean 4.26,
4.30 and 4.32. It then migrates the real
[Mathlib norm interface](../examples/mathlib-migration/) from 4.30 to 4.32, compares
compiler facts including dependencies, and runs the same two original clients
in both environments. Dependency downloads are required on a clean machine.

Existing matching dependency caches can be supplied explicitly with
--packages-430 and --packages-432; their Mathlib commits are checked before use.
Cache-based local checks and fresh-checkout GitHub CI results are reported separately.

## Validation scope

data/validation/ records package checks. Historical results stay in their original
files. No command here runs a model or resumes a previous campaign.
