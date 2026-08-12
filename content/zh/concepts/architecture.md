---
title: "Architecture(架构)"
weight: 1
summary: "代码与元数据仓库,加上负责执行工作流的生产工厂。"
---

Celebi 系统由两半组成:

![Celebi 系统总览](/images/concepts/architecture.png)

- **Celebi Repository(仓库)** —— 代码与元数据仓库。它包含工作流系统(代码、
  环境与参数,以[物化工作流](/zh/concepts/materialized-workflow/)的形式组织)
  和版本系统([Impression](/zh/concepts/impression/) —— 每个工作流节点的快照)。
- **Production Factory(生产工厂)** —— [Yuki](/zh/concepts/yuki/) 负责编排
  工作流与输入,把作业分派给外部 [runner](/zh/concepts/runner/)(如 REANA),
  并取回结果。

## 设计原则

1. **严格禁止手工操作数据** —— 一旦手动动过数据,就再也无法确切知道它是如何产生的。
2. **代码仓库保持干净** —— 不对数据做版本管理,否则目录会膨胀爆炸。
3. **过期结果及时清理** —— 需要时可以通过时光机(impression)取回。
4. **代码的任何改动都可检测。**
5. **每个数据的状态可知** —— 随时可以判断数据是否有效。
