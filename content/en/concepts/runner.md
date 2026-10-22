---
title: "Runner"
weight: 6
summary: "REANA, native, SSH, and IHEP backends that execute impressions."
---

The repository holds code and impressions — so why bother with an external runner?
Because impressions should run **flexibly**: part of the work on your PC, part on
HTCondor, and so on. And a running workflow should never block your development.

![How a runner executes a node](/images/concepts/runner.png)

## Runner backends

- **REANA** — executes containerized workflows on a REANA cluster.
- **native** — a host agent executes Snakemake and Conda workflows on the machine
  that shares Yuki's storage directory.
- **SSH** — stages and executes workflows on a remote SSH host.
- **IHEP** — stages through SSH and submits jobs through `hep_sub` on IHEP clusters.

See [Runners and environments](/guide/runners-and-environments/) for registration,
project environments, and backend-specific requirements.

## How a runner works

1. Resolve the dependencies.
2. Copy the predecessors (code, plus the `stageout` folders of preceding nodes).
3. Run the command in the requested environment.
4. Retrieve the outputs (via [Yuki](/concepts/yuki/)).

Multiple tasks can be submitted with one action — e.g. running `submit` in a folder
executes it in all child nodes.
