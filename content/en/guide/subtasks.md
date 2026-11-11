---
title: "Repeated tasks and 100 Gaussian toys"
weight: 40
guide_group: "workflow-tutorials"
summary: "One Task impression, N indexed executions, and a generate–fit–summarize example."
---

Add `subtasks: N` to a Task's `celebi.yaml` to repeat its computation N times.
It remains an ordinary Task with one impression. Yuki generates a Snakemake
wildcard rule plus a completion rule, without registering N Yuki jobs or
impressions. This is separate from `create-multi-tasks`, which creates
independent Task objects.

```yaml
environment: python3.12
memory_limit: 128Mi
subtasks: 100
commands:
  - python code/fit.py --index ${index} --input toys/stageout/${index}/*.json --output stageout/index
```

N must be a positive YAML integer. `${index}` supplies the decimal integer
0 through N - 1; use `type=int` when parsing it in Python. `index` is reserved
in parameters when subtasks is set. Omitting subtasks preserves normal Task
behavior. Both Celebi and Yuki need the update. Data-only tasks, the special
`htcondorcern` backend and client test/workaround expansion are unsupported.

## Paths and aliases

| Path | Meaning |
|---|---|
| `toys/stageout/${index}/*.json` | Select an upstream partition by index |
| `stageout/index/fit.json` | Literal output path inside the current instance |
| `stageout/7/fit.json` | Actual Task output for index 7 |
| `fits/stageout/7/fit.json` | The same file through a downstream alias |

The runner links the literal `stageout/index/` directly to the current
numbered output directory. Caches, collected results and downstream inputs
preserve `stageout/<number>/`; even `subtasks: 1` retains `/0/`. There is no
post-run relocation. Separate workspaces prevent accidental collisions but
do not add an operating-system security sandbox.

An alias always references the whole upstream Task. Downstream Tasks wait
for all upstream instances. Explicitly choose `${index}` for pairwise input,
or traverse all partitions for a reduction. The shell expands `*.json`;
each partition in this example contains exactly one toy dataset.

## Three Tasks, 100 Gaussian toys

The local `Demo/demo-subtasks-01-gaussian-toys` project has this graph:

```text
GenerateTask -> FitTask (100 subtasks) -> SummaryTask
```

Each toy contains 1,000 Gaussian observations with true mean 5, sigma 1.5,
and seed 20261025 + index. Fits use the exact unbinned Gaussian maximum
likelihood solution with asymptotic curvature errors. All scripts use only
Python's standard library; no ROOT, NumPy or numerical optimizer is required.

Download [generate.py](/examples/gaussian-toys/GenerateTask/generate.py),
[fit.py](/examples/gaussian-toys/FitTask/fit.py), and
[summarize.py](/examples/gaussian-toys/SummaryTask/summarize.py). Create the
three Tasks and put each script in its corresponding directory:

```bash
celebi-cli create-task GenerateTask
celebi-cli create-task FitTask
celebi-cli create-task SummaryTask
cd FitTask
celebi-cli add-input ../GenerateTask toys
cd ../SummaryTask
celebi-cli add-input ../FitTask fits
```

**GenerateTask/celebi.yaml** runs once and writes `stageout/0/toy.json`
through `stageout/99/toy.json`, plus `manifest.json`:

```yaml
environment: python3.12
memory_limit: 128Mi
parameters:
  toys: 100
  events: 1000
  mean: 5.0
  sigma: 1.5
  seed: 20261025
commands:
  - python generate.py --toys ${toys} --events ${events} --mean ${mean} --sigma ${sigma} --seed ${seed} --output stageout
```

Use the first YAML block on this page for **FitTask**. Repeated inline tasks
expose shared source as `code/`; each writes `stageout/index/fit.json`.

**SummaryTask/celebi.yaml** checks all 100 results and writes `fits.csv`,
`summary.json`, `summary.svg` and `report.md`:

```yaml
environment: python3.12
memory_limit: 128Mi
parameters:
  expected: 100
commands:
  - python summarize.py --fits fits/stageout --expected ${expected} --output stageout
```

The summary fails on missing or inconsistent results. When changing the
ensemble size, update GenerateTask's `parameters.toys`, FitTask's `subtasks`,
and SummaryTask's `parameters.expected` together.

Define `.celebi-env/python3.12.yaml` at the project root:

```yaml
channels:
  - conda-forge
dependencies:
  - python=3.12
```

Install with `celebi-cli install-environment local python3.12`, set
`celebi-cli request-runner local` in all three Tasks, then from SummaryTask:

```bash
celebi-cli submit --runner local
celebi-cli status --wait
celebi-cli collect all
celebi-cli view-url
```

The Demo project's `python run_local.py --cores 4` independently validates
Yuki's production Snakefile using the current Python environment without a
server. Outputs are in `.local-run/results/`. All 100 fits passed; average
fitted mean was 4.995186 and sigma 1.496423 for the supplied configuration.
These are reproducibility references, not acceptance thresholds or proof
of a live service run. Pulls fluctuate with the finite ensemble.

## Logs, caches and retries

From FitTask, `celebi-cli log 0 --subtask 7` selects command 0 of instance 7;
add `--follow` to follow new output. Logs and per-instance status files live
under `logs/<number>/`. Abrupt termination may leave a stale running status.
Terminal details retain failed indices. A short instance that starts and fails
between status polls is classified as a runtime failure when backend logs show it
ran, rather than as a workflow-construction failure. REANA collection expands
nested listings and archives while preserving numeric stageout/log directories.

The Task completion marker and full cache are published only after all
instances succeed. Snakemake `--rerun-incomplete` in the same workspace can
preserve successful instances. A new Celebi workflow may run all instances
again; cross-workflow per-index reuse and a dedicated index retry CLI are
not implemented.
