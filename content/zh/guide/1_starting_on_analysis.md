---
title: "1. 开始使用 Celebi 进行分析"
summary: "学习如何使用 Celebi 在远程服务器上处理数据，同时在本地开发和管理分析代码。"
---

# 开始使用 Celebi 进行分析

本教程介绍如何使用 **Celebi** 创建并运行一个物理分析工作流。

在本例中：

- **分析代码**在本地计算机上开发和管理。
- **输入数据**存储在远程服务器上。
- **计算任务**提交到远程服务器执行。
- **输出文件**可以在任务完成后按需收集或下载。

示例项目名称为 `B02K3pi`，远程运行节点（Runner）为 `pkufarm212`。

## 前置准备：启动 Yuki

打开 WSL 终端，运行以下命令启动 Yuki：

```bash
❯ yuki docker run yuki:dev --dev-dir ~/Yuki --celebi-dir ~/Celebi
```

## 1. 初始化项目

为分析项目创建一个新目录：

```bash
❯ mkdir B02K3pi
❯ cd B02K3pi
❯ celebi init
❯ celebi
```

该目录将成为 Celebi 分析项目的根目录。

其中，`celebi init` 用于初始化项目，`celebi` 用于进入交互式命令行界面。

## 2. 注册远程数据

原始数据存储在远程服务器上。我们不需要将数据复制到本地计算机，而是通过 Celebi 注册其远程位置。

在 Celebi 交互式终端中执行：

```text
>>>> create-data Raw
>>>> cd Raw
>>>> register-ssh-data pkufarm212 /home/user/workdir/TestData
```

其中：

- `Raw`：在 Celebi 中创建的数据对象。
- `pkufarm212`：远程服务器名称。
- `/home/user/workdir/TestData`：远程服务器上存储数据的目录，需要替换为实际路径。

完成注册后，后续任务就可以引用这些远程数据，而无需手动下载。

## 3. 创建和配置任务

一个 **Task（任务）** 定义了某个数据处理步骤所需的程序、运行环境、输入数据以及执行命令。

### 3.1 创建任务

返回项目根目录并创建任务：

```text
>>>> cd ..
>>>> create-task filter0
```

在 `filter0` 目录中创建 Python 程序 `filter0.py`。

随后配置任务的 `celebi.yaml` 文件：

```yaml
descriptor: filter0
environment: env_root_6.38.04
memory_limit: 256Mi

commands:
  - python3 filter0.py
```

主要配置项如下：

| 配置项 | 含义 |
|---|---|
| `descriptor` | 任务名称 |
| `environment` | 远程 Runner 使用的 Conda 环境 |
| `memory_limit` | 任务的内存限制 |
| `commands` | 执行任务时运行的命令 |

**注意：** YAML 对缩进敏感。`commands` 下的每条命令都必须以连字符和空格（`- `）开头。

### 3.2 连接输入数据

进入任务目录，并将前面注册的数据添加为输入：

```text
>>>> cd filter0
>>>> add-input ../Raw raw_data
```

其中：

- `../Raw` 指向已经注册的数据对象。
- `raw_data` 是当前任务使用的输入别名。

输入别名与原始数据对象的名称和位置相互独立。这样，即使后续修改上游数据对象的名称或位置，也更容易维护工作流。

如果需要移除输入连接，可以执行：

```text
>>>> remove-input raw_data
```

注意，这里使用的是输入别名 `raw_data`，而不是原始数据对象的名称。

### 3.3 输入和输出目录

当 `filter0.py` 执行时，其使用的输入、输出路径可以表示为：

```text
filter0/
├── celebi.yaml
├── filter0.py
├── raw_data/
│   └── stageout/
│       └── input.root
└── stageout/
    └── output.root
```

其中最重要的两个路径是：

- **输入目录：** `raw_data/stageout/`
- **输出目录：** `stageout/`

例如，在 Python 程序中可以这样读取和创建 ROOT 文件：

```python
import ROOT
from pathlib import Path

input_file = ROOT.TFile.Open("raw_data/stageout/input.root")

Path("stageout").mkdir(exist_ok=True)
output_file = ROOT.TFile("stageout/output.root", "RECREATE")

# 在这里编写分析代码

output_file.Close()
input_file.Close()
```

其中 `input.root` 需要替换为实际的输入文件名。

写入 `stageout/` 的文件将作为该任务的输出结果，由 Celebi 进行管理。

## 4. 配置运行环境

### 4.1 安装并查看环境

在项目的 `.celebi-env/env_root_6.38.04.yaml` 中创建标准 Conda YAML，
然后将环境安装到 Runner 并查看当前项目的环境：

```text
>>>> install-environment pkufarm212 env_root_6.38.04
Installing environment 'env_root_6.38.04' on 'pkufarm212'...
Environment 'env_root_6.38.04' is ready at .../environments/<project_uuid>/env_root_6.38.04.
>>>> runner-environments pkufarm212
Conda environments on 'pkufarm212' (1):
  env_root_6.38.04      .../environments/<project_uuid>/env_root_6.38.04
```

本例使用：

```yaml
environment: env_root_6.38.04
```

任务中的环境名称应与项目安装到 Runner 上的逻辑环境名称一致。

### 4.2 设置默认环境

为了避免每次创建新任务时都手动指定相同的环境，可以修改用户配置。

在 Celebi 终端中运行：

```text
>>>> user-config
```

其中比较重要的配置项包括：

```yaml
# 新任务默认使用的 Runner
default_runner: pkufarm212

# 是否自动下载任务输出
auto_download: true

# 是否在远程 Runner 上缓存结果
cache_on_runner: true

# 新任务默认使用的 Conda 环境
task_environment: env_root_6.38.04
```

修改并保存配置后，新创建的任务将继承这些默认设置。

