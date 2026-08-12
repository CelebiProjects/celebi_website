---
title: "Impression"
weight: 4
summary: "Immutable, content-defined snapshots of every workflow node."
---

An **impression** is an **immutable snapshot** of a task or an algorithm. It is
**uniquely defined** by:

- the project UUID,
- all preceding impressions,
- the contents of the corresponding task or algorithm.

![The impression system records the project's history](/images/concepts/impression.png)

From the perspective of an impression, it is an isolated component that only sees its
connected objects:

```text
imp8c340c/
├── contents/     # the contents of itself
├── code -> ...   # symlink to the impression of the algorithm
├── inputname -> ...  # symlink to the impression of the input task
└── stageout/     # empty folder to store outputs
```

The impression system records the **entire history of the project** through these
connections.

## Properties

- **Version the data without versioning the data** — instead of storing datasets,
  an impression records the exact execution provenance: code hash, inputs, and
  parameter states.
- **Immutable once created** — so the results it produces are feasible and reliable.
- **README.md is not included** — only files that can change results are sealed, so
  after running your job you are free to polish the documentation.

```sh
celebi-cli make-impression "preselection v1"
```
