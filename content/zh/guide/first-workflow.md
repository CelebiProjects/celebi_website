---
title: "你的第一个工作流"
weight: 1
summary: "用高斯分布产生样本并拟合 —— 完整的 Gen → Fit 示例。"
---

本指南演示 Celebi 的经典示例:**用高斯分布产生一些样本并拟合它们**(另见
[demo-basic-01](https://celebi.readthedocs.io/en/latest/examples/demo-basic-01.html))。

## 1. 克隆仓库

```sh
git clone https://github.com/CelebiProjects/demo-basic-01.git
cd demo-basic-01
```

这条命令从 GitHub 下载一个已有的 Celebi 仓库。你可以把它克隆到任何想存放 Celebi
项目的位置。

## 2. Celebi 环境

```sh
cd demo-basic-01 # (如果还没有进入该目录)
celebi-cli register-project .
celebi-cli list-projects
celebi --project demo-basic-01
```

`register-project` 注册指定路径中的项目而不改变其 UUID;`list-projects` 显示项目
注册表;`celebi --project` 直接为该项目打开交互式 shell。若希望后续会话默认使用
此项目,运行:

```sh
celebi-cli use-project demo-basic-01
```

## 3. 理解目录结构

进入 celebi 后输入 `ls`,你会看到这个仓库的结构,类似:

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

磁盘上的目录结构如下:

```bash
.
├── .celebi
│   ├── config.json
│   └── project.json
├── Fit
│   ├── .celebi
│   │   └── config.json
│   ├── celebi.yaml
│   ├── fitdata.C
│   └── README.md
├── FitTask
│   ├── .celebi
│   │   └── config.json
│   ├── celebi.yaml
│   └── README.md
├── Gen
│   ├── .celebi
│   │   └── config.json
│   ├── celebi.yaml
│   ├── gendata.C
│   └── README.md
├── GenTask
│   ├── .celebi
│   │   └── config.json
│   ├── celebi.yaml
│   └── README.md
└── README.md
```

我们先来解释 `tasks` 和 `algorithms`。打开 `Gen/gendata.C`,你会看到一个 ROOT
脚本,简化后如下:

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

这就是你稍后要运行的代码。可以看到,这个脚本接受两个参数:`numevents` 和
`outfilename`。稍后我们会看到这些参数是如何传给脚本的。

打开 `Gen/celebi.yaml`,你会看到:

```yaml
environment: script
commands:
  - root -b -q 'code/gendata.C(${events},"stageout/data.root")'
```

这个配置包含两个字段:

* **`environment: script`**
  它指定该算法是脚本型算法。脚本型算法与任务兼容,无论任务的执行环境是什么。
  大多数情况下,用 `set-environment script` 把算法的环境设为 `script` 即可。

* **`commands`**
  它指定任务将要执行的命令。这里我们用一条 ROOT 命令执行 `gendata.C`。

  注意脚本写的是 `code/gendata.C` 而不是 `gendata.C`。这是因为在任务内部,算法
  的文件被放在 `code` 目录下。稍后我们会更详细地解释这个结构。

  你还会在命令里看到 `${events}`。这是由任务提供、在命令执行时替换的参数。稍后
  我们会解释参数是如何传给任务的。

接下来看任务 `GenTask`。打开 `GenTask/celebi.yaml`,你会看到:

```yaml
alias: []
environment: rootproject/root:6.32.02-ubuntu22.04
memory_limit: 256Mi
parameters:
  events: '20000'
```

这里有四个字段:

* **`environment`**
  这里指定的环境是 `rootproject/root:6.32.02-ubuntu22.04`。这是 ROOT 团队维护、
  发布在 Docker Hub 上的 Docker 镜像:[https://hub.docker.com/r/rootproject/root](https://hub.docker.com/r/rootproject/root)。

* **`parameters`**
  `parameters` 段定义了该任务使用的参数,例如:

  ```yaml
  events: '20000'
  ```

  这个参数对应算法 `commands` 字段里的 `${events}`。任务执行时,Celebi 使用算法
  定义的命令,并把 `${events}` 替换成这里提供的值,把参数传给命令。

* **`memory_limit`**
  它指定任务申请的内存量。

* **`alias`**
  它记录前驱输入在任务内挂载时使用的名称。`GenTask` 没有上游输入,所以这里为空。

通常用户不需要阅读或修改隐藏文件,例如 `.celebi/*`。这些文件由 Celebi 系统自动
管理。不过了解它们的用途仍然有帮助,所以我们在这里简单说明一下。

## 4. 提交并检查工作流

这个示例使用 Docker 镜像,请先确认 Yuki 正在运行,并注册一个能够执行容器的
runner。参见[安装与首次启动](/zh/guide/setup/)和
[Runner 与环境](/zh/guide/runners-and-environments/)。然后在项目根目录的 Celebi
shell 中执行:

```text
>>>> runners
>>>> submit --runner RUNNER_NAME
>>>> status --wait
```

[runner](/zh/concepts/runner/) 会解析依赖并先运行 Gen、再运行 Fit。在 `FitTask`
中检查日志并取回结果:

```text
>>>> cd FitTask
>>>> log 0
>>>> collect all
>>>> ls --status
```

对目录执行 `submit` 会把子任务作为一个依赖感知的工作流提交,结果经由
[Yuki](/zh/concepts/yuki/) 返回。

## 5. 日常操作

- **复制子工作流** —— `cp TasksGroup TaskGroupB` 复制工作流的一部分,连接自动
  接好。做系统误差研究时非常好用。
- **重命名 / 重组** —— 随意 `mv`;别名系统会保持底层工作流不变。
- **写文档** —— 每个对象都有自己的 `README.md`,它不会影响结果(impression 不会
  封存它),随时可以打磨。
