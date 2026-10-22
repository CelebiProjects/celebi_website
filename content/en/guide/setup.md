---
title: "Installation and first start"
weight: 2
summary: "Install Celebi and Yuki, start their services, and initialize a project."
---

Celebi is the project-facing client. Yuki is the HTTP service, task queue, workflow
builder, runner registry, and result-location service behind it. A usable local setup
needs both packages and a running Yuki service.

## Install from source

Use separate Python or Conda environments if you want to develop the two projects
independently:

```sh
git clone https://github.com/CelebiProjects/Celebi.git
git clone https://github.com/CelebiProjects/Yuki.git

python -m pip install -e ./Celebi
python -m pip install -e ./Yuki
```

Verify the entry points:

```sh
celebi-cli --help
celebi-git --help
yuki --help
```

## Start Yuki locally

Yuki's Flask server and Celery worker require RabbitMQ. From the Yuki checkout, the
provided setup script creates and starts a dedicated broker environment:

```sh
scripts/setup-rabbitmq.sh
yuki server start
yuki server status
```

The API listens on port `3315` by default. On first start Yuki registers a native
runner named `local`. Native workflows require the host agent:

```sh
yuki native-runner start
yuki native-runner status
```

Use `yuki native-runner logs` for agent logs and `yuki native-runner stop` before
maintenance. Alternatively, `yuki docker run` starts the all-in-one Docker service;
the native host agent still runs outside the container and shares the same `YUKIDIR`.

## Connect Celebi and create a project

```sh
celebi-cli set-dite http://127.0.0.1:3315
mkdir my-analysis
cd my-analysis
celebi-cli init
celebi
```

`init` creates project metadata and `.celebi-env/default.yaml`. For an existing
project, use `celebi-cli register-project PATH`. Add `--new-project` only when a
copied checkout must become a distinct project with a new UUID.

Run these checks before building a workflow:

```sh
celebi-cli dite
celebi-cli runners
celebi-cli test-runner local
```

Continue with [Runners and environments](/guide/runners-and-environments/) before
submitting work.
