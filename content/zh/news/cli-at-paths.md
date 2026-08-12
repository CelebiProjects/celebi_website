---
title: "CLI:支持项目根目录 @/ 路径与 Tab 补全"
date: 2026-07-09
summary: "任务配置命令现在可以解析相对于项目根目录的 @/ 路径,并支持 shell Tab 补全。"
---

Celebi shell 现在将 `@/` 识别为项目根目录的别名:

- 所有任务配置命令均可解析 `@/` 路径。
- `@/` 路径支持 Tab 补全,深层对象路径输入更快捷。
- 本次更新包含完整的路径解析测试。

```sh
celebi> configure @/analysis/selection --param threshold=0.9
```
