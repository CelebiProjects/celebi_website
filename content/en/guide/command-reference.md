---
title: "Command reference"
weight: 3
summary: "A categorized quick reference for every Celebi shell command: navigation, object creation, wiring and parameters, configuration, impressions, execution, DITE, runners, data, and files."
---

All commands below are used inside the interactive Celebi shell (enter with
`celebi`). Command names are case-insensitive and arguments are space-separated.
Square brackets `[ ]` mark optional arguments.

## Projects & navigation

| Command | Purpose and usage |
|---|---|
| `ls-projects` | List all registered projects |
| `cd-project <name>` | Switch to a different project |
| `navigate` | Print the path of the current project |
| `project-uuid` | Print the UUID of the current project |
| `cd <path>` | Change directory/object within the project (supports numeric index and `@/` root paths) |
| `tree` | Display the directory tree |
| `mkdir <path>` | Create a new directory object |
| `ls` | List the current object: README, subobjects, and status tags (options like `ls --status`) |
| `short-ls` | Short listing of the current object |

## Creating objects

| Command | Purpose and usage |
|---|---|
| `create-algorithm <name>` | Create an algorithm object (a reusable computation template) |
| `create-task <name>` | Create a task object (a concrete instance of an algorithm) |
| `create-multi-tasks <base> <n>` | Create multiple tasks at once |
| `create-data <name>` | Create a data object |
| `create-multi-data <base> <n>` | Create multiple data objects at once |
| `create-data-list <name>` | Create a data-list object |
| `create-lhcb-ap-list <path>` | Create an LHCb AP data-list task (generates `dataList.txt` dynamically; fill in the AP query parameters afterwards) |
| `add-apd-token <token>` | Store an APD token for the current LHCb AP data-list task (in `.celebi/config.local.json`) |

## Wiring objects & parameters

| Command | Purpose and usage |
|---|---|
| `add-algorithm <path>` | Attach an algorithm to the current task (visible as `code/` inside it) |
| `add-input <path> <alias>` | Add an input to the current task/algorithm, referenced by alias (the alias system keeps reorganization safe) |
| `input` | Alias for `add-input` |
| `add-multi-inputs <base> <n>` | Add multiple inputs at once |
| `remove-input <alias>` | Remove an input |
| `remove-multi-inputs` | Remove multiple inputs at once |
| `add-parameter <name> <value>` | Add a parameter to the task, matching `${name}` in the algorithm's commands |
| `add-parameter-subtask <dirname> <name> <value>` | Add a parameter to a specific subtask inside a directory |
| `remove-parameter <name>` | Remove a parameter |
| `predecessors` | List the predecessors of the current object |
| `successors` | List the successors of the current object |

## Configuration & editing

| Command | Purpose and usage |
|---|---|
| `config` | Open the object's `celebi.yaml` in the default editor (creates a template if missing) |
| `set-environment <env>` | Set the execution environment: `script` for script-based algorithms, otherwise a Docker image name |
| `setenv` | Alias for `set-environment` |
| `set-memory-limit <limit>` | Set the memory limit, e.g. `256Mi` |
| `set-descriptor <text>` | Set the object's descriptor (human-readable name/description) |
| `setdescriptor` | Alias for `set-descriptor` |
| `add-source <path>` | Link an external source file/directory to the object (tracked for dependencies) |
| `comment <text>` | Add a comment to the object |
| `edit-readme` | Edit the object's README |
| `edit-script <file>` | Edit a script file |
| `watermark` | Show the object's watermark (creation metadata, version and signature info) |
| `history` | Show the object's execution and modification history |
| `changes` | Show recent changes to the object |

## Impressions

| Command | Purpose and usage |
|---|---|
| `impress [names...]` | Create an impression of the current object (or the named sub-objects) — seal the current state |
| `impression` | Get the current object's impression |
| `view` | View impressions of the current task |
| `viewurl` | Get the impression URL |
| `search-impression <prefix>` | Search impressions by UUID prefix |
| `trace` | Trace back to the task/algorithm that generated an impression |
| `draw-dag-graphviz <output> [--exclude-algorithms]` | Draw the dependency DAG with Graphviz (PDF/SVG/PNG) |
| `bookkeep` | Project-wide impression bookkeeping (storage, indexing, cleanup) |
| `bkkurl` | Get the bookkeeping URL |
| `viewbkk` | Open the bookkeeping URL |
| `homekeep` | Clean up workflows on the runner |
| `clean-impressions` | Clean impressions (developer tool) |
| `purge-impressions` | Purge impressions of the current object |
| `purge-old-impressions` | Purge old impression data, keeping only recent or essential snapshots |
| `doctor` | Run system diagnostics: examine and repair the repository |

