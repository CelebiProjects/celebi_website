---
title: "安装与首次启动"
weight: 10
guide_group: "getting-started"
summary: "安装 Celebi 与 Yuki,启动服务并初始化项目。"
---

Celebi 是面向项目的客户端;Yuki 在其后提供 HTTP 服务、任务队列、工作流构建、
runner 注册与结果位置管理。可用的本地环境需要安装两者并启动 Yuki。

## 从源码安装

Celebi 和 Yuki 仍在快速开发中，因此建议以 editable mode 安装源码：
`git pull` 更新后无需重新安装，新代码就会直接生效。若要分别开发两个项目，
建议使用不同的 Python 或 Conda 环境：

```sh
git clone https://github.com/CelebiProjects/Celebi.git
git clone https://github.com/CelebiProjects/Yuki.git

python -m pip install -e ./Celebi
python -m pip install -e ./Yuki
```

验证命令入口:

```sh
celebi-cli --help
celebi-git --help
yuki --help
```

## 使用 Docker Compose 在本机启动 Yuki

在 Yuki 源码目录中，Docker Compose 会构建开发镜像、挂载本地 Yuki 源码，
并一起启动 RabbitMQ、Flask API 和 Celery worker：

```sh
cd Yuki
docker compose up --build
```

首次构建完成后，直接运行 `docker compose up` 即可。使用 Celebi 时保持该终端
运行；也可添加 `-d` 让服务在后台运行，再用 `docker compose logs -f` 跟踪日志。
后台服务可用 `docker compose down` 停止。

API 默认监听 `3315` 端口，Yuki 数据保存在宿主机的 `~/.Yuki` 目录中。
Yuki 首次启动时会注册名为 `local` 的 native runner。执行 native 工作流
仍需要宿主机 agent，请在通过 `pip install -e .` 安装 Yuki 的环境中启动：

```sh
yuki native-runner start
yuki native-runner status
```

用 `yuki native-runner logs` 查看日志；维护前用 `yuki native-runner stop` 停止。
native host agent 运行在 Compose 容器之外，并与容器共享同一个 `YUKIDIR`。

## 连接 Celebi 并创建项目

```sh
celebi-cli set-dite http://127.0.0.1:3315
mkdir my-analysis
cd my-analysis
celebi-cli init
celebi
```

`init` 会创建项目元数据和 `.celebi-env/default.yaml`。已有项目使用
`celebi-cli register-project PATH`;只有在复制的 checkout 应成为具有新 UUID 的
独立项目时才添加 `--new-project`。

建立工作流前运行:

```sh
celebi-cli dite
celebi-cli runners
celebi-cli test-runner local
```

提交任务前请继续阅读 [Runner 与环境](/zh/guide/runners-and-environments/)。
