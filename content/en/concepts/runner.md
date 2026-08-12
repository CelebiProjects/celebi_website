---
title: "Runner"
weight: 6
summary: "REANA, local, or ssh — interchangeable backends that execute impressions."
---

The repository holds code and impressions — so why bother with an external runner?
Because impressions should run **flexibly**: part of the work on your PC, part on
HTCondor, and so on. And a running workflow should never block your development.

![How a runner executes a node](/images/concepts/runner.png)

## Three types of runner

- **REANA runner** — the most robust one; runs in containerized environments.
- **Local runner** — runs things on the machine that Yuki runs on.
- **ssh runner** — jobs are submitted to an ssh machine.

The latter two offer less reproducibility than containerized REANA execution.

## How a runner works

1. Resolve the dependencies.
2. Copy the predecessors (code, plus the `stageout` folders of preceding nodes).
3. Run the command in the requested environment.
4. Retrieve the outputs (via [Yuki](/concepts/yuki/)).

Multiple tasks can be submitted with one action — e.g. running `submit` in a folder
executes it in all child nodes.
