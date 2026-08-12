---
title: "Runner(执行器)"
weight: 6
summary: "REANA、本地或 ssh —— 可互换的 impression 执行后端。"
---

仓库里已经有代码和 impression 了,为什么还要外部 runner?因为 impression 应该能
**灵活地运行**:一部分工作在本机,一部分在 HTCondor 上,等等。而且正在运行的
工作流绝不应该阻塞你的开发。

![runner 如何执行一个节点](/images/concepts/runner.png)

## 三种 runner

- **REANA runner** —— 最稳健的一种,在容器化环境中运行。
- **本地 runner** —— 在 Yuki 所在的机器上运行。
- **ssh runner** —— 作业提交到一台 ssh 机器。

后两种的可复现性不如容器化的 REANA 执行。

## runner 的工作方式

1. 解析依赖关系。
2. 复制前驱节点(代码,以及前驱节点的 `stageout` 目录)。
3. 在请求的环境中运行命令。
4. 取回输出(经由 [Yuki](/zh/concepts/yuki/))。

多个任务可以用一个动作提交 —— 例如在某个目录中执行 `submit`,就等于在它所有
子节点中执行。
