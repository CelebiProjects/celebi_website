---
title: "Runner(执行器)"
weight: 6
summary: "执行 impression 的 REANA、native、SSH 与 IHEP 后端。"
---

仓库里已经有代码和 impression 了,为什么还要外部 runner?因为 impression 应该能
**灵活地运行**:一部分工作在本机,一部分在 HTCondor 上,等等。而且正在运行的
工作流绝不应该阻塞你的开发。

![runner 如何执行一个节点](/images/concepts/runner.png)

## Runner 后端

- **REANA** —— 在 REANA 集群上执行容器化工作流。
- **native** —— host agent 在与 Yuki 共享存储目录的机器上执行 Snakemake 与
  Conda 工作流。
- **SSH** —— 在远程 SSH 主机上暂存并执行工作流。
- **IHEP** —— 通过 SSH 暂存,并在 IHEP 集群上通过 `hep_sub` 提交作业。

注册方式、项目环境和各后端要求见 [Runner 与环境](/zh/guide/runners-and-environments/)。

## runner 的工作方式

1. 解析依赖关系。
2. 复制前驱节点(代码,以及前驱节点的 `stageout` 目录)。
3. 在请求的环境中运行命令。
4. 取回输出(经由 [Yuki](/zh/concepts/yuki/))。

多个任务可以用一个动作提交 —— 例如在某个目录中执行 `submit`,就等于在它所有
子节点中执行。
