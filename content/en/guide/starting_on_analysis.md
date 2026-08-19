---
title: "Starting an analysis"
summary: "Start an analysis using Celebi with data on the server and code on your local machine."
---

This file demonstrates how to start an analysis using Celebi. In this example, all data is stored on the server, but the code resides on our local computer.

## Prerequisite: Start Yuki

First, run the following command in WSL to start Yuki:

```WSL
❯ yuki docker run yuki:dev --dev-dir ~/Yuki --celebi-dir ~/Celebi
```
Then run `celebi`
to start our software. Type `Ctrl+D` when you want to exit.

## Initialize the Project

Create a new folder in your workdir to contain the project:
```celebi
>>>> mkdir B02K3pi
>>>> cd B02K3pi
>>>> celebi init
```
This new folder becomes your analysis project.

## 1. Bring in Raw Data
Raw data on the server should be linked to the analysis system on your local computer. 
Use the following commands to build the data file, which connects to the data on the server:
```celebi
>>>> create-data Raw
>>>> cd Raw
>>>> register-data pkufarm212 /home/user/workdir/TestData
```
## 2. Connect Data, Algorithm and Task

We need an algorithm and a corresponding task to process the data. First,
### Create an algorithm
Create a new algorithm in the project folder:
```celebi
>>>> create-algorithm filter0
```
Create a `filter0.py` program inside the `filter0` directory and edit the YAML file in `filter0`:
```yaml
environment: script
commands:
  - python3 code/filter0.py
```
`Commands`: These are the commands that will be 
executed when running the workflow. Note that a dash (`-`) followed by a space must precede each command.
The code folder will be explained later.
### Create a task
Create a task that will execute the workflow:

```celebi
>>>> create-task filter0_task
```

Add the corresponding algorithm and input data:

```celebi
>>>> cd filter0_task
>>>> add-algorithm ../filter0
>>>> add-input ../Raw raw_data
```

The name of the input data ("raw_data" here) is arbitrary since different
data can be added to the same task. 

### Understanding Impressions

After running the workflow, the algorithm, data, and task will be stored as **impressions** in different folders in the repository on the server:

1. **Algorithm impression**: Contains only the Python file.
2. **Data impression**: Contains the raw data (in the `stageout` folder) and empty logs (in the `logs` folder).
3. **Task impression**: Contains the following:
   - `code/` folder — contains all the programs.
   - `logs/` folder — contains the execution logs.
   - `data/` folder — named after your input data (e.g., `raw_data`), linking to the data impression.
   - `stageout/` folder — contains output files.

Therefore, the task can run the program in the `code/ folder` (hence `code/filter0.py` in the command) 
and use data from `raw_data/stageout`. When writing the program, ensure:
- The input folder is `raw_data/stageout`
- The output folder is `stageout`

### View the Workflow
Use ``ls`` in the task folder to see the workflow you just built:
```celebi
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
### Set the Environment
Check what environments are available on the server:
```celebi
>>>> runner-envs pkufarm212
Conda environments on 'pkufarm212' (3):
  base                          /home/zouqt/miniconda3
  env_root_6.38.04              /home/zouqt/miniconda3/envs/env_root_6.38.04
  snakemake                     /home/zouqt/miniconda3/envs/snakemake
```

Copy `env_root_6.38.04` to the YAML file of the task.
### Configure the Runner
If "Cache on runner" is `False`, enable it:

```celebi
>>>> cache-on-runner on
```
If there is no runner configured, request one:
```celebi
>>>> request-runner pkufarm212
```
### Submit the Job
When everything is ready, submit the task:
```celebi
>>>> submit --runner pkufarm212
```
The task will be executed by the server.
### Check Job Status
Use the `status` command to monitor the job:
```celebi
>>>> status
Status of : filter0_task
Impression: [9017b6082037087e287fa89b76caca7b]
DITE: [connected]
Job status: [in movement][running]
Details: Executing workflow steps
**** Workflow: 
Workflow: [pkufarm212][494f0f6c61b34204b2e8910404c772e9]
Stageout files:
    (nothing to show yet — run 'collect', or the runner may be unreachable)
```
When the job is finished, the status will show:
```celebi
>>>> status
Status of : filter0_task
Impression: [9017b6082037087e287fa89b76caca7b]
DITE: [connected]
Job status: [coda][finished]
Details: Remote execution completed
**** Workflow: 
Workflow: [pkufarm212][494f0f6c61b34204b2e8910404c772e9]
Stageout files:
    NAME                              SIZE  TYPE   IN YUKI
    24r1_down_cut0.root           758.7 MB  data   ✗
    24r1_up_cut0.root               1.2 GB  data   ✗
    25c1_down_cut0.root           135.6 MB  data   ✗
    25c1_up_cut0.root             555.9 MB  data   ✗
    25c2_down_cut0.root             1.3 GB  data   ✗
    25c3_up_cut0.root             867.2 MB  data   ✗
    25c4_down_cut0.root           328.7 MB  data   ✗
    25c4_up_cut0.root             442.7 MB  data   ✗
```

To review the execution logs, navigate to the log file at:
```text
/home/zouqt/workdir/celebi_ssh_runner/workflows/5668ba0decc3482a897e8f4e0e8566ba/494f0f6c61b34204b2e8910404c772e9/imp9017b60/logs/celebi_user_step0.log
```
Note: The `imp9017b60` segment in the path represents the task impression, which is nested within the workflow impression `494f0f6c61b34204b2e8910404c772e9`.
### Visualize the Workflow
Run the following command to generate a sketch of the workflow:
```WSL
>>>> draw-dag-graphviz
```
[dag.pdf](https://github.com/user-attachments/files/31177657/dag.pdf)

Note: If you don't have Graphviz installed, install it in WSL using:
```celebi
sudo apt update && sudo apt install graphviz
```
