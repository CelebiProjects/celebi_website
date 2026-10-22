---
title: "Yuki"
weight: 5
summary: "中间件(DITE):排队操作、分派作业、掌管数据。"
---

**Yuki** 是 Celebi 系统的中间件 —— *Data Integration Thought Entity*(DITE)。
用户只需要操作仓库;作业提交由 Yuki 管理,它把 impression 翻译成 Snakemake
工作流,并通过 REANA、native、SSH 或 IHEP 后端分发给
[runner](/zh/concepts/runner/)。

![Yuki 中间件与工作流 runner](/images/concepts/yuki.png)

## 为什么需要中间件?

没有它,仓库就要直接与远程 runner 服务器通信 —— 这可能非常慢。Yuki 可以同时
**排队多个操作**(提交作业、查询状态等),远程执行绝不会阻塞你的开发。
仓库与 Yuki 之间通过 HTTP 通信,所以应让 Yuki 与本地仓库保持良好的连接。

## 数据存储

Yuki 跟踪每份结果所在的位置。已收集的结果存入 Yuki Storage;SSH/IHEP 的输出在
收集或迁移前也可能只存在于 runner cache 或 workflow workspace。native 的
stage-out 则直接进入 Yuki Storage。仓库通过 impression UUID 引用结果,从而保持
代码、参数、输入与输出之间的对应关系。
