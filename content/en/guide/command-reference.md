---
title: "Command reference"
weight: 3
summary: "A categorized quick reference for the Celebi shell, one-shot CLI, and Git commands."
---

Celebi has three entry points: `celebi` enters the persistent interactive shell,
`celebi-cli COMMAND` runs one operation for scripts, and `celebi-git COMMAND`
contains Git integration. The tables use the canonical command names shared by
the shell and `celebi-cli` unless marked shell-only. Square brackets `[ ]` mark
optional arguments.

Inside `celebi`, bare `helpme` gives object-aware guidance. These three forms show
the same detailed command documentation:

```text
help status
helpme status
status --help
```

Use `celebi-cli COMMAND --help` outside the shell. Compatibility spellings remain
callable and are listed separately by `celebi-cli --help`.

## Projects & navigation

| Command | Purpose and usage |
|---|---|
| `init [--project-uuid <uuid>]` | Initialize the current empty directory as a Celebi project |
| `list-projects` | List all registered projects |
| `use-project <name>` | Select the project opened by the next `celebi` session |
| `register-project <path> [--new-project]` | Register an existing project; assign a fresh UUID only for an intentional copy |
| `remove-project <name>` | Remove a registry entry without deleting project files |
| `project-path` | Print the path of the current project |
| `project-uuid` | Print the UUID of the current project |
| `cd <path>` | Change directory/object within `celebi` (shell-only) |
| `cd-project <name>` | Switch project within `celebi` (shell-only) |
| `tree` | Display the directory tree |
| `mkdir <path>` | Create a new directory object |
| `ls` | List the current object: README, subobjects, and status tags (options like `ls --status`) |
| `short-ls` | Short listing of the current object |

## Creating objects

| Command | Purpose and usage |
|---|---|
| `create-algorithm <name>` | Create an algorithm object (a reusable computation template) |
| `create-task <name>` | Create a task object (a concrete instance of an algorithm) |
| `create-multi-tasks <base> <stop> [--start <n>]` | Create numbered tasks for the half-open range `start <= n < stop` |
| `create-data <name>` | Create a data object |
| `create-multi-data <path>` | Create and upload one data object per immediate child directory |
| `create-data-list <name>` | Create a data-list object |
| `create-lhcb-ap-list <name>` | Create an LHCb AP data-list task (generates `dataList.txt` dynamically; fill in the AP query parameters afterwards) |
| `add-apd-token <token>` | Store an APD token for the current LHCb AP data-list task (in `.celebi/config.local.json`) |

## Wiring objects & parameters

| Command | Purpose and usage |
|---|---|
| `add-algorithm <path>` | Attach an algorithm to the current task (visible as `code/` inside it) |
| `add-input <path> <alias>` | Add an input to the current task/algorithm, referenced by alias (the alias system keeps reorganization safe) |
| `add-multi-inputs <path-base> <alias-base> <stop> [--start <n>]` | Add numbered input paths and aliases for a half-open range |
| `remove-input <alias>` | Remove an input |
| `remove-multi-inputs <alias-base> <stop> [--start <n>]` | Remove numbered aliases for a half-open range |
| `set-parameter <name> <value>` | Set a task parameter matching `${name}` in algorithm commands |
| `add-parameter-subtask <dirname> <name> <value>` | Add a parameter to a specific subtask inside a directory |
| `remove-parameter <name>` | Remove a parameter |
| `predecessors` | List the predecessors of the current object |
| `successors` | List the successors of the current object |

## Configuration & editing

| Command | Purpose and usage |
|---|---|
| `config` | Open the object's `celebi.yaml` in the default editor (creates a template if missing) |
| `set-environment <env>` | Set `script`, a container image, a managed Conda environment name, or an LHCb `lb-conda/PACKAGE/DATE` environment |
| `user-config [--list]` | Edit or display user-level defaults copied into newly created objects; it does not edit existing tasks |
| `cache-policy [auto\|mtime\|off]` | Show or set the current project's local cache invalidation policy |
| `set-memory-limit <limit>` | Set the memory limit, e.g. `256Mi` |
| `set-descriptor <text>` | Set the object's descriptor (human-readable name/description) |
| `add-source <path>` | Link an external source file/directory to the object (tracked for dependencies) |
| `comment <text>` | Add a comment to the object |
| `edit-readme` | Edit the object's README |
| `edit <file>` | Edit a script file |
| `watermark` | Show the object's watermark (creation metadata, version and signature info) |
| `history` | Show the object's execution and modification history |
| `changes` | Show recent changes to the object |