## 5. 配置 Runner

**Runner（运行节点）** 是负责执行分析任务的远程计算资源。

### 5.1 启用远程缓存

运行：

```text
>>>> cache-on-runner on
```

启用缓存后，任务结果可以保留在远程 Runner 上。

在工作流支持结果复用的情况下，这有助于减少不必要的数据传输和重复计算。

### 5.2 指定 Runner

如果任务尚未配置 Runner，可以执行：

```text
>>>> request-runner pkufarm212
```

这会将任务关联到指定的远程运行节点。

## 6. 检查工作流

提交任务之前，可以先检查任务配置：

```text
>>>> ls
```

示例输出：

```text
DITE: [connected]

README:
Please write README for task filter0

o--> Predecessors:
[0] (task)       raw_data: @/TestData

---- Task files:
filter0.py

Environment: env_root_6.38.04
Memory limit: 256Mi
Validated: True
Request runner: pkufarm212
Request cache: True

---- Commands:
python3 filter0.py
```

需要重点检查：

- 输入数据是否正确连接。
- Python 程序是否包含在任务文件中。
- 运行环境是否正确。
- Runner 是否已经配置。
- 任务配置是否通过验证。

其中，`Validated: True` 表示任务通过了配置验证，但并不保证分析程序在实际运行时一定不会出错。

## 7. 提交和监控任务

### 7.1 提交任务

确认配置无误后，运行：

```text
>>>> submit --runner pkufarm212
```

Celebi 会将工作流提交到远程服务器执行。

### 7.2 查看任务状态

使用：

```text
>>>> status
```

任务运行过程中，可能显示：

```text
Status of : filter0_task
Impression: [9017b6082037087e287fa89b76caca7b]
DITE: [connected]

Job status: [in movement][running]
Details: Executing workflow steps

**** Workflow:
Workflow: [pkufarm212][494f0f6c61b34204b2e8910404c772e9]

Stageout files:
    (nothing to show yet — run 'collect',
     or the runner may be unreachable)
```

其中，`Job status: [in movement][running]` 表示任务正在执行。

`Impression` 用于标识特定的任务版本，`Workflow` 后面的标识符用于区分工作流执行实例。不同执行对应的标识符可能不同。

### 7.3 查看运行日志

查看日志：

```text
>>>> log
```

实时查看日志：

```text
>>>> log -f
```

日志可以帮助排查 Python 异常、输入文件缺失、环境配置问题以及运行时错误。

### 7.4 查看已完成的任务

任务成功执行后，再次运行：

```text
>>>> status
```

示例输出：

```text
Status of : filter0_task
Impression: [9017b6082037087e287fa89b76caca7b]
DITE: [connected]

Job status: [coda][finished]
Details: Remote execution completed

**** Workflow:
Workflow: [pkufarm212][494f0f6c61b34204b2e8910404c772e9]

Stageout files:
    NAME                       SIZE       TYPE   IN YUKI
    24r1_down_cut0.root        758.7 MB   data   ✗
    24r1_up_cut0.root            1.2 GB   data   ✗
    25c1_down_cut0.root        135.6 MB   data   ✗
    25c1_up_cut0.root          555.9 MB   data   ✗
    25c2_down_cut0.root          1.3 GB   data   ✗
    25c3_up_cut0.root          867.2 MB   data   ✗
    25c4_down_cut0.root        328.7 MB   data   ✗
    25c4_up_cut0.root          442.7 MB   data   ✗
```

其中：

- `[coda][finished]`：表示远程任务已经执行完成。
- `Stageout files`：列出任务生成的输出文件。
- `IN YUKI`：表示输出文件是否已经在本地 Yuki 环境中可用。

**远程计算完成，并不意味着所有输出文件都已经下载到本地。**

如果需要收集任务结果，可以运行：

```text
>>>> collect data
# 或收集所有类别:
>>>> collect all
```

不带参数的 `collect` 只下载图片与日志。ROOT 等数据输出请使用
`collect data`;所有类别一起收集则使用 `collect all`。

对于大型 ROOT 文件，将结果保留在远程 Runner 上可以避免不必要的本地数据传输。

## 8. 可视化工作流

Celebi 可以生成**有向无环图（Directed Acyclic Graph, DAG）**，用于展示任务之间的依赖关系。

运行：

```text
>>>> draw-dag
```

生成的图像可以直观展示数据对象和处理任务之间的关系。

![Celebi 工作流 DAG 示例](https://github.com/user-attachments/assets/8528a658-381c-43e8-82e1-692ccbd70f72)

### 安装 Graphviz

如果尚未安装 Graphviz，可以在 **WSL 终端**中执行：

```bash
sudo apt update
sudo apt install graphviz
```

Graphviz 用于绘制工作流依赖关系图。

## 9. 总结

一个典型的 Celebi 分析流程如下：

```text
本地计算机（WSL / Yuki）
    |
    |-- 初始化项目
    |-- 注册远程数据
    |-- 创建分析任务
    |-- 编写 Python 程序
    |-- 配置运行环境和 Runner
    |
    v
通过 Celebi 提交任务
    |
    v
远程服务器（pkufarm212）
    |
    |-- 访问输入数据
    |-- 执行分析程序
    |-- 生成输出文件
    |-- 缓存计算结果
    |
    v
查看任务状态和运行日志
    |
    v
按需收集输出文件
```

这种工作流的主要优势在于实现了**本地开发与远程计算的分离**。

我们可以在本地开发和管理分析程序，而将大型数据集、中间文件以及计算密集型任务保留在远程服务器上。

这样就不需要在本地存储和管理大量中间文件，只需要专注于分析代码的开发和维护。

**如何在不下载完整文件的情况下直接预览中间结果，将在后续教程中介绍。**
