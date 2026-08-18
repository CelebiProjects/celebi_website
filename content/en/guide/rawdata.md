---
title: "Start a workflow with raw data"
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
In the beginning, make a new folder that will contain our project.
```text
>>>> mkdir . B02K3pi
>>>> cd B02K3pi
>>>> celebi init
```
Then this new folder becomes our analysis project.

## 1. Bring in the data
There are four ways to bring data into a project. Choose by where the data
currently lives:

| Data is currently... | Command |
|---|---|
| a file on your machine that belongs to one task | `create-data` + `import` |
| a directory on your machine | `upload-data` |
| an impression already on DITE | `attach-data` |
| a directory on an SSH runner | `create-data ` + `register-ssh-data` |

### 1. `create-data` + `import` — files inside a task

`create-data` makes an empty raw-data task; `import` copies local files into
it. The files travel with the task when it is submitted, so this is for small
per-task files (configurations, small tables), not for large datasets.

```text
>>>> create-data MyData
>>>> cd @/MyData
>>>> import /path/to/file.txt
```

### 2. `upload-data` — local directory to DITE

`upload-data` (previously `send`) uploads a local directory to the DITE
server with a progress bar. The MD5 is computed, the data is stored in Yuki
storage, and an impression is registered — after that the local task is just
a pointer to it.

```text
>>>> upload-data /data/lhcb/samples
The md5 of the dir is: 779f83aa862dd6fb4a32989718d70bdd
```

### 3. `attach-data` — adopt an impression already on DITE

`attach-data` (previously `use-data`) turns an impression that already lives
on DITE — created by another project or by `yuki-create-data` — into a local
data task. **No data is transferred**; the local task is a pointer, and the
UUID is filled from the server's metadata.

```text
>>>> attach-data 17d47e297f50cbeed12b821fde672ea9
```

If you run it inside an existing raw-data task, that task's UUID/descriptor
are updated instead of creating a new task.

### 4. `register-ssh-data` — data already on an SSH runner

When the data already sits on a compute farm, do not pull it to your laptop
and upload it again. `register-ssh-data` computes the MD5 **on the runner**
and copies the data into Yuki's managed impressions area **on that runner**
— the data never crosses your network. The command shows a live byte
progress bar for the hash and **returns as soon as the hash is computed**;
the copy continues as a background job on Yuki.

```text
>>>> create-data TestData
>>>> cd TestData
>>>> register-ssh-data pkufarm212 /home/user/workdir/TestData --descriptor MyData
register-ssh-data: job 37013596... started on 'pkufarm212'
register-ssh-data: hashing  4.2G/4.2G [██████████] 100% 00:25
Registered: md5=779f83aa862dd6fb4a32989718d70bdd impression=17d47e297f50cbeed12b821fde672ea9 — copying in background
Updated rawdata task at MyData (register-ssh-data) with new impression data
```

Registration has two phases: the hash (MD5 + impression synthesis) runs
while the command waits, then the copy is dispatched as a separate
background task (hashing → copying → done). Check the copy's progress with
`status`:

```text
>>>> status
...
Data registration: copying — 1.2GiB/4.2GiB
```

Once the copy finishes (or fails), `status` shows
`Data registration: archived` or `failed — <error>`. Re-registering the
same path **always re-hashes**: if the content is unchanged the existing
registration is reused (the command returns right after the hash); if it
changed, a new impression is created and the managed copy refreshed.
The data task's default runner is set
to the runner that hosts the data.

## 2. Connect Data, Algorithm and Task

We need an algorithm and a corresponding task to process the data. First,
create a new algorithm in the project file:

```text
>>>> create-algorithm filter0
```

Create a filter0.py program in filter0 and edit the yaml file in filter0:

```yaml
environment: script
commands:
  - python3 code/filter0.py
```

Notice that a '-' and a space should be in front of your command. We'll
explain the 'code' later.

Create a task that will execute the workflow in the project file:

```text
>>>> create-task filter0_task
```

Add the corresponding algorithm and input data:

```text
>>>> cd filter0_task
>>>> add-algorithm ../filter0
>>>> add-input ../TestData raw_data
```

