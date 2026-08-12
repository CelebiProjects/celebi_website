---
title: "Impression(快照)"
weight: 4
summary: "每个工作流节点的不可变、由内容唯一决定的快照。"
---

**Impression(快照)** 是任务或算法的**不可变快照**。它由以下三者**唯一决定**:

- 项目 UUID;
- 所有前序 impression;
- 对应任务或算法的内容。

![impression 系统记录项目的全部历史](/images/concepts/impression.png)

从 impression 的视角看,它是一个隔离的组件,只能看到与它连接的对象:

```text
imp8c340c/
├── contents/     # 自身的内容
├── code -> ...   # 指向算法 impression 的符号链接
├── inputname -> ...  # 指向前驱任务 impression 的符号链接
└── stageout/     # 用于存放输出的空目录
```

impression 系统通过这些连接记录项目的**完整历史**。

## 特性

- **在不版本化数据的前提下版本化数据** —— impression 不存数据集本身,而是记录
  精确的执行来源:代码哈希、输入与参数状态。
- **一旦创建不可更改** —— 因此它产出的结果可信、可靠。
- **不包含 README.md** —— 只有会影响结果的文件才被封存,所以跑完任务后你可以
  随意打磨文档。

```sh
celebi-cli make-impression "preselection v1"
```
