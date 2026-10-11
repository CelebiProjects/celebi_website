---
title: "扩展 Celebi 工作流"
weight: 2
summary: "通过连接多个任务及管理任务依赖关系，扩展已有的 Celebi 分析工作流。"
---

# 扩展 Celebi 工作流

本教程介绍如何扩展已有的 **Celebi 工作流**，在上一教程创建的 `filter0` 任务之后添加第二个筛选任务 `filter1`。

同时，我们还将介绍如何在 Celebi 项目中安全地重命名、移动和组织任务。

通过连接多个任务，我们可以构建更长、更复杂的分析工作流，同时将分析代码保留在本地，将中间数据存储在远程服务器上。

## 1. 创建新的筛选任务

在上一教程创建的项目中，进入项目根目录并创建新任务：

```celebi
>>>> create-task filter1
>>>> cd filter1
```

在 `filter1` 目录中创建 Python 程序 `filter1.py`。

随后配置其 `celebi.yaml` 文件：

```yaml
descriptor: filter1
environment: env_root_6.38.04
memory_limit: 256Mi

commands:
  - python3 filter1.py
```

新任务将对 `filter0` 的输出结果进行进一步处理。

## 2. 连接任务

### 2.1 添加上游任务作为输入

在 `filter1` 目录中执行：

```celebi
>>>> add-input ../filter0 data_filter0
```

这将在两个任务之间建立依赖关系：

```text
Raw Data
   |
   v
 filter0
   |
   v
 filter1
```

其中：

- `../filter0` 指向上游任务 `filter0`。
- `data_filter0` 是 `filter1` 使用的输入别名。

这样，`filter0` 的输出就成为了 `filter1` 的输入。

### 2.2 输入和输出目录

从 `filter1.py` 的角度来看，相关路径如下：

| 用途 | 目录 |
|---|---|
| 来自 `filter0` 的输入 | `data_filter0/stageout/` |
| `filter1` 的输出 | `stageout/` |

例如：

```python
import ROOT
from pathlib import Path

input_file = ROOT.TFile.Open("data_filter0/stageout/output.root")

Path("stageout").mkdir(exist_ok=True)
output_file = ROOT.TFile("stageout/filtered.root", "RECREATE")

# 在这里添加筛选代码

output_file.Close()
input_file.Close()
```

其中，`output.root` 需要替换为 `filter0` 实际生成的输出文件名。

**注意：** Celebi 会自动管理任务之间的数据连接，因此不需要手动下载和传输不同处理步骤之间的中间文件。

## 3. 配置并运行任务

### 3.1 配置 Runner

启用远程缓存并指定运行节点：

```celebi
>>>> cache-on-runner on
>>>> request-runner pkufarm212
```

为了避免每次创建新任务时都重复设置，可以按照上一教程介绍的方法，通过 `user-config` 配置默认参数。

### 3.2 检查任务配置

执行：

```celebi
>>>> ls
```

输出中应包含类似以下的信息：

```text
o--> Predecessors:
[0] (task)       data_filter0: @/filter0

Environment: env_root_6.38.04
Cache on runner: True
Default runner: pkufarm212
```

检查前驱任务是否正确连接，以及运行环境和 Runner 是否符合预期。

### 3.3 提交任务

将 `filter1` 提交到远程 Runner：

```celebi
>>>> submit --runner pkufarm212
```

Celebi 会根据任务依赖关系图确定执行当前任务所需的上游结果。

如果某个上游结果不存在，或者需要重新生成，工作流可能需要重新执行相应的上游任务。

如果已有有效的缓存结果，Celebi 则可以直接复用，避免不必要的重复计算。

使用以下命令监控任务执行：

```celebi
>>>> status
>>>> log -f
```

## 4. 可视化扩展后的工作流

运行以下命令，生成任务依赖关系图：

```celebi
>>>> draw-dag-graphviz
```

生成的图像展示了数据从原始输入经过各个筛选任务的处理流程。

