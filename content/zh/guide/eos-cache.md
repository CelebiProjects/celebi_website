---
title: "EOS 缓存统计与清理"
weight: 31
guide_group: "core-data"
summary: "通过 REANA 小作业统计项目用量、预览清理并独立复查。"
---

需要 CelebiChrono 和 Yuki `1.1.2b1`。客户端和 Yuki 主机无需直接访问 EOS；
注册的 REANA runner 需要配置 EOS 根目录，并在作业中提供挂载和 Kerberos 凭据。
本功能只处理 Celebi 管理的 EOS 缓存，不统计任意数据集、REANA workspace、
本地 CAS 或已经收集到 Yuki 的副本。

## 查看用量

```sh
celebi-cli eos-usage cern --all-projects
celebi-cli eos-usage cern --all-projects --no-wait
celebi-cli eos-usage --scan-id SCAN_ID --json
```

- **live**：有效同步集合中的 impression，或非终态 workflow 仍引用的数据。
- **non_live**：有效同步集合明确标记为被替代，且没有已知活动引用。
- **unknown**：live 信息缺失或超过 24 小时、归属不明、测量不完整等情况。

当前项目扫描会先同步 live 集合；全项目扫描前，可在其他项目运行
`celebi-cli sync-live`。历史列表中有记录不代表仍然 live。
大小是普通文件的逻辑字节数，不含 EOS 副本开销。权限错误等会使报告不完整，
此时已测得大小只是下界。查询已完成的扫描只重新分类，不重新测量文件大小。
旧式平铺目录只有在能够唯一确认项目归属时才计入对应项目。

## 预览与执行

```sh
# 默认只预览 non-live
celebi-cli eos-cleanup cern --all-projects
# 同时选择有明确项目归属的 unknown 缓存
celebi-cli eos-cleanup cern --all-projects --include-unknown
# 确认清单后执行
celebi-cli eos-cleanup --plan-id PLAN_ID --execute
# 查询原计划进度及复查结果
celebi-cli eos-cleanup --plan-id PLAN_ID
```

清理命令会刷新匹配的本地项目的 live 信息。找不到本地 checkout 的项目使用
已有信息，缺失或过期时保留 unknown 分类。`--clear-project PROJECT_UUID`
在新预览中显式选中该项目全部缓存，包括 live；仅在需要清空整个项目时使用。
无法归属的目录始终跳过，项目内未知布局条目只有明确整项目清空时才包含。
`--yes` 仅搭配 `--execute` 跳过确认，不扩大范围。`tidyup` 也提供此操作。

计划要求 24 小时内的完整扫描和元数据指纹。执行前重新校验 live、归属、runner
及文件信息；项目有活动 REANA workflow 时拒绝提交。删除与复查完成前应避免
启动新的分析工作流，因为这不是原子的文件系统事务。
删除 REANA workflow 本身不会删除 EOS 缓存。

清理后会提交独立只读 REANA 作业，复查目标消失且受保护目录存在。残留或校验
错误报告为部分完成，不自动重试。客户端超时不代表删除被取消，应继续查询原
`PLAN_ID`，不要重新创建清理任务。复查也只是特定时刻的观察。

## 服务升级

升级两个组件后重载 Yuki HTTP 服务。扫描和计划分别保存在
`$YUKIDIR/eos-usage` 与 `$YUKIDIR/eos-cleanup`。旧扫描如果没有元数据指纹，需
重新扫描后才能清理。安装或升级本身不会提交删除作业。
