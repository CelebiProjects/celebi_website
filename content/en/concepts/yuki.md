---
title: "Yuki"
weight: 5
summary: "The middleware (DITE) that queues operations, dispatches jobs, and owns the data."
---

**Yuki** is the middleware of the Celebi system — the *Data Integration Thought
Entity* (DITE). Users only need to operate the repository; job submission is managed
by Yuki, which translates impressions into workflows and distributes them to
[runners](/concepts/runner/) using REANA, native, SSH, or IHEP backends.

![Yuki middleware and workflow runners](/images/concepts/yuki.png)

## Why a middleware?

Without it, the repository would talk to remote runner servers directly — which can be
very slow. Yuki **queues multiple operations** (submit jobs, query status, …) at the
same time, so remote execution never blocks your development. Repository and Yuki
communicate via HTTP, so Yuki should have a good connection to your local repository.

## Data storage

Yuki tracks where every result is available. Collected results live in Yuki Storage;
SSH and IHEP outputs may instead remain in a runner cache or workflow workspace until
they are collected or transferred. Native stage-out enters Yuki Storage directly.
The repository refers to results by impression UUID, preserving the relationship
between code, parameters, inputs, and output data.
