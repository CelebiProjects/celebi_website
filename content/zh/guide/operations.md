---
title: "运维与恢复"
weight: 6
summary: "监控和恢复工作流,维护存储,发布 bookkeeping,并运维 Yuki。"
---

## 监控与停止工作流

```sh
celebi-cli submit --runner RUNNER --timeout 300
celebi-cli status --wait --poll-interval 5
celebi-cli log 0 --follow
celebi-cli engine-logs --fetch
```

提交 timeout 是 HTTP/SSH 操作超时,不是工作流运行时限。超时的请求仍可能已经到达
Yuki,再次提交前先检查 `status`。当前任务中运行的 impression 用 `cancel` 取消。

处理陈旧或脱离项目的状态:

```sh
celebi-cli sync-live
celebi-cli purge-stale-workflows RUNNER --dry-run
celebi-cli stop-orphaned-workflows RUNNER --dry-run
celebi-cli stop-workflow WORKFLOW_UUID
```

清理前先预览。`stop-workflow` 是针对已知僵尸 workflow UUID 的定向退出手段。

## Cache 与 impression 维护

```sh
celebi-cli purge-stale-cache RUNNER --dry-run
celebi-cli impression-stats
celebi-cli gc-impressions                 # 只预览
celebi-cli gc-impressions --execute
celebi-cli pack-impressions
celebi-cli migrate-impressions --dry-run
```

purge 命令使用项目已同步的 live 集合。未知 impression 被视作 live,因此
`sync-live` 失败不会让删除更激进。检查 dry-run 输出后再使用执行或 prune 选项。

## 发布 Bookkeeping

Celebi bookkeeping 发布可共享的 Git 状态,以及符合条件、已经收集的图片和 UTF-8
文本结果。它与旧的 REANA booking 命令不同。

```sh
celebi-cli register-celebi-server \
  --server http://bookkeeping-host:3320 \
  --token ANALYSIS_TOKEN \
  --yuki http://yuki-host:3315

celebi-cli bookkeep --commit "Publish fit results" --tag v1
```

发布前先收集结果。`--allow-partial` 允许结果 archive 不完整;收集完成后不创建新
tag 再次运行即可补传。凭据保存在 Git 排除的本地配置中。

## Celebi-aware Git 操作

```sh
celebi-git enable
celebi-git status
celebi-git hooks --install
celebi-git validate
celebi-git merge BRANCH --strategy interactive
```

merge wrapper 会验证 Celebi 元数据并重建 impression。用 `--dry-run` 先检查计划。

## Yuki 服务命令

```sh
yuki server status
yuki native-runner status
yuki native-runner logs
yuki impression-export UUID --project-uuid PROJECT_UUID -o backup.tar.gz
yuki impression-import backup.tar.gz --project-uuid PROJECT_UUID
yuki env-map list
yuki purge-ssh-runner-cache --help
```

计划停机时使用 `yuki server stop` 与 `yuki native-runner stop`。`env-map` 用于维护
兼容映射;新工作流优先使用项目级 `.celebi-env` 安装。
