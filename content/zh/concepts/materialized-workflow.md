---
title: "Materialized workflow(物化工作流)"
weight: 3
summary: "每个工作流节点都是磁盘上的真实文件夹 —— 而不是描述文件里的抽象步骤。"
---

在传统工作流语言中,工作流节点是定义在工作流描述文件里的抽象概念。而在 Celebi
中,**每个工作流节点都是磁盘上的一个文件夹**,用 `create-task [name]` 或
`create-algorithm [name]` 创建。

![示例工作流与节点](/images/concepts/materialized.png)

- **Algorithm(算法)** —— 可复用、自包含的一段代码或脚本,是任务的模板。
- **Task(任务)** —— 可运行组件的代理,包含参数等。多个任务可以共享同一个算法。

**物化(Materialized)** 的含义是:工作流节点真实存在于磁盘上,而不像大多数
工作流语言那样只是概念上的步骤。

## 数据–代码绑定

这个设计来自一个关键认识:*我们不需要把数据当作工作流中的节点* —— 所有数据
都有生成它的对应代码。受 Docker 镜像/容器的启发,每个任务都 “包含” 它的数据:
节点产出的数据,通过 [impression](/zh/concepts/impression/) 与产生它的精确代码
和参数绑定在一起。
