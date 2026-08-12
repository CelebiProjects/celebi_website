---
title: "Repository"
weight: 2
summary: "An organized directory of objects, each carrying machine and human metadata."
---

The Celebi repository is an organized directory containing **objects** —
directory objects, algorithm objects, and task objects.

![Structure of a Celebi repository](/images/concepts/repository.png)

## Every object MUST contain

- **`.celebi/config.json`** — machine-reading metadata. The workflow DAG itself is
  defined by the `predecessors` and `successors` recorded here.
- **`celebi.yaml`** — human-reading metadata (environment, parameters, commands).
- **`README.md`** — documentation of the object's purpose.

A **directory** simply contains subobjects.

## No absolute paths — the alias system

To ensure the repository could run anywhere, it contains **no absolute paths**. And to
keep it freely re-organizable, tasks see their predecessors as **aliases**: when a
dependency "changes" but doesn't *really* change — the task's name or location
changes — dependent tasks still see exactly the same thing. That is what makes
`mv`-style reorganization safe.
