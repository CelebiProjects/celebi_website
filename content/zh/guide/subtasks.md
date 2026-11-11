---
title: "重复任务与 100 个高斯 toy"
weight: 40
guide_group: "workflow-tutorials"
summary: "一个 Task impression、N 次带 index 的执行，以及生成—拟合—汇总示例。"
---

在 Task 的 `celebi.yaml` 添加 `subtasks: N`，即可重复执行同一份计算 N 次。
它仍然是普通 Task，共用一个 impression。Yuki 生成一条 Snakemake wildcard
执行规则和一条完成规则，不为每个 index 注册独立 Yuki job 或 impression。
`create-multi-tasks` 则仍然创建多个独立 Task 对象。

```yaml
environment: python3.12
memory_limit: 128Mi
subtasks: 100
commands:
  - python code/fit.py --index ${index} --input toys/stageout/${index}/*.json --output stageout/index
```

N 必须是正的 YAML 整数。`${index}` 提供 0 到 N - 1 的十进制整数，Python
解析命令行参数时用 `type=int`。设置 subtasks 后，用户参数中的 index 是保留
名称。不写 subtasks 时保持普通 Task 行为。使用前须同时更新 Celebi 和 Yuki。
数据类任务、特殊的 `htcondorcern` backend 以及客户端 test/workaround 展开
不支持 subtasks。

## 路径与 alias

| 路径 | 含义 |
|---|---|
| `toys/stageout/${index}/*.json` | 用编号选择上游输入分区 |
| `stageout/index/fit.json` | 当前实例内的固定输出路径，index 是字面目录名 |
| `stageout/7/fit.json` | 编号 7 的实际 Task 输出 |
| `fits/stageout/7/fit.json` | 下游通过 alias 读取同一输出 |

运行器将固定 `stageout/index/` 直接链接到当前编号的输出目录。在线缓存、
收集结果和下游输入都保留 `stageout/<编号>/`，即使 `subtasks: 1` 也保留
`/0/`，不需要运行后搬运。独立工作目录避免正常写入互相覆盖，但不构成
操作系统层面的安全沙箱。

alias 始终指向整个上游 Task。下游等待全部实例完成；逐项处理用 `${index}`
显式选择输入，汇总时遍历全部分区。`*.json` 由 shell 展开，本例每个分区
恰好包含一份 JSON toy 数据。

## 三个 Task，100 个高斯 toy

本地 `Demo/demo-subtasks-01-gaussian-toys` 项目只有三个 Task：

```text
GenerateTask -> FitTask（100 subtasks）-> SummaryTask
```

每份 toy 含 1,000 个均值为 5、sigma 为 1.5 的高斯随机数，随机种子是
20261025 + index。拟合使用无截断高斯模型的精确非分箱最大似然解，误差使用
渐近似然曲率。脚本仅依赖 Python 标准库，不需要 ROOT、NumPy 或数值优化器。

下载 [generate.py](/examples/gaussian-toys/GenerateTask/generate.py)、
[fit.py](/examples/gaussian-toys/FitTask/fit.py) 和
[summarize.py](/examples/gaussian-toys/SummaryTask/summarize.py)。创建三个
Task，将脚本分别放在对应目录：

```bash
celebi-cli create-task GenerateTask
celebi-cli create-task FitTask
celebi-cli create-task SummaryTask
cd FitTask
celebi-cli add-input ../GenerateTask toys
cd ../SummaryTask
celebi-cli add-input ../FitTask fits
```

**GenerateTask/celebi.yaml**：一次执行生成 `stageout/0/toy.json` 至
`stageout/99/toy.json`，以及 manifest。

```yaml
environment: python3.12
memory_limit: 128Mi
parameters:
  toys: 100
  events: 1000
  mean: 5.0
  sigma: 1.5
  seed: 20261025
commands:
  - python generate.py --toys ${toys} --events ${events} --mean ${mean} --sigma ${sigma} --seed ${seed} --output stageout
```

**FitTask** 使用本页开头的 YAML。重复执行的 inline Task 将共享源码暴露为
`code/`；每个实例写入固定 `stageout/index/fit.json`。

**SummaryTask/celebi.yaml**：检查全部 100 个结果，生成 `fits.csv`、
`summary.json`、`summary.svg` 和 `report.md`。

```yaml
environment: python3.12
memory_limit: 128Mi
parameters:
  expected: 100
commands:
  - python summarize.py --fits fits/stageout --expected ${expected} --output stageout
```

缺失结果或内容不一致时汇总报错。修改 toy 数量时，同时修改 GenerateTask 的
`parameters.toys`、FitTask 的 `subtasks` 和 SummaryTask 的 `parameters.expected`。

项目根目录的 `.celebi-env/python3.12.yaml`：

```yaml
channels:
  - conda-forge
dependencies:
  - python=3.12
```

执行 `celebi-cli install-environment local python3.12` 安装环境，在三个
Task 中分别执行 `celebi-cli request-runner local`，然后从 SummaryTask 提交：

```bash
celebi-cli submit --runner local
celebi-cli status --wait
celebi-cli collect all
celebi-cli view-url
```

Demo 的 `python run_local.py --cores 4` 使用当前 Python 环境，独立验证真实
Yuki Snakefile 生成与全部执行，不连接服务器。结果在 `.local-run/results/`。
给定配置的 100 次拟合全部通过，拟合均值平均为 4.995186，sigma 平均为
1.496423。这些是可复现参考值，不是验收阈值，也不表示已在在线服务运行。
有限 toy 数量会使 pull 分布出现统计涨落。

## 日志、缓存和重试

在 FitTask 内执行 `celebi-cli log 0 --subtask 7`，读取实例 7 的命令 0 日志，
加 `--follow` 可以跟随新输出。日志和实例状态文件位于 `logs/<编号>/`。
进程突然终止可能留下过时的 running 状态，应结合 workflow 终态判断。
终态详情会保留失败编号。若短任务在两次状态轮询之间启动并失败，只要后端日志证明
它实际运行过，就会归类为运行时失败，而不是工作流构造失败。REANA 收集会展开嵌套
文件列表和归档，同时保留数字编号的 stageout 与日志目录。

全部实例成功后才发布 Task 完成标记和完整缓存。同一个工作区中使用 Snakemake
`--rerun-incomplete` 可以保留成功实例。新建 Celebi workflow 仍可能重跑全部
实例，目前没有跨 workflow 的按 index 复用或专用单 index 重试 CLI。
