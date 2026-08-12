---
title: "你的第一个工作流"
weight: 1
summary: "用高斯分布产生样本并拟合 —— 完整的 Gen → Fit 示例。"
---

本指南演示 Celebi 的经典示例:**用高斯分布产生一些样本并拟合它**(另见
[demo-basic-01](https://celebi.readthedocs.io/en/latest/examples/demo-basic-01.html))。

## 0. 开始一个项目

```sh
celebi init .            # 在空目录中
celebi use .             # 在已有的 Celebi 项目目录中
celebi                   # 进入 Celebi shell
celebi projects          # 列出项目;celebi workon [name]  切换项目
```

## 1. 构建工作流

每个工作流节点都是磁盘上的一个文件夹。创建两个算法和两个任务,然后把它们连起来:

```text
create-algorithm AlgGen
create-algorithm AlgFit
create-task Gen
create-task Fit

cd @/Gen    add-algorithm ../AlgGen
cd @/Fit    add-algorithm ../AlgFit
cd @/Fit    add-input ../Gen gen
```

`add-input ../Gen gen` 让 Gen 任务在 Fit 内部以名为 `gen` 的子文件夹可见 ——
这就是[别名系统](/zh/concepts/repository/)的工作方式。

## 2. 写代码并配置

在**算法**中,写下带参数占位符的命令模板:

```yaml
# AlgGen/celebi.yaml
environment: script
commands:
  - root -l code/gen.C('${events}')
```

用你习惯的编辑器写实际代码:

```text
cd @/AlgGen
edit-script gen.C
```

在**任务**中,设置环境与参数:

```text
cd @/Gen
set-environment env:root6
add-parameters events 1000
```

运行时,模板会被翻译成 `root -l code/gen.C('1000')`。

## 3. 交互式开发

导航到某个任务,运行:

```text
workaround
```

你会进入一个新建文件夹中的 shell:任务的算法被复制到 `code/`,依赖以别名的形式
复制进来 —— 它模拟真实的运行环境,因此你可以精确调试将要执行的内容。

## 4. 提交运行

```text
cd @/Fit
submit                 # 或:submit [runner_name]
```

[runner](/zh/concepts/runner/) 会解析依赖,先运行 Gen、再运行 Fit,输出经由
[Yuki](/zh/concepts/yuki/) 取回。在某个目录中执行 `submit`,等于在它所有子节点中
执行 —— 一个动作提交整个工作流。

## 5. 日常操作

- **复制子工作流** —— `cp TasksGroup TaskGroupB` 复制工作流的一部分,连接自动
  接好。做系统误差研究时非常好用。
- **重命名 / 重组** —— 随意 `mv`;别名系统会保持底层工作流不变。
- **写文档** —— 每个对象都有自己的 `README.md`,它不会影响结果(impression 不会
  封存它),随时可以打磨。
