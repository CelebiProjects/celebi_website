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
celebi use .
```

`celebi use .` 把 `demo-basic-01` 项目注册到 Celebi 中。注册之后,这个项目就成为
Celebi 系统管理的项目之一。

你可以运行:

```sh
celebi projects
```

查看 Celebi 当前管理的所有项目。

你也可以用:

```sh
celebi workon [project_name]
```

切换当前的工作项目。

用 `celebi workon` 选好项目后,`celebi` 命令都会在 Celebi 环境与当前所选项目中
运行。

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
  它给任务定义一个人类可读的别名,方便识别或引用任务。

通常用户不需要阅读或修改隐藏文件,例如 `.celebi/*`。这些文件由 Celebi 系统自动
管理。不过了解它们的用途仍然有帮助,所以我们在这里简单说明一下。

[runner](/zh/concepts/runner/) 解析依赖,先运行 Gen,再运行 Fit,输出经由
[Yuki](/zh/concepts/yuki/) 取回。在某个目录中执行 `submit`,等于在它所有子节点中
执行 —— 一个动作提交整个工作流。

## 5. 日常操作

- **复制子工作流** —— `cp TasksGroup TaskGroupB` 复制工作流的一部分,连接自动
  接好。做系统误差研究时非常好用。
- **重命名 / 重组** —— 随意 `mv`;别名系统会保持底层工作流不变。
- **写文档** —— 每个对象都有自己的 `README.md`,它不会影响结果(impression 不会
  封存它),随时可以打磨。