![扩展后的 Celebi 工作流](https://github.com/user-attachments/assets/77211ea5-9418-4e06-82a0-fd3a36e300e7)

通过类似的方法，我们不仅可以构建更长的串行处理流程，还可以设计结构更加复杂的**有向无环图（Directed Acyclic Graph, DAG）**工作流。

一个任务可以具有多个输入和依赖关系，不同的处理分支可以独立运行，并在后续步骤中合并结果。

每个任务都可以使用独立的 Python 程序、运行环境和输入依赖关系，因此能够灵活地设计适用于复杂物理分析的工作流。

**注意：** Celebi 使用 Impression 标识特定版本的任务配置及其依赖关系。

提交工作流时，如果已有结果仍然有效，Celebi 可以复用这些结果，而不必重新执行所有处理步骤。当相关任务或其依赖关系发生变化时，Celebi 会根据需要生成新的 Impression。

## 5. 管理任务和目录

随着工作流规模不断扩大，合理管理项目的目录结构变得越来越重要。

**重命名或移动已经注册的任务时，必须使用 Celebi 提供的命令。**

直接在 IDE 或文件管理器中修改任务目录的名称或位置，可能破坏 Celebi 维护的任务依赖关系。

### 5.1 重命名任务

例如，要将 `filter0` 重命名为 `filter`，可以在项目根目录执行：

```celebi
>>>> mv filter0 filter
```

其中：

- `filter0` 是原来的任务名称。
- `filter` 是新的任务名称。

不要直接在 VS Code 或其他 IDE 中重命名已经注册的任务。

### 5.2 创建目录

为了更好地组织大型分析项目，可以使用标准 Linux 命令创建目录：

```celebi
>>>> mkdir filters
```

这些目录可以用于组织具有相似功能的任务。

### 5.3 将任务移动到目录中

例如，将任务 `Raw` 移动到 `filters` 目录：

```celebi
>>>> mv Raw filters/
```

移动后的项目结构如下：

```text
B02K3pi/
├── filters/
│   └── Raw/
├── filter0/
└── filter1/
```

同样，当需要将任务移出某个目录、移动整个目录或重新组织项目结构时，也应该使用 Celebi 的 `mv` 命令。

### 5.4 注意事项

管理 Celebi 项目时，需要注意：

- **使用 Celebi 的 `mv` 命令**重命名或移动已注册的任务和目录。
- 不要直接在 IDE 中修改已注册任务的位置。
- 使用 `mkdir` 创建用于组织任务的目录。
- 使用 `draw-dag-graphviz` 检查工作流结构是否仍然正确。

如果遇到意外的依赖关系或配置问题，可以联系 Celebi 维护者 Mingrui Zhao（mingrui.zhao@mail.labz0.org）。

## 6. 总结

通过将一个任务的输出连接到另一个任务的输入，我们可以不断扩展 Celebi 工作流。

其中最重要的命令是：

```celebi
>>>> add-input ../filter0 data_filter0
```

该命令在任务之间建立依赖关系，同时允许每个处理步骤独立开发。

这种工作流的主要优势包括：

- **模块化：** 每个任务负责一个独立的分析步骤。
- **自动管理依赖关系：** Celebi 自动追踪不同任务之间的依赖关系。
- **远程数据处理：** 大型中间文件保留在服务器上，无需手动传输。
- **结果复用：** 利用缓存结果避免不必要的重复计算。
- **灵活组织：** 可以通过 Celebi 命令对任务进行分组和重新组织。

利用这些功能，我们可以逐步将简单的数据筛选任务扩展为完整的物理分析工作流。

下图展示了一个典型的 Celebi 工作流：

![典型 Celebi 工作流](https://github.com/user-attachments/assets/64666f55-3a7b-48a5-8bed-cf4cd98fe3dd)

通常，**位于同一目录中的任务会在工作流图中以相同的颜色显示**，便于区分不同的任务组及其组织结构。
