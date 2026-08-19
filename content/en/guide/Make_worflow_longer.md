---
title: "Making Workflows Longer"
weight: 2
summary: "Extend your analysis pipeline by chaining multiple tasks — add a second filter and pass data between tasks."
---
This guide walks you through extending an existing CELEBI workflow by adding a new filter step (`filter1`) 
and a merge step, creating a longer processing chain.

## 1. Create a New Filter Algorithm

Start by creating a second filter algorithm (filter1) in our project folder:
```celebi
create-algorithm filter1
```
This creates a new algorithm directory. You will need to implement the filtering logic in `filter1.py` 
and the settings in `YAML` file (just like `filter0.py`).

## 2. Create and Configure the Filter1 Task

Create a task for `filter1` and link it to the algorithm:
```celebi
create-task filter1_task
cd filter1_task
add-algorithm ../filter1
```
Now set up the input:
```celebi
add-input ../filter0_task/ data_filter0
```
This means  `filter1_task` takes its input from the output of `filter0_task` and we name the input `data_filter0`. 
Therefore, the input folder for `filter1.py` becomes `data_filter0` and the output folder is still `stageout`.
Then configure the runner settings:
```celebi
cache-on-runner on
request-runner pkufarm212
```
Verify the configuration with `ls`. You should see:
```celebi
o--> Predecessors:
[0] (algorithm)  code        : @/filter1
[1] (task)       data_filter0: @/filter0_task
Environment: env_root_6.38.04
Cache on runner: True
Default runner: pkufarm212
```

## 3. Submit and Monitor the Filter1 Task
Submit the task to the remote runner:
```celebi
submit --runner pkufarm212
```

Use `draw-dag-graphviz` to visualize the workflow:

<img width="2057" height="972" alt="2f69105f1c075f98307256be9d0c37a6" src="https://github.com/user-attachments/assets/dc7fdfab-e193-4a82-8fdb-8cf48df0a176" />

This way, you can create workflows as long as you need. 
Note that impressions are only generated for new tasks or tasks that have been changed in the directory from which you run `submit`.



