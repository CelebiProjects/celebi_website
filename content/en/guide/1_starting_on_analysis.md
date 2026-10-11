---
title: "Starting an Analysis"
summary: "Learn how to run a Celebi analysis with remote data and locally managed code."
---

# Starting an Analysis with Celebi

This tutorial demonstrates how to set up and run a physics analysis using **Celebi**.

In this example:

- **Analysis code** is developed and managed on your local computer.
- **Input data** is stored on a remote server.
- **Computational tasks** are submitted to and executed on the remote server.
- **Output files** can be collected or downloaded after execution.

The example project is named `B02K3pi`, and the remote runner is `pkufarm212`.

## Prerequisites: Start Yuki

Open a WSL terminal and start Yuki:

```bash
❯ yuki docker run yuki:dev --dev-dir ~/Yuki --celebi-dir ~/Celebi
```

## 1. Initialize a Project

Create a directory for your analysis project:

```bash
❯ mkdir B02K3pi
❯ cd B02K3pi
❯ celebi init
❯ celebi
```

This directory becomes the root of your Celebi analysis project.

## 2. Register Remote Data

The raw data is stored on the remote server. Instead of copying it to the local computer, we register its location with Celebi.

In the Celebi shell, run:

```text
>>>> create-data Raw
>>>> cd Raw
>>>> register-ssh-data pkufarm212 /home/user/workdir/TestData
```

Here:

- `Raw` is the data object created in Celebi.
- `pkufarm212` is the remote server.
- `/home/user/workdir/TestData` is the directory containing the remote data. Replace it with your actual path.

This step registers the remote data location so that downstream tasks can reference it.

## 3. Create and Configure a Task

A **task** defines the code, environment, inputs, and commands required for one processing step.

### 3.1 Create a task

Return to the project root and create a task:

```text
>>>> cd ..
>>>> create-task filter0
```

Create a Python script named `filter0.py` in the `filter0` directory.

Then configure the task's `celebi.yaml`:

```yaml
descriptor: filter0
environment: env_root_6.38.04
memory_limit: 256Mi

commands:
  - python3 filter0.py
```

The main fields are:

| Field | Description |
|---|---|
| `descriptor` | Name of the task |
| `environment` | Conda environment used on the runner |
| `memory_limit` | Memory allocation for the task |
| `commands` | Commands executed during the workflow |

**Note:** YAML is indentation-sensitive. Each command must be preceded by a hyphen and a space (`- `).

### 3.2 Connect input data

Enter the task directory and add the registered data as an input:

```text
>>>> cd filter0
>>>> add-input ../Raw raw_data
```

Here:

- `../Raw` refers to the registered data object.
- `raw_data` is the input alias used within this task.

The alias is independent of the original data object's name or location. This makes the workflow easier to maintain when upstream objects are renamed or reorganized.

To remove the input connection:

```text
>>>> remove-input raw_data
```

Use the input alias, not the original data object name.

### 3.3 Input and output directories

When `filter0.py` executes, the expected directory structure is:

```text
filter0/
├── celebi.yaml
├── filter0.py
├── raw_data/
│   └── stageout/
│       └── input.root
└── stageout/
    └── output.root
```

The important paths are:

- **Input:** `raw_data/stageout/`
- **Output:** `stageout/`

For example, a Python script can use:

```python
import ROOT
from pathlib import Path

input_file = ROOT.TFile.Open("raw_data/stageout/input.root")

Path("stageout").mkdir(exist_ok=True)
output_file = ROOT.TFile("stageout/output.root", "RECREATE")

# Add your analysis code here.

output_file.Close()
input_file.Close()
```

Replace `input.root` with the actual input filename.

Files written to `stageout/` are treated as the task's output artifacts.

## 4. Configure the Execution Environment

### 4.1 Check available environments

To list the Conda environments available on the remote server:

```text
>>>> runner-environments pkufarm212
```

Example output:

```text
Conda environments on 'pkufarm212' (3):
  base                  /home/zouqt/miniconda3
  env_root_6.38.04      /home/zouqt/miniconda3/envs/env_root_6.38.04
  snakemake             /home/zouqt/miniconda3/envs/snakemake
```

For this analysis, we use:

```yaml
environment: env_root_6.38.04
```

The environment must exist on the runner.

### 4.2 Set the default environment

To avoid specifying the same environment for every new task, open the user configuration:

```text
>>>> user-config
```

Relevant settings include:

```yaml
# Default runner for newly created tasks
default_runner: pkufarm212

# Automatically download task outputs
auto_download: true

# Cache results on the remote runner
cache_on_runner: true

# Default environment for new tasks
task_environment: env_root_6.38.04
```

After saving the configuration, newly created tasks will inherit these defaults.



## 5. Configure the Runner

A **runner** is the remote execution resource responsible for running the analysis.

### 5.1 Enable remote caching

To enable caching on the runner:

