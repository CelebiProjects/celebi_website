---
title: "Your first workflow"
weight: 1
summary: "Generate samples with a Gaussian distribution and fit them — the complete Gen → Fit example."
---

This guide walks through the canonical Celebi example: **generate some samples with a
Gaussian distribution and fit them** (see also
[demo-basic-01](https://celebi.readthedocs.io/en/latest/examples/demo-basic-01.html)).

## 0. Start a project

```sh
celebi init .            # in an empty directory
celebi use .             # in an existing Celebi project folder
celebi                   # enter the Celebi shell
celebi projects          # list projects;  celebi workon [name]  to switch
```

## 1. Construct the workflow

Each workflow node is a folder on disk. Create two algorithms and two tasks, then
link them:

```text
create-algorithm AlgGen
create-algorithm AlgFit
create-task Gen
create-task Fit

cd @/Gen    add-algorithm ../AlgGen
cd @/Fit    add-algorithm ../AlgFit
cd @/Fit    add-input ../Gen gen
```

`add-input ../Gen gen` makes the Gen task visible inside Fit as a sub-folder named
`gen` — that is the [alias system](/concepts/repository/) at work.

## 2. Write the code and configure

In the **algorithm**, write the command template with a parameter placeholder:

```yaml
# AlgGen/celebi.yaml
environment: script
commands:
  - root -l code/gen.C('${events}')
```

Write the actual code with your preferred editor:

```text
cd @/AlgGen
edit-script gen.C
```

In the **task**, set the environment and the parameters:

```text
cd @/Gen
set-environment env:root6
add-parameters events 1000
```

At run time the template is translated into `root -l code/gen.C('1000')`.

## 3. Develop interactively

Navigate to a task and run:

```text
workaround
```

You enter a shell inside a created folder: the task's algorithm is copied into
`code/`, and its dependencies are copied as aliases — it simulates the real running
environment, so you can debug exactly what will run.

## 4. Submit

```text
cd @/Fit
submit                 # or: submit [runner_name]
```

The [runner](/concepts/runner/) resolves the dependencies, runs Gen first, then Fit,
and the outputs come back through [Yuki](/concepts/yuki/). Running `submit` in a
directory executes it in all child nodes — one action submits the whole workflow.

## 5. Everyday operations

- **Copy sub-workflows** — `cp TasksGroup TaskGroupB` duplicates part of the workflow
  with connections automatically rewired. Very handy for systematic-uncertainty
  studies.
- **Rename / reorganize** — `mv` freely; the alias system keeps the underlying
  workflow intact.
- **Document** — every object has its own `README.md`, which never affects results
  (impressions don't seal it), so polish it any time.
