---
title: "Installation and first start"
weight: 10
guide_group: "getting-started"
summary: "Install Celebi and Yuki, start their services, and initialize a project."
---

Celebi is the project-facing client. Yuki is the HTTP service, task queue, workflow
builder, runner registry, and result-location service behind it. A usable local setup
needs both packages and a running Yuki service.

## Install from source

Celebi and Yuki are under rapid development. Installing their source checkouts in
editable mode is therefore recommended: updates from `git pull` become available
without reinstalling the packages. Use separate Python or Conda environments if
you want to develop the two projects independently:

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

## Start Yuki locally with Docker Compose

From the Yuki checkout, Docker Compose builds the development image, mounts the
local Yuki source, and starts RabbitMQ, the Flask API, and the Celery worker
together:

```sh
cd Yuki
docker compose up --build
```

After the first build, plain `docker compose up` is sufficient. Keep that terminal
open while using Celebi, or add `-d` to run the service in the background and use
`docker compose logs -f` to follow its logs. Stop a background service with
`docker compose down`.

The API listens on port `3315` by default, and Yuki's data persists in the host
`~/.Yuki` directory. On first start Yuki registers a native runner named `local`.
Native workflows still require the host agent, started from the environment where
Yuki was installed with `pip install -e .`:

```sh
yuki native-runner start
yuki native-runner status
```

Use `yuki native-runner logs` for agent logs and `yuki native-runner stop` before
maintenance. The native host agent runs outside the Compose container and shares
the same `YUKIDIR`.

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
