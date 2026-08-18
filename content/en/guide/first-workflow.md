---
title: "Your first workflow"
weight: 1
summary: "Generate samples with a Gaussian distribution and fit them — the complete Gen → Fit example."
---

This guide walks through the canonical Celebi example: **generate some samples with a
Gaussian distribution and fit them** (see also
[demo-basic-01](https://celebi.readthedocs.io/en/latest/examples/demo-basic-01.html)).

## 1. Clone the repository

```sh
git clone https://github.com/CelebiProjects/demo-basic-01.git
cd demo-basic-01
```

This command downloads an existing Celebi repository from GitHub. You can clone it to any location where you would like to keep your Celebi projects.

## 2. The Celebi environment

```sh
cd demo-basic-01 # (if you have not already done so)
celebi use .
```

The command `celebi use .` registers the `demo-basic-01` project with Celebi. Once registered, the project becomes one of the projects managed by the Celebi system.

You can run:

```sh
celebi projects
```

to see all projects currently managed by Celebi.

You can also use:

```sh
celebi workon [project_name]
```

to switch your current working project.

After you select a project with `celebi workon`, running `celebi` commands will operate within the Celebi environment and the currently selected project.

## 3. Understand the structure

When you enter the celebi, type the `ls` you will see the structure of this repository like
```bash
>>>> ls
>>>> DITE: [connected]
README:
(readme contents ... )
>>>> Subobjects:
[0] (algorithm)   Fit
[1] (algorithm)   Gen
[2] (task)        FitTask
[3] (task)        GenTask
```

On the disk the folder is like:
```bash
.
├── .celebi
│   ├── config.json
│   └── project.json
├── Fit
│   ├── .celebi
│   │   └── config.json
│   ├── celebi.yaml
│   ├── fitdata.C
│   └── README.md
├── FitTask
│   ├── .celebi
│   │   └── config.json
│   ├── celebi.yaml
│   └── README.md
├── Gen
│   ├── .celebi
│   │   └── config.json
│   ├── celebi.yaml
│   ├── gendata.C
│   └── README.md
├── GenTask
│   ├── .celebi
│   │   └── config.json
│   ├── celebi.yaml
│   └── README.md
└── README.md
```
Let use explain the `tasks` and `algorithms` first.
If you open the `Gen/gendata.C`, you will see a ROOT script, shorten like:
```cpp
#ifndef __CINT__
(some include ... )
#include "RooPlot.h"
using namespace RooFit ;

void gendata(int numevents, const char* outfilename)
{
  (some logic ... )
  RooDataSet *data = model.generate(x, numevents) ;
  (some logic ... )
  w->writeToFile(outfilename) ;
  // Workspace will remain in memory after macro finishes
  gDirectory->Add(w) ;
}
```
This is the code that you will run later. As you can see, the script accepts two parameters: `numevents` and `outfilename`. We will see how these parameters are passed to the script later.

Open `Gen/celebi.yaml`. You will see:

```yaml
environment: script
commands:
  - root -b -q 'code/gendata.C(${events},"stageout/data.root")'
```

This configuration contains two fields:

* **`environment: script`**
  This specifies that the algorithm is a script-based algorithm. Script-based algorithms are compatible with tasks regardless of the task's execution environment. In most cases, you can simply set the environment of an algorithm to `script` using the `set-environment script` command.

* **`commands`**
  This specifies the command that will be executed by the task. Here, we run a ROOT command to execute `gendata.C`.

  Notice that the script is specified as `code/gendata.C` rather than simply `gendata.C`. This is because, inside a task, the algorithm's files are made available under the `code` directory. We will explain this structure in more detail later.

  You can also see `${events}` in the command. This is a parameter that will be provided by the task and substituted when the command is executed. We will explain how parameters are passed to tasks later.

Then let us see the task `GenTask`, if you open `GenTask/celebi.yaml` you will see
```yaml
alias: []
environment: rootproject/root:6.32.02-ubuntu22.04
memory_limit: 256Mi
parameters:
  events: '20000'
```
Here you see the four fields:

* **`environment`**
  The environment specified here is `rootproject/root:6.32.02-ubuntu22.04`. This is a Docker image maintained by the ROOT team and available on Docker Hub: [https://hub.docker.com/r/rootproject/root](https://hub.docker.com/r/rootproject/root).

* **`parameters`**
  The `parameters` section defines the parameters used by this task. For example:

  ```yaml
  events: '20000'
  ```

  This parameter corresponds to `${events}` in the `commands` field of the corresponding algorithm. When the task is executed, Celebi uses the command defined by the algorithm and replaces `${events}` with the value provided here, passing the parameter to the command.

* **`memory_limit`**
  This specifies the amount of memory requested by the task.

* **`alias`**
  This defines a human-readable alias for the task, which can be used to identify or refer to the task more conveniently.


Usually, users do not need to read or modify the hidden files, such as `.celebi/*`. These files are managed automatically by the Celebi system. However, it is still useful to understand their purpose, so we will briefly explain them below.


The [runner](/concepts/runner/) resolves the dependencies, runs Gen first, then Fit,
and the outputs come back through [Yuki](/concepts/yuki/). Running `submit` in a
directory executes it in all child nodes — one action submits the whole workflow.

## 5. Everyday operations

- **Copy sub-workflows** — `cp TasksGroup TaskGroupB` duplicates part of the workflow
  with connections automatically rewired. Very handy for systematic-uncertainty
  studies.
- **Rename / reorganize** — `mv` freely; the alias system keeps the underlying
  workflow intact.
- **Document** — every object has its own `README.md`, which never affects results
  (impressions don't seal it), so polish it any time.
