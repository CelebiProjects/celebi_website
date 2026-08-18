---
title: "Task and algorithm states"
weight: 2
summary: "The local new/impressed states, and the musically-named job status system on DITE after submission."
---

In Celebi, every object's status lives on **two levels**: the **local status** on
disk (determined by the impression system), and the **remote job status** on DITE
(Yuki) after submission.

## Local status: new vs impressed

Tasks and algorithms have only two local states:

| State | Meaning |
|---|---|
| `new` | No impression yet, or the contents changed since the last impression |
| `impressed` | The current contents are fully recorded by an impression |

Impressions are **content-defined**: an impression is uniquely determined by the
project UUID, all preceding impressions, and the object's contents. Therefore:

- Touch anything that can change results (code, `celebi.yaml`, parameters) and the
  object falls back to `new`;
- Editing `README.md` does **not** change the status — impressions never include it;
- If any **predecessor** is `new`, you are `new` too — status propagates downstream
  along the dependency graph, so an upstream change brings every affected
  downstream object back to `new`.

### How to check

Enter an object in the Celebi shell and run `status`:

```text
>>>> status
Status of : /FitTask
Impression: [imp3f2a1c]
DITE: [connected]
...
```

Without an impression it shows:

```text
Impression: [new]
```

You can also use `ls --status` to see the status tag of every subobject in a list.

The `Impression: [imp...]` line shows the first characters of the object's
**current** impression UUID — the handle used for submission and job-status queries.

## Remote status: job status on DITE

When a task is impressed, its impression is **deposited into DITE**. If it is not
deposited yet, `status` says:

```text
Impression not deposited in DITE
```

Run `impress` to seal and upload it. When you then `submit`, DITE creates a **job**
for this impression, and its status evolves as the runner executes it.

### Status names: coarse phase and fine status

Yuki's job statuses come as a pair, displayed by the client as `[coarse][fine]`:

- the first bracket is the **musically-named coarse status** — the rough phase the
  job is in;
- the second bracket is the **fine status** — the precise state within that phase.

In practice, statuses come from two paths:

**Construction phase** — before Yuki hands the workflow to a backend, it writes
musical names directly as the coarse status:

| Coarse | Fine (display) | When it appears |
|---|---|---|
| `silence` | `raw` | Initial state; or reset back to initial when dependencies are unfinished |
| `prelude` | `waiting` | Job queued for execution; workflow being constructed (1/3 → 3/3) |
| `tuning` | `ready` | Algorithm job ready for configuration — preparing algorithm components, parameters and dependencies (algorithm jobs only) |
| `orchestrating` | `built` | Talking to the backend: create workflow, upload dependencies, start (REANA) |
| `dissonance` | `failed` | Workflow **construction** failed — never actually started executing |

`tuning` is used for algorithm jobs only: their fine status shows as `ready`,
meaning the algorithm components are prepared and awaiting configuration.

**Before any job exists on DITE** — status queries also return two special states:

| State | Meaning |
|---|---|
| `empty` | No job record exists on DITE for this impression (the job object type is empty) — usually means it has never been submitted |
| `deposited` | The data has been deposited to DITE ("Data has been deposited"), but the job status is unknown — it has not entered real execution yet |

**Execution phase** — once the job runs, the backend (REANA / native / ssh)
reports fine statuses, which are stored as-is and translated to the coarse
status for display:

| Fine (reported by backend) | Coarse (display) | Meaning |
|---|---|---|
| `created` / `queued` / `pending` / `running` | `in movement` | Backend is executing (or queued to execute) |
| `finished` | `coda` | All steps completed successfully |
| `failed` | `failed` | Backend execution failed |
| `stopped` / `deleted` | `stopped` / `deleted` | Stopped or removed (from the backend) |

The distinction between `dissonance` and `failed` matters: the former means the
**workflow could not be assembled** (missing dependencies, Snakefile generation
failed, …) and the job never actually ran; the latter means it **ran and failed**.

**Note**: the constants also define statuses such as `composing` and
`final note`, but no current code path actually uses them (`composing` only
appears as the display translation of REANA's `created`). `in movement` and
`coda` are likewise never stored: finished jobs store `finished`, running jobs
store `running` etc., and `[in movement]` / `[coda]` are the coarse brackets
translated from those fine statuses for display.

The client folds close fine statuses together:

- `created / queued / pending / running` all show as `[in movement]`;
- `finished` shows as `[coda]`;
- the fine bracket of `prelude / orchestrating` shows as `[undecided]`.

A successfully finished workflow therefore shows `[coda][finished]` — coarse
`coda` (successful conclusion) with fine status `finished` — plus a
`Details: ...` line with the detailed status (current step, error reasons, …).

### Aggregated status of directories and projects

Running `status` on a **directory or project** aggregates all subobjects:

- any subtask failed → the aggregate is `failed`;
- otherwise, any subtask not finished → `pending`;
- all finished → `finished`.

Algorithms are skipped in the aggregation (they do not execute themselves). So a
single `status` at the project root surveys the whole workflow's progress.

## What is special about algorithm states

- **Algorithms never run by themselves** — tasks are the executable units. An
  algorithm only has the local `new` / `impressed` states, plus whether it has been
  used by some submission.
- At execution time, an algorithm is referenced by its impression (the `code -> ...`
  symlink inside the task), so algorithm changes propagate automatically to every
  task using it: change the algorithm and the related tasks all fall back to `new`
  and need re-impressing and re-submitting.
- Running `status` on an algorithm whose impression has no workflow definition
  shows:

  ```text
  Workflow not defined
  ```

  which usually means no task has submitted a job with it yet.