The name of the input data ("raw_data" here) is arbitrary since different
data can be added to the same task. After we run the workflow, the algorithm, 
data and task will be stored as 'impression' in different folders in the 
repository. Impression of the algorithm only contains the python file. Impression
of the data contains the raw data (in stageout folder) and logs (empty, in logs folder). 
However, impression of the task contains:

1. code folder: contains all the programs.
2. logs folder: contains the logs of execution.
3. data folder: Its name is what you name the input data (raw_data here) and it is the same as the impression of the raw data.
4. stageout folder: contains output files.

Therefore, the task can run the program in the code folder (That's why we write code/filter0.py before) and use the data in raw_data/stageout. 
When we write the program, make sure the input folder is **raw_data/stageout**, and the output folder is **stageout**.

We can use **ls** in the task folder to see the workflow we just built:

```text
>>>> ls
>>>> DITE: [connected]
README: 
Please write README for task filter0_task
o--> Predecessors:
[0] (algorithm)  code    : @/filter0
[1] (task)       raw_data: @/TestData
Environment: env_root_6.38.04
Memory limit: 256Mi
Validated: True
Cache on runner: True
Default runner: pkufarm212
---- Algorithm files:
code:filter0.py    
---- Commands:
python3 code/filter0.py
```

## 3. Run the Workflow
To set the appropriate environment, see what environment you have on the server:

```text
>>>> runner-envs pkufarm212
Conda environments on 'pkufarm212' (3):
  base                          /home/zouqt/miniconda3
  env_root_6.38.04              /home/zouqt/miniconda3/envs/env_root_6.38.04
  snakemake                     /home/zouqt/miniconda3/envs/snakemake
```

Then copy 'env_root_6.38.04' to the yaml file of the task.
If "Cache on runner" is False, run:

```text
>>>> cache-on-runner on
```

If there's no runner, run:
```text
>>>> request-runner pkufarm212
```

Finally, when everything's ready, run:
```text
>>>> submit --runner pkufarm212
```

and the task is run by the server. Use "Status" to see the status:

```text
>>>> status
Status of : filter0_task
Impression: [ec21fbb7ef0ec6888175eae7302b55d5]
DITE: [connected]
Job status: [in movement][running]
Details: Executing workflow steps
**** Workflow: 
Workflow: [pkufarm212][84b43f1adf8c4b80bdc1f3af043b7411]
Stageout files:
    (nothing to show yet — run 'collect', or the runner may be unreachable)
```

## Appendix

### 1.
How the data reaches the workflow depends on the runner:

- **SSH runner**: the data is staged from the runner's local impressions
  cache. Raw-data inputs are cached automatically — the first workflow
  uploads the data (or copies it from its managed area) and writes it into
  `[remote-workdir]/impressions/<project>/<impression>/`; every later
  workflow on the same runner copies it locally, with no network transfer.
- **REANA runner**: with `cache_on_runner` on, data flows through EOS.
- Data registered with `register-ssh-data` is bound to its runner: submitting
  a workflow that needs it to a different runner is rejected with a clear
  error (moving such data via `collect` is planned).

### 2. `cache_on_runner` — where results are cached

Every task has a `cache_on_runner` option (in the shell: `cache_on_runner on|off`).
Its effect depends on the runner type:

| Runner type | `cache_on_runner` on |
|---|---|
| REANA | results are copied to EOS (the runner's `eos_mount_point`) |
| SSH | results are copied to the runner's managed impressions area |
| native / dry | no effect (outputs already land in Yuki storage) |

### 3. `verify-data` — check the data integrity

`verify-data` recomputes the MD5 and compares it with the registered UUID.
For data hosted on an SSH runner the MD5 is recomputed on the runner; for
data in Yuki storage it is recomputed locally.

```text
>>>> verify-data
Data verified: md5 matches (779f83aa862dd6fb4a32989718d70bdd) on runner pkufarm212
```

A mismatch means the data changed on disk and is reported with both values.

### 4. Status and visibility

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

### 5. Working with SSH runners

Two commands help you inspect an SSH runner before using it:

- `test-runner <runner>` — probes connectivity, snakemake, conda and the
  remote working directory, and stores the result (shown by `runners`).
- `runner-envs <runner>` — lists the conda environments available on the
  runner.

See [Runner](/concepts/runner/) for registering and configuring runners
(including SSH keys, which are uploaded automatically by `register-runner`).
