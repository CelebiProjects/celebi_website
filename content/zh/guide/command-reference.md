---
title: "命令参考"
weight: 3
summary: "Celebi 交互式 shell、单次 CLI 与 Git 命令的分类速查。"
---

Celebi 有三个入口:`celebi` 进入可持续切换对象的交互式 shell,
`celebi-cli COMMAND` 执行适合脚本调用的单次操作,`celebi-git COMMAND`
专门提供 Git 集成。下表默认使用 shell 与 `celebi-cli` 共用的正式命令名;
仅适用于 shell 的命令会特别注明。方括号 `[ ]` 表示可选参数。

在 `celebi` 内,裸 `helpme` 会根据当前对象给出建议。以下三种写法显示同一份详细帮助:

```text
help status
helpme status
status --help
```

在 shell 外使用 `celebi-cli COMMAND --help`。旧名称仍可兼容调用,并集中列在
`celebi-cli --help` 的 Compatibility aliases 区域。

## 项目与导航

| 命令 | 作用与用法 |
|---|---|
| `init [--project-uuid <uuid>]` | 在当前空目录初始化 Celebi 项目 |
| `list-projects` | 列出所有已注册的项目 |
| `use-project <name>` | 选择下次 `celebi` 打开的项目 |
| `register-project <path> [--new-project]` | 注册已有项目;仅在有意复制项目时生成新 UUID |
| `remove-project <name>` | 只删除注册信息,不删除项目文件 |
| `project-path` | 显示当前项目路径 |
| `project-uuid` | 显示当前项目的 UUID |
| `cd <path>` | 在 `celebi` 内切换目录/对象(仅 shell) |
| `cd-project <name>` | 在 `celebi` 内切换项目(仅 shell) |
| `tree` | 显示目录树结构 |
| `mkdir <path>` | 新建目录对象 |
| `ls` | 列出当前对象:README、子对象与状态标签(支持 `ls --status` 等选项) |
| `short-ls` | 当前对象的简短列表 |

## 创建对象

| 命令 | 作用与用法 |
|---|---|
| `create-algorithm <name>` | 创建算法对象(可复用的计算模板) |
| `create-task <name>` | 创建任务对象(算法的具体实例) |
| `create-multi-tasks <base> <stop> [--start <n>]` | 按 `start <= n < stop` 批量创建编号任务 |
| `create-data <name>` | 创建数据对象 |
| `create-multi-data <path>` | 为路径下每个直接子目录创建并上传一个数据对象 |
| `create-data-list <name>` | 创建数据列表对象 |
| `create-lhcb-ap-list <name>` | 创建 LHCb AP 数据列表任务(动态生成 `dataList.txt`,需自行填写 AP 查询参数) |
| `add-apd-token <token>` | 为当前 LHCb AP 数据列表任务添加 APD token(存入 `.celebi/config.local.json`) |

## 连接对象与参数

| 命令 | 作用与用法 |
|---|---|
| `add-algorithm <path>` | 为当前任务关联算法(任务里将以 `code/` 形式可见) |
| `add-input <path> <alias>` | 为当前任务/算法添加输入,用别名引用(别名系统让重组更安全) |
| `add-multi-inputs <path-base> <alias-base> <stop> [--start <n>]` | 按半开区间批量添加编号输入和别名 |
| `remove-input <alias>` | 移除输入 |
| `remove-multi-inputs <alias-base> <stop> [--start <n>]` | 按半开区间批量移除编号别名 |
| `set-parameter <name> <value>` | 设置任务参数,对应算法命令里的 `${name}` |
| `add-parameter-subtask <dirname> <name> <value>` | 给目录内的指定子任务添加参数 |
| `remove-parameter <name>` | 移除参数 |
| `predecessors` | 列出当前对象的前驱 |
| `successors` | 列出当前对象的后继 |

## 配置与编辑

| 命令 | 作用与用法 |
|---|---|
| `config` | 用默认编辑器打开当前对象的 `celebi.yaml`(不存在则创建模板) |
| `set-environment <env>` | 设置 `script`、容器镜像、项目 Conda 环境名或 LHCb `lb-conda/PACKAGE/DATE` 环境 |
| `user-config [--list]` | 编辑或显示用户级默认值;只复制到之后新建的对象中 |
| `cache-policy [auto\|mtime\|off]` | 显示或设置当前项目的本地缓存失效策略 |
| `set-memory-limit <limit>` | 设置内存上限,如 `256Mi` |
| `set-descriptor <text>` | 设置对象的描述(descriptor) |
| `add-source <path>` | 添加外部源文件/目录到当前对象(参与依赖追踪) |
| `comment <text>` | 给对象添加评论 |
| `edit-readme` | 编辑当前对象的 README |
| `edit <file>` | 编辑脚本文件 |
| `watermark` | 显示对象水印(创建元数据、版本与签名信息) |
| `history` | 显示对象的执行与修改历史 |
| `changes` | 显示对象最近的改动 |