## Impressions

| Command | Purpose and usage |
|---|---|
| `impress [--offline] [--immutable] [--cache-dir <path>]` | Seal the current object state; immutable mode evaluates a fixed DAG once |
| `impression` | Get the current object's impression |
| `view [impression]` | View the current or selected impression |
| `view-url [impression]` | Get an impression URL |
| `search-impression <prefix>` | Search impressions by UUID prefix |
| `trace <object>` | Compare an object/impression with its recorded dependency DAG |
| `draw-dag [output] [--exclude-algorithms]` | Draw the dependency DAG with Graphviz |
| `bookkeep [--commit <message>] [--tag <tag>]` | Publish Git code and collected small results to a Celebi bookkeeping server |
| `bookkeeping-url` | Get the bookkeeping URL |
| `open-bookkeeping` | Open the bookkeeping page |
| `purge-impressions` | Purge impressions of the current object |
| `purge-old-impressions` | Purge old impression data, keeping only recent or essential snapshots |
| `doctor` | Run system diagnostics: examine and repair the repository |

## Execution

| Command | Purpose and usage |
|---|---|
| `submit [--runner <name>] [--timeout <seconds>] [--with-unknown]` | Submit the current task or container for execution |
| `status [--wait] [--poll-interval <seconds>]` | Show status and optionally poll until terminal state — see [Task and algorithm states](/guide/task-and-algorithm-states/) |
| `cancel` | Cancel running impressions for the current task or directory |
| `log [index] [--follow]` | Show a user-command log, optionally following new output |
| `collect [all\|plots\|data\|logs\|<glob>\|<name>] [--allow-failed]` | Collect task results; defaults to plots + logs |
| `engine-logs [--fetch]` | Display saved workflow engine logs or fetch them from DITE |
| `collect-outputs` / `collect-logs` | Collect only outputs or logs |
| `refresh-filelists` | Re-list stageout and logs for a terminal workflow |
| `check-results <runner>` | Mount cached results for inspection on an SSH runner |
| `auto-download on\|off` | Enable or disable automatic result downloads |
| `cache-on-runner on\|off` | Enable or disable runner-side result caching (no additional effect on native) |
| `test [docker\|ssh] [runner]` | Test the current task locally with Docker or on a registered SSH runner |
| `workaround [--reference <alg>] [--skip-input <task>]` | Debug in a simulated local run environment (shell-only); the one-shot result viewer is `workaround-vre` |

## DITE & servers

| Command | Purpose and usage |
|---|---|
| `dite` | Show DITE connection information |
| `set-dite <url>` | Set the DITE (Yuki) server URL (`dite` displays the current setting) |
| `add-host <host> <port-or-url>` | Register a communicator host, e.g. `add-host localhost http://127.0.0.1:8080` |
| `hosts` | List all hosts and their status |
| `register-booking-server [--server <url>] [--token <token>]` | Register the REANA server URL and token with Yuki (falls back to environment variables) |
| `register-celebi-server --server <url> --token <token> [--yuki <url>]` | Save and verify credentials for Celebi bookkeeping |
| `booking-server` | Check the registered REANA server URL and status |
| `book-reana` | Package the current project and upload it to REANA via Yuki (streaming progress) |

## Runner management

| Command | Purpose and usage |
|---|---|
| `runners` | List all available runners with full configuration |
| `register-runner <name> <url> <secret> <backend-type>` | Register a `reana`, `native`, `ssh`, or `ihep` runner; backend-specific settings are options |
| `request-runner <name>` | Set the requested runner for the current task |
| `test-runner <name>` | Probe runner capabilities; native probes also require a live host agent |
| `install-environment <runner> <name> [--file <yaml>]` | Install or update a project-scoped Conda environment on an SSH/IHEP/native runner; defaults to `.celebi-env/<name>.yaml` |
| `runner-environments <runner>` | List environments for the current project on an SSH/IHEP/native runner |
| `remove-runner <name>` | Remove a runner |
| `update-runner <name> ...` | Update runner settings (url, token, backend type, Kerberos, EOS mount point, …) |
| `yuki-overview` | Summarize runner state, capacity, and current resource use |
| `refresh-distribution` | Rebuild the current project's result-location registry |

