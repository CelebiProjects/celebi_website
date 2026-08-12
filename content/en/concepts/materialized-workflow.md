---
title: "Materialized workflow"
weight: 3
summary: "Every workflow node is a real folder on disk — not an abstract step in a description file."
---

In traditional workflow languages, a workflow node is an abstract concept defined
inside a workflow description file. In Celebi, **each workflow node is a folder on
disk**, created with `create-task [name]` or `create-algorithm [name]`.

![Example workflow and nodes](/images/concepts/materialized.png)

- **Algorithm** — a reusable, self-contained piece of code or script; a template for
  tasks.
- **Task** — the proxy for a runnable component; contains parameters etc. Multiple
  tasks can share the same algorithm.

**Materialized** means: workflow nodes actually exist on disk, not only as conceptual
steps like in most workflow languages.

## Data–code binding

This design follows a key realization: *we do not need to treat data as a node in the
workflow* — all data has corresponding code that generates it. Inspired by Docker's
image/container duality, every task "contains" its data: the data produced by a node
is bound to the exact code and parameters that produced it, through
[impressions](/concepts/impression/).