## 印象(Impression)

| 命令 | 作用与用法 |
|---|---|
| `impress [--offline] [--immutable] [--cache-dir <path>]` | 封存当前对象状态;immutable 模式只计算一次固定 DAG |
| `impression` | 获取当前对象的 impression |
| `view [impression]` | 查看当前或指定的 impression |
| `view-url [impression]` | 获取 impression URL |
| `search-impression <prefix>` | 按 UUID 前缀搜索 impression |
| `trace <object>` | 将对象/impression 与记录的依赖 DAG 比较 |
| `draw-dag [output] [--exclude-algorithms]` | 用 Graphviz 绘制依赖 DAG |
| `bookkeep [--commit <message>] [--tag <tag>]` | 向 Celebi bookkeeping server 发布 Git 代码和已收集的小型结果 |
| `bookkeeping-url` | 获取 bookkeeping URL |
| `open-bookkeeping` | 打开 bookkeeping 页面 |
| `purge-impressions` | 清除当前对象的 impression |
| `purge-old-impressions` | 清除旧 impression 数据,只保留近期/关键快照 |
| `doctor` | 系统诊断,检查并修复 repository 的完整性 |

## 执行

| 命令 | 作用与用法 |
|---|---|
| `submit [--runner <name>] [--timeout <seconds>] [--with-unknown]` | 提交当前任务或容器对象执行 |
| `status [--wait] [--poll-interval <seconds>]` | 显示状态并可轮询至终态,详见[任务与算法的状态](/zh/guide/task-and-algorithm-states/) |
| `cancel` | 取消当前任务或目录中正在运行的 impressions |
| `log [index] [--follow]` | 显示用户命令日志,并可持续跟随新输出 |
| `collect [all\|plots\|data\|logs\|<glob>\|<name>] [--allow-failed]` | 收集任务结果;默认收集 plots + logs |
| `engine-logs [--fetch]` | 显示已保存的工作流引擎日志,或从 DITE 获取 |
| `collect-outputs` / `collect-logs` | 只收集输出或日志 |
| `refresh-filelists` | 对终态工作流重新列出 stageout 与日志 |
| `check-results <runner>` | 在 SSH runner 上挂载缓存结果以供检查 |
| `auto-download on\|off` | 开启或关闭结果自动下载 |
| `cache-on-runner on\|off` | 开启或关闭 runner 端结果缓存（对 native 无额外效果） |
| `test [docker\|ssh] [runner]` | 用本地 Docker 或已注册的 SSH runner 测试当前任务 |
| `workaround [--reference <alg>] [--skip-input <task>]` | 在本地模拟环境调试(仅 shell);单次 CLI 的结果查看命令是 `workaround-vre` |

## DITE 与服务器

| 命令 | 作用与用法 |
|---|---|
| `dite` | 显示 DITE 连接信息 |
| `set-dite <url>` | 设置 DITE(Yuki)服务器地址;用 `dite` 查看当前配置 |
| `add-host <host> <port-or-url>` | 注册 communicator 主机,如 `add-host localhost http://127.0.0.1:8080` |
| `hosts` | 列出所有主机及状态 |
| `register-booking-server [--server <url>] [--token <token>]` | 向 Yuki 注册 REANA 服务器与访问 token(缺省读环境变量) |
| `register-celebi-server --server <url> --token <token> [--yuki <url>]` | 保存并验证 Celebi bookkeeping 凭据 |
| `booking-server` | 查看已注册的 REANA 服务器 URL 与状态 |
| `book-reana` | 把当前项目打包上传到 REANA(经 Yuki,流式显示进度) |

## Runner 管理

| 命令 | 作用与用法 |
|---|---|
| `runners` | 列出所有可用 runner 及完整配置 |
| `register-runner <name> <url> <secret> <backend-type>` | 注册 `reana`、`native`、`ssh` 或 `ihep` runner;各后端设置通过选项提供 |
| `request-runner <name>` | 为当前任务指定执行 runner |
| `test-runner <name>` | 探测 runner 能力；native 还会检查 host agent 是否存活 |
| `install-environment <runner> <name> [--file <yaml>]` | 在 SSH/IHEP/native runner 上安装或更新项目专属 Conda 环境；默认读取 `.celebi-env/<name>.yaml` |
| `runner-environments <runner>` | 列出当前项目在 SSH/IHEP/native runner 上的环境 |
| `remove-runner <name>` | 移除 runner |
| `update-runner <name> ...` | 更新 runner 设置(url、token、backend_type、Kerberos、EOS 挂载点等) |
| `yuki-overview` | 汇总 runner 状态、容量与当前资源使用 |
| `refresh-distribution` | 重建当前项目的结果位置登记表 |