Project environments are installed below
`<runner-workdir>/environments/<project_uuid>/<environment_name>`, so two projects
using the same logical name remain isolated. Re-running `install-environment` updates
the prefix with `conda env update --prune`. The YAML `name` field is ignored, and no
specification hash is stored: these environments are trusted mutable runner state.
Explicit Yuki `conda_env_map` entries remain available for compatibility.
For native runners, the workdir defaults to `~/.Yuki/LocalWorkflows`, and workflow
state is separated under `workflows/<project_uuid>/<workflow_uuid>`. Submission
fails early with the install command when a managed environment is missing.

Native and Yuki Storage form one storage domain: successful stage-out enters Storage
directly. Native therefore has no separate managed cache and is not a transfer
location; use `yuki` instead.

## Data management

| Command | Purpose and usage |
|---|---|
| `upload-data <path>` | Upload a local path to DITE |
| `register-ssh-data <runner> <remote-path>` | Register data living on an SSH runner into Yuki's managed staging (MD5 + background copy, live byte progress) |
| `register-xrootd-data <runner> <root-url> [--checksum auto\|required\|none]` | Freeze an XRootD sample as a datalist without copying payloads through Yuki |
| `verify-data` | Verify the current data task: recompute its MD5 against the registered UUID |
| `attach-data <uuid> [--path <path>]` | Attach a Yuki impression to a rawdata task |
| `whereabouts` | Show whether the current result is in Yuki Storage or runner caches |
| `transfer <source> <destination>` | Move results between `yuki` and `runner:<name>` locations |
| `cache-results <runner>` | Copy the current result into an SSH runner's managed cache |
| `purge-data [--force]` | Remove collected Yuki data; normally requires another recoverable copy |
| `import <path>` | Import external files into the current object (`/*` imports a whole directory) |
| `export <glob>` | Export matching files to `project/export/` |
| `remove-file <file>` | Remove a file from the object |
| `move-file <src> <dst>` | Move a file within the object |
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
| `system-shell` | Enter a system bash; `exit` or Ctrl-D returns to Celebi (shell-only) |
| `danger-call <cmd>` | Execute a system command directly (shell-only; use with care) |
| `EOF` | Exit the Celebi shell (shell-only; same as Ctrl-D) |
| `help` | List commands (shell-only; use `celebi-cli --help` outside it) |
| `helpme` | Get object-aware help (shell-only) |

## Recovery & impression storage

| Command | Purpose and usage |
|---|---|
| `sync-live` | Push the project's live impression set to Yuki |
| `stop-workflow <uuid>` | Force-stop a workflow, including a zombie run |
| `stop-orphaned-workflows <runner>` | Stop workflows no longer referenced by the project |
| `purge-stale-cache <runner> [--dry-run]` | Remove superseded cached impressions |
| `purge-stale-workflows <runner> [--dry-run]` | Delete non-live, non-running workflow workspaces |
| `gc-impressions [--execute]` | Garbage-collect unreachable CAS objects; dry-run is the default |
| `pack-impressions [--force]` | Pack eligible CAS impression objects |
| `migrate-impressions [--dry-run] [--prune-legacy]` | Migrate legacy impression storage into CAS references |
| `impression-stats` | Display impression storage statistics |

## Git integration

These commands use the separate `celebi-git` entry point.

| Command | Purpose and usage |
|---|---|
| `celebi-git enable` / `disable` | Enable or disable integration for the current project |
| `celebi-git status` | Show integration state and merge readiness |
| `celebi-git validate` | Validate Celebi metadata after Git operations |
| `celebi-git hooks --install\|--uninstall` | Manage Celebi-aware Git hooks |
| `celebi-git merge <branch> [--strategy <mode>]` | Merge with Celebi validation and impression regeneration |
| `celebi-git config <key> <value>` | Set a Git integration option |
