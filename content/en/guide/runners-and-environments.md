---
title: "Runners and environments"
weight: 4
summary: "Configure REANA, native, SSH, and IHEP execution and project environments."
---

Yuki supports four current backend types: `reana`, `native`, `ssh`, and `ihep`.
List and probe configured runners before submitting:

```sh
celebi-cli runners
celebi-cli test-runner RUNNER
celebi-cli yuki-overview
```

## Register a runner

The complete positional signature is:

```text
celebi-cli register-runner NAME URL SECRET BACKEND_TYPE [OPTIONS]
```

- `reana` runs containerized workflows through a REANA service.
- `native` uses a Yuki host agent and a local `--workdir`.
- `ssh` uses `--ssh-host`, `--ssh-user`, `--ssh-key-path`, and
  `--remote-workdir` to execute on a remote host.
- `ihep` uses the SSH transport but submits the coordinator and rule jobs through
  `hep_sub`; its remote workdir must be shared by login and worker nodes.

Use `celebi-cli register-runner --help` for backend-specific resource, Conda, and
Snakemake options. Secrets and private keys are operational credentials: do not put
them in a project README or commit them to Git.

Select a default runner on a task with `request-runner NAME`, or override it for one
submission:

```sh
celebi-cli submit --runner NAME
```

## Project-scoped Conda environments

`celebi-cli init` creates `.celebi-env/default.yaml`. Add more definitions as
`.celebi-env/NAME.yaml`, then install one on an SSH, IHEP, or native runner:

```sh
celebi-cli install-environment RUNNER NAME
celebi-cli runner-environments RUNNER
celebi-cli set-environment NAME
```

Yuki installs it below
`<runner-workdir>/environments/<project_uuid>/<name>`. The project UUID prevents two
projects with the same environment name from sharing a prefix. Reinstallation runs
`conda env update --prune`; the YAML `name` field does not choose the prefix. A
submission fails early with an install hint when the environment is missing.

## Containers and LHCb environments

For REANA, the normal `environment` value can be a container image. Algorithms whose
commands inherit the task environment use `environment: script`.

LHCb releases can be declared with an `lb_run` block containing required `project`
and `version` fields and an optional `platform`. The ordinary `environment` remains
required as an ABI-compatible base. Native, SSH, and IHEP hosts must expose
`/cvmfs/lhcb.cern.ch`; REANA must mount the same repository.

For a dated LbConda environment, use:

```yaml
environment: lb-conda/default/2020-05-14
```

The supported form is `lb-conda/PACKAGE/DATE`. Do not combine `lb-conda/...` with an
`lb_run` block on the same task.