```text
>>>> cache-on-runner on
```

Caching allows task results to be retained on the remote runner, which can reduce unnecessary data transfers or repeated computation when supported by the workflow.

### 5.2 Request a runner

If no runner has been assigned, request one:

```text
>>>> request-runner pkufarm212
```

This associates the task with the specified remote runner.

## 6. Inspect the Workflow

Before submitting a task, inspect its configuration:

```text
>>>> ls
```

Example output:

```text
DITE: [connected]

README:
Please write README for task filter0

o--> Predecessors:
[0] (task)       raw_data: @/TestData

---- Task files:
filter0.py

Environment: env_root_6.38.04
Memory limit: 256Mi
Validated: True
Request runner: pkufarm212
Request cache: True

---- Commands:
python3 filter0.py
```

Check that:

- The input data is correctly connected.
- The Python script is included.
- The execution environment is correct.
- The requested runner is available.
- The task configuration is valid.

A task marked `Validated: True` has passed configuration validation, but this does not guarantee that the analysis code will execute successfully.

## 7. Submit and Monitor the Job

### 7.1 Submit the task

Once the configuration is ready:

```text
>>>> submit --runner pkufarm212
```

Celebi submits the workflow for execution on the remote server.

### 7.2 Check job status

Use:

```text
>>>> status
```

While the task is running, the output may look like:

```text
Status of : filter0_task
Impression: [9017b6082037087e287fa89b76caca7b]
DITE: [connected]

Job status: [in movement][running]
Details: Executing workflow steps

**** Workflow:
Workflow: [pkufarm212][494f0f6c61b34204b2e8910404c772e9]

Stageout files:
    (nothing to show yet — run 'collect',
     or the runner may be unreachable)
```

The workflow identifier and impression hash are generated for the execution and will differ between runs.

### 7.3 View execution logs

To inspect the logs:

```text
>>>> log
```

To follow the logs in real time:

```text
>>>> log -f
```

Logs are useful for diagnosing Python exceptions, missing input files, environment problems, and runtime errors.

### 7.4 Check completed results

After successful execution:

```text
>>>> status
```

Example:

```text
Status of : filter0_task
Impression: [9017b6082037087e287fa89b76caca7b]
DITE: [connected]

Job status: [coda][finished]
Details: Remote execution completed

**** Workflow:
Workflow: [pkufarm212][494f0f6c61b34204b2e8910404c772e9]

Stageout files:
    NAME                       SIZE       TYPE   IN YUKI
    24r1_down_cut0.root        758.7 MB   data   ✗
    24r1_up_cut0.root            1.2 GB   data   ✗
    25c1_down_cut0.root        135.6 MB   data   ✗
    25c1_up_cut0.root          555.9 MB   data   ✗
    25c2_down_cut0.root          1.3 GB   data   ✗
    25c3_up_cut0.root          867.2 MB   data   ✗
    25c4_down_cut0.root        328.7 MB   data   ✗
    25c4_up_cut0.root          442.7 MB   data   ✗
```

Here:

- `[coda][finished]` indicates that remote execution has finished.
- `Stageout files` lists the generated output files.
- `IN YUKI` indicates whether an output is available in the local Yuki environment.

A completed remote task does not necessarily mean that all output files have been downloaded locally.

If necessary, use:

```text
>>>> collect
```

to collect the task results.

For large ROOT files, retaining outputs on the remote runner can avoid unnecessary transfers to the local machine.

## 8. Visualize the Workflow

Celebi can generate a directed acyclic graph (DAG) to visualize task dependencies.

Run:

```text
>>>> draw-dag-graphviz
```

The graph shows the relationships between data objects and processing tasks.

![Example Celebi workflow DAG](https://github.com/user-attachments/assets/8528a658-381c-43e8-82e1-692ccbd70f72)

### Install Graphviz

If Graphviz is not installed, open the **WSL terminal** and run:

```bash
sudo apt update
sudo apt install graphviz
```

Graphviz is used to render the workflow graph.

## 9. Summary

A typical Celebi analysis follows this workflow:

```text
Local Computer (WSL / Yuki)
    |
    |-- Initialize project
    |-- Register remote data
    |-- Create analysis task
    |-- Write Python code
    |-- Configure environment and runner
    |
    v
Submit task through Celebi
    |
    v
Remote Server (pkufarm212)
    |
    |-- Access input data
    |-- Execute analysis code
    |-- Generate output files
    |-- Cache results
    |
    v
Inspect status and logs
    |
    v
Collect outputs when needed
```

The main advantage of this workflow is the separation between **local development** and **remote computation**. Analysis code can be developed and managed locally, while large datasets, intermediate files, and computationally intensive tasks remain on the remote server. This eliminates the need to store or manage large intermediate files locally, allowing users to focus on their analysis code.

How to preview intermediate results without downloading them will be covered in a later tutorial.
