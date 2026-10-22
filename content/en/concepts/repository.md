---
title: "Repository"
weight: 2
summary: "An organized directory of objects, each carrying machine and human metadata."
---

The Celebi repository is an organized directory containing **objects** —
directory objects, algorithm objects, and task objects.

![Structure of a Celebi repository](/images/concepts/repository.png)

## Files shared by every object

- **`.celebi/config.json`** — machine-reading metadata. The workflow DAG itself is
  defined by the `predecessors` and `successors` recorded here.
- **`README.md`** — documentation of the object's purpose.

Task and algorithm objects additionally contain **`celebi.yaml`**, the editable
configuration for environments, parameters, and commands. Project and directory
objects do not require this file. A **directory** simply contains subobjects.

## Relocatable relationships — the alias system

Celebi records object relationships independently of their filesystem locations.
External data, linked sources, and runner settings may still use absolute paths.
Within the project, tasks see their predecessors as **aliases**: when a
dependency "changes" but doesn't *really* change — the task's name or location
changes — dependent tasks still see exactly the same thing. That is what makes
`mv`-style reorganization safe.
