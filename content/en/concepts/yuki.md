---
title: "Yuki"
weight: 5
summary: "The middleware (DITE) that queues operations, dispatches jobs, and owns the data."
---

**Yuki** is the middleware of the Celebi system — the *Data Integration Thought
Entity* (DITE). Users only need to operate the repository; job submission is managed
by Yuki, which translates impressions into Snakemake workflows and distributes them
to [runners](/concepts/runner/) (currently mainly REANA).

![Yuki middleware and workflow runners](/images/concepts/yuki.png)

## Why a middleware?

Without it, the repository would talk to remote runner servers directly — which can be
very slow. Yuki **queues multiple operations** (submit jobs, query status, …) at the
same time, so remote execution never blocks your development. Repository and Yuki
communicate via HTTP, so Yuki should have a good connection to your local repository.

## Data storage

Results are **stored in Yuki** — the repository does not see them directly. Data is
owned and managed by the middleware, and the repository refers to samples by their
impression UUID, which is determined by the project, the previous node, and this
node — so a data sample can never mismatch the code.