项目环境安装在
`<runner-workdir>/environments/<project_uuid>/<environment_name>`，因此不同项目即使
使用相同环境名也不会共享路径。再次运行 `install-environment` 会通过
`conda env update --prune` 更新环境。YAML 中的 `name` 字段不会决定安装路径，也不
记录环境配置哈希：这里把环境视为可信、可变的 runner 状态。Yuki 中显式配置的
`conda_env_map` 仍作为兼容方式保留。
native runner 的工作目录默认是 `~/.Yuki/LocalWorkflows`，工作流状态按
`workflows/<project_uuid>/<workflow_uuid>` 分层。若项目环境尚未安装，提交会提前
失败并给出对应的安装命令。

Native 与 Yuki Storage 属于同一存储域：成功 stage-out 会直接进入 Storage。因此
native 没有独立的托管缓存，也不是 transfer 位置；此时应使用 `yuki`。

## 数据管理

| 命令 | 作用与用法 |
|---|---|
| `upload-data <path>` | 上传本地路径到 DITE |
| `register-ssh-data <runner> <remote-path>` | 把 SSH runner 上的数据注册进 Yuki 托管存储(计算 MD5,后台复制并显示进度) |
| `register-xrootd-data <runner> <root-url> [--checksum auto\|required\|none]` | 不经 Yuki 复制载荷,把 XRootD 样本冻结为 datalist |
| `verify-data` | 校验当前数据任务:重算 MD5 与注册 UUID 对比 |
| `attach-data <uuid> [--path <path>]` | 把 Yuki impression 附加到 rawdata 任务 |
| `whereabouts` | 查看当前结果位于 Yuki Storage 还是 runner cache |
| `transfer <source> <destination>` | 在 `yuki` 与 `runner:<name>` 位置间迁移结果 |
| `cache-results <runner>` | 将当前结果复制到 SSH runner 的托管缓存 |
| `purge-data [--force]` | 删除 Yuki 已收集数据;通常要求另有可恢复副本 |
| `import <path>` | 导入外部文件到当前对象(支持 `/*` 通配导入整个目录) |
| `export <glob>` | 把匹配文件导出到 `project/export/` |
| `remove-file <file>` | 删除对象内的文件 |
| `move-file <src> <dst>` | 移动对象内的文件 |
| `display <file>` | 查看对象内的文件 |
| `cat <file>` | 显示文件内容 |
| `imgcat <file>` | 在终端内联显示图片(来自 DITE) |

## 文件与对象操作

| 命令 | 作用与用法 |
|---|---|
| `cp <src> <dst>` | 复制对象(保留依赖关系与元数据,连接自动接好) |
| `mv <src> <dst>` | 移动/重命名对象(关系与元数据不变,可放心重组) |
| `rm <path>` | 删除对象(会校验以保护项目完整性) |

## 系统与工具

| 命令 | 作用与用法 |
|---|---|
| `system-shell` | 进入系统 bash;`exit` 或 Ctrl-D 返回 Celebi(仅 shell) |
| `danger-call <cmd>` | 直接执行系统命令(仅 shell,慎用) |
| `EOF` | 退出 Celebi shell(仅 shell,同 Ctrl-D) |
| `help` | 列出命令(仅 shell;外部使用 `celebi-cli --help`) |
| `helpme` | 获取对象感知的帮助(仅 shell) |

## 恢复与 impression 存储

| 命令 | 作用与用法 |
|---|---|
| `sync-live` | 将项目的 live impression 集合推送给 Yuki |
| `stop-workflow <uuid>` | 强制停止工作流,包括僵尸运行 |
| `stop-orphaned-workflows <runner>` | 停止项目已不再引用的工作流 |
| `purge-stale-cache <runner> [--dry-run]` | 删除被取代的缓存 impression |
| `purge-stale-workflows <runner> [--dry-run]` | 删除非 live、非运行中的工作流工作区 |
| `gc-impressions [--execute]` | 回收不可达 CAS 对象;默认只预览 |
| `pack-impressions [--force]` | 打包符合条件的 CAS impression 对象 |
| `migrate-impressions [--dry-run] [--prune-legacy]` | 将旧 impression 存储迁移到 CAS 引用 |
| `impression-stats` | 显示 impression 存储统计 |

## Git 集成

以下命令使用独立的 `celebi-git` 入口。

| 命令 | 作用与用法 |
|---|---|
| `celebi-git enable` / `disable` | 为当前项目启用或禁用集成 |
| `celebi-git status` | 显示集成状态与合并准备情况 |
| `celebi-git validate` | 在 Git 操作后验证 Celebi 元数据 |
| `celebi-git hooks --install\|--uninstall` | 管理 Celebi-aware Git hooks |
| `celebi-git merge <branch> [--strategy <mode>]` | 合并并执行 Celebi 校验和 impression 重建 |
| `celebi-git config <key> <value>` | 设置 Git 集成选项 |
