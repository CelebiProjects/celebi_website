---
title: "任务与算法的状态"
weight: 2
summary: "本地 new/impressed 两层状态,以及提交后 DITE 上以音乐命名的作业状态体系。"
---

Celebi 中每个对象的状态分**两层**:磁盘上的**本地状态**(由 impression 系统决定),
以及提交后 DITE(Yuki)上的**远端作业状态**。

## 本地状态:new 与 impressed

任务与算法的本地状态只有两种:

| 状态 | 含义 |
|---|---|
| `new` | 还没有 impression,或内容在最近一次 impression 之后发生了变化 |
| `impressed` | 当前内容已被某个 impression 完整记录 |

印象是**内容寻址**的:impression 由项目 UUID、所有前驱 impression 与对象内容
唯一决定。因此:

- 你改动了对象里任何会影响结果的文件(代码、`celebi.yaml`、参数),它就变回 `new`;
- 改动 `README.md` **不会**影响状态 —— 印象本来就不包含 README;
- 如果某个**前驱**是 `new`,那么你也是 `new` —— 状态沿依赖图向下游传播,上游任何
  改动都会让所有受影响的下游对象回到 `new`。

### 如何查看

在 Celebi shell 中进入对象后运行 `status`:

```text
>>>> status
Status of : /FitTask
Impression: [imp3f2a1c]
DITE: [connected]
...
```

如果还没有 impression,则显示:

```text
Impression: [new]
```

也可以用 `ls --status` 在列表里直接看到每个子对象的状态标签。

在 `status` 输出中,`Impression: [imp...]` 里显示的是对象**当前** impression 的
UUID 前几位 —— 提交、查询作业状态都以它作为句柄。

## 远端状态:DITE 上的作业状态

任务被 `impress` 后,它的 impression 会**存入 DITE(deposit)**。如果还没存,
`status` 会提示:

```text
Impression not deposited in DITE
```

此时运行 `impress` 即可完成封存与上传。之后用 `submit` 提交任务,DITE 会为这个
impression 创建**作业(job)**,作业在 runner 上执行时状态不断流转。

### 状态名:大状态与细分状态

Yuki 的作业状态是一组成对的名字,客户端显示为 `[大状态][细分状态]` 的形式:

- 第一个方括号是**音乐隐喻命名的大状态**,表示作业所处的粗粒度阶段;
- 第二个方括号是**细分状态**,给出该阶段内更精确的状态。

实际运行时,状态来自两条路径:

**构建阶段** —— Yuki 把工作流交给后端之前,直接以音乐名写入大状态:

| 大状态 | 细分状态(显示) | 何时出现 |
|---|---|---|
| `silence` | `raw` | 初始状态;或依赖未完成、被重置回初始 |
| `prelude` | `waiting` | 作业已排队;正在构建工作流(1/3 → 3/3) |
| `tuning` | `ready` | 算法作业就绪待配置 —— 准备算法组件、配置参数与依赖(仅算法作业) |
| `orchestrating` | `built` | 与后端交互:创建工作流、上传依赖、启动(REANA) |
| `dissonance` | `failed` | 工作流**构建**失败 —— 尚未真正开始执行 |

其中 `tuning` 只用于算法作业:算法作业的细分状态显示为 `ready`,表示算法组件
已就绪、等待配置。

**作业尚未在 DITE 上创建时** —— 状态查询还会返回两个特殊状态:

| 状态 | 含义 |
|---|---|
| `empty` | 该 impression 在 DITE 上还没有作业记录(作业对象类型为空)—— 一般意味着还没有 submit 过 |
| `deposited` | 数据已存入 DITE("Data has been deposited"),但作业状态未知 —— 尚未进入真正的执行流程 |

**执行阶段** —— 作业跑起来后,后端(REANA / native / ssh)回报细分状态,
系统原样落盘,显示时再翻译成大状态:

| 细分状态(后端回报) | 大状态(显示) | 含义 |
|---|---|---|
| `created` / `queued` / `pending` / `running` | `in movement` | 后端正在(或排队等待)执行 |
| `finished` | `coda` | 全部步骤成功完成 |
| `failed` | `failed` | 后端执行失败 |
| `stopped` / `deleted` | `stopped` / `deleted` | 被停止或删除(来自后端) |

`dissonance` 与 `failed` 的区分很重要:前者是**工作流拼不起来**(依赖缺失、
Snakefile 生成失败等),任务从未真正开跑;后者是**跑起来了但执行出错**。

**注意**:常量表里还定义了 `composing`、`final note` 等状态,但当前代码路径
并没有实际使用它们(`composing` 只会作为 REANA `created` 状态的翻译出现在
显示里);`in movement` 与 `coda` 也不会落盘 —— 完成的任务落盘的是
`finished`,运行中的落盘的是 `running` 等细分名,`[in movement]` / `[coda]`
只是显示时由细分状态翻译出的大状态档位。

客户端显示时还会把相近的细分状态归并:

- `created / queued / pending / running` 统一显示为 `[in movement]`;
- `finished` 显示为 `[coda]`;
- `prelude / orchestrating` 的细分档显示为 `[undecided]`。

例如一个成功完成的工作流会显示 `[coda][finished]` —— 大状态 `coda`(成功
收尾),细分状态 `finished`(已完成),并附带一行 `Details: ...` 详细状态信息
(当前步骤、错误原因等)。

### 目录与项目的聚合状态

在**目录或项目**上运行 `status`,Celbi 会聚合所有子对象:

- 任一子任务失败 → 聚合结果为 `failed`;
- 否则有任一子任务未完成 → `pending`;
- 全部完成 → `finished`。

聚合时会跳过算法对象(算法本身不执行)。所以你可以站在项目根目录用一条
`status` 命令俯瞰整个工作流的进展。

## 算法状态的特殊之处

- **算法不会自己运行** —— 可执行的单元是任务。算法只有本地 `new` / `impressed`
  状态,以及它是否已被某次提交使用。
- 任务执行时,算法以 impression 的形式被引用(任务内部 `code -> ...` 符号链接),
  因此算法的状态变化会自动传播到所有使用它的任务:改了算法,相关任务全部回到
  `new`,需要重新 impress 与 submit。
- 对算法运行 `status`,如果对应的 impression 上没有工作流定义,会显示:

  ```text
  Workflow not defined
  ```

  这通常意味着还没有任务用它提交过作业。