## Execution

| Command | Purpose and usage |
|---|---|
| `submit [runner] [names...]` | Submit the current object (or named sub-objects) for execution; optionally choose a runner, e.g. `submit --runner cern` |
| `jobs` | Show job information for the current algorithm/task |
| `status` | Show the object's status (local state + DITE job status — see [Task and algorithm states](/guide/task-and-algorithm-states/)) |
| `kill` | Kill the current object's running process |
| `log` | Show the current object's log |
| `collect [all\|plots\|data\|logs\|<glob>\|<name>]` | Collect task results; defaults to plots + logs |
| `engine-logs` | Fetch workflow engine logs from DITE |
| `auto-download` | Enable/disable automatic result downloads |
| `cache-on-runner` | Enable/disable EOS caching |
| `test` | Run a test workflow in a Docker container |
| `workaround [--reference <alg>] [--skip-input <task>]` | Debug the task in a simulated local run environment — what you see is what runs |

## DITE & servers

| Command | Purpose and usage |
|---|---|
| `dite` | Show DITE connection information |
| `set-dite <url>` | Set the DITE (Yuki) server URL; with no argument, show the current setting |
| `add-host <name> <url>` | Register a host, e.g. `add-host localhost http://127.0.0.1:8080` |
| `hosts` | List all hosts and their status |
| `register-booking-server [url] [token]` | Register the REANA server URL and token with Yuki (falls back to environment variables) |
| `booking-server` | Check the registered REANA server URL and status |
| `book-reana` | Package the current project and upload it to REANA via Yuki (streaming progress) |

## Runner management

| Command | Purpose and usage |
|---|---|
| `runners` | List all available runners with full configuration |
| `register-runner <name> <url> <secret>` | Register a new runner with DITE |
| `request-runner <name>` | Set the requested runner for the current task |
| `test-runner <name>` | Probe a runner's capabilities (snakemake/conda/workdir) |
| `runner-envs <name>` | List conda environments available on a runner (ssh/native) |
| `remove-runner <name>` | Remove a runner |
| `update-runner <name> ...` | Update runner settings (url, token, backend type, Kerberos, EOS mount point, …) |

## Data management

| Command | Purpose and usage |
|---|---|
| `upload-data <path>` | Upload a local path to DITE |
| `register-ssh-data` | Register data living on an ssh runner into Yuki's managed staging (MD5 + background copy, live byte progress) |
| `verify-data` | Verify the current data task: recompute its MD5 against the registered UUID |
| `attach-data <uuid> [path]` | Attach a Yuki impression to a rawdata task |
| `import <path>` / `import-file` | Import external files into the current object (`/*` imports a whole directory) |
| `export <glob>` | Export matching files to `project/export/` |
| `rm-file <file>` | Remove a file from the object |
| `mv-file <src> <dst>` | Move a file within the object |
| `display <file>` | View a file of the object |
| `cat <file>` | Show file contents |
| `imgcat <file>` | Display an image inline in the terminal (from DITE) |

## File & object operations

| Command | Purpose and usage |
|---|---|
| `cp <src> <dst>` | Copy objects (relationships and metadata preserved, connections re-wired) |
| `mv <src> <dst>` | Move/rename objects (relationships unchanged — reorganize freely) |
| `rm <path>` | Remove objects (validated to protect project integrity) |

## System & utilities

| Command | Purpose and usage |
|---|---|
| `system-shell` | Enter a system bash; `exit` or Ctrl-D returns to the Celebi shell |
| `danger-call <cmd>` | Execute a system command directly (use with care) |
| `EOF` | Exit the Celebi shell (same as Ctrl-D) |
| `help` | List all commands |
| `helpme` | Get help for the current object |
