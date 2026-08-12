---
title: "面向 Claude Code 的 Celebi skills 发布"
date: 2026-03-03
summary: "一套让 Claude Code 自主浏览 Celebi 项目、创建对象并运行工作流的技能集合。"
---

`celebi-skills` 是面向 [Claude Code](https://claude.com/claude-code) 的 AI 辅助分析技能集合,包含:

- 浏览项目结构(`tree`、`ls`)
- 创建任务与算法
- 提交与监控工作流
- 调试与修正已有组件
- 查看日志、获取输出文件

安装方式:

```sh
npx skills add CelebiProjects/celebi-skills --skill '*' -g -y
```
