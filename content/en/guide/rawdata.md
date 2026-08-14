---
title: "Working with raw data"
weight: 2
summary: "Bring data into Celebi — locally, from DITE, or straight from an SSH runner — and manage it by MD5."
---

Raw data in Celebi lives in **data tasks**: ordinary task folders whose
`celebi.yaml` carries `environment: rawdata` together with a `uuid`. The UUID
is the **MD5 of the data content** — the same data always yields the same
UUID, no matter where it was registered. Data tasks do not execute; they are
containers that downstream analysis tasks reference as inputs.

```yaml
environment: rawdata
uuid: 779f83aa862dd6fb4a32989718d70bdd
descriptor: MyData
```

There are four ways to bring data into a project. Choose by where the data
currently lives:

| Data is currently... | Command |
|---|---|
| a file on your machine that belongs to one task | `create-data` + `import` |
| a directory on your machine | `upload-data` |
| an impression already on DITE | `attach-data` |
| a directory on an SSH runner | `register-data` |

## 1. `create-data` + `import` — files inside a task

`create-data` makes an empty raw-data task; `import` copies local files into
it. The files travel with the task when it is submitted, so this is for small
per-task files (configurations, small tables), not for large datasets.

```text
>>>> create-data MyData
>>>> cd @/MyData
>>>> import /path/to/file.txt
```

## 2. `upload-data` — local directory to DITE

`upload-data` (previously `send`) uploads a local directory to the DITE
server with a progress bar. The MD5 is computed, the data is stored in Yuki
storage, and an impression is registered — after that the local task is just
a pointer to it.

```text
>>>> upload-data /data/lhcb/samples
The md5 of the dir is: 779f83aa862dd6fb4a32989718d70bdd
```

## 3. `attach-data` — adopt an impression already on DITE

`attach-data` (previously `use-data`) turns an impression that already lives
on DITE — created by another project or by `yuki-create-data` — into a local
data task. **No data is transferred**; the local task is a pointer, and the
UUID is filled from the server's metadata.

```text
>>>> attach-data 17d47e297f50cbeed12b821fde672ea9
```

If you run it inside an existing raw-data task, that task's UUID/descriptor
are updated instead of creating a new task.

## 4. `register-data` — data already on an SSH runner

When the data already sits on a compute farm, do not pull it to your laptop
and upload it again. `register-data` computes the MD5 **on the runner** and
copies the data into Yuki's managed impressions area **on that runner** —
the data never crosses your network.

```text
>>>> register-data pkufarm212 /home/user/workdir/TestData --descriptor MyData
register-data: job 37013596... started on 'pkufarm212'
register-data: hashing...
register-data: copying...
Registered: md5=779f83aa862dd6fb4a32989718d70bdd impression=17d47e297f50cbeed12b821fde672ea9
Updated rawdata task at MyData (register-data) with new impression data
```

The registration runs as a background job on Yuki (hashing → copying →
registering). Re-registering the same path is idempotent: the existing
registration is returned instantly. The data task's default runner is set
to the runner that hosts the data.

## 5. Using data downstream

Add the data task as an input of an analysis task and submit:

```text
>>>> cd @/FitTask
>>>> add-input ../MyData
>>>> submit pkufarm212
```

How the data reaches the workflow depends on the runner:

- **SSH runner**: the data is staged from the runner's local impressions
  cache. Raw-data inputs are cached automatically — the first workflow
  uploads the data (or copies it from its managed area) and writes it into
  `[remote-workdir]/impressions/<project>/<impression>/`; every later
  workflow on the same runner copies it locally, with no network transfer.
- **REANA runner**: with `cache_on_runner` on, data flows through EOS.
- Data registered with `register-data` is bound to its runner: submitting
  a workflow that needs it to a different runner is rejected with a clear
  error (moving such data via `collect` is planned).

## 6. `cache_on_runner` — where results are cached

Every task has a `cache_on_runner` option (in the shell: `cache_on_runner on|off`).
Its effect depends on the runner type:

| Runner type | `cache_on_runner` on |
|---|---|
| REANA | results are copied to EOS (the runner's `eos_mount_point`) |
| SSH | results are copied to the runner's managed impressions area |
| native / dry | no effect (outputs already land in Yuki storage) |

## 7. `verify-data` — check the data integrity

`verify-data` recomputes the MD5 and compares it with the registered UUID.
For data hosted on an SSH runner the MD5 is recomputed on the runner; for
data in Yuki storage it is recomputed locally.

```text
>>>> verify-data
Data verified: md5 matches (779f83aa862dd6fb4a32989718d70bdd) on runner pkufarm212
```

A mismatch means the data changed on disk and is reported with both values.

## 8. Status and visibility

A data task's status reflects the lifecycle of its registration: `running`
while the copy is in flight, `archived` once it has settled. The `status`
command shows the same file table as analysis tasks — name, size, type, and
whether the file is already in local (Yuki) storage:

```text
>>>> status
Job status: [coda][archived]
Stageout files:
    NAME                            SIZE  TYPE   IN YUKI
    111.txt                           5 B  data   ✗
```

## 9. Working with SSH runners

Two commands help you inspect an SSH runner before using it:

- `test-runner <runner>` — probes connectivity, snakemake, conda and the
  remote working directory, and stores the result (shown by `runners`).
- `runner-envs <runner>` — lists the conda environments available on the
  runner.

See [Runner](/concepts/runner/) for registering and configuring runners
(including SSH keys, which are uploaded automatically by `register-runner`).
