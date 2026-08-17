---
title: "命令参考"
weight: 3
summary: "Celebi shell 全部命令的分类速查:项目导航、对象创建、连接与参数、配置、印象、执行、DITE、runner、数据与文件操作。"
---

以下命令都在 Celebi 交互式 shell 中使用(用 `celebi` 进入)。命令名大小写不敏感,
参数按空格分隔。方括号 `[ ]` 表示可选参数。

## 项目与导航

| 命令 | 作用与用法 |
|---|---|
| `ls-projects` | 列出所有已注册的项目 |
| `cd-project <name>` | 切换到另一个项目 |
| `navigate` | 显示当前项目路径 |
| `project-uuid` | 显示当前项目的 UUID |
| `cd <path>` | 在当前项目内切换目录/对象(支持数字索引与 `@/` 根路径) |
| `tree` | 显示目录树结构 |
| `mkdir <path>` | 新建目录对象 |
| `ls` | 列出当前对象:README、子对象与状态标签(支持 `ls --status` 等选项) |
| `short-ls` | 当前对象的简短列表 |

## 创建对象

| 命令 | 作用与用法 |
|---|---|
| `create-algorithm <name>` | 创建算法对象(可复用的计算模板) |
| `create-task <name>` | 创建任务对象(算法的具体实例) |
| `create-multi-tasks <base> <n>` | 批量创建多个任务 |
| `create-data <name>` | 创建数据对象 |
| `create-multi-data <base> <n>` | 批量创建多个数据对象 |
| `create-data-list <name>` | 创建数据列表对象 |
| `create-lhcb-ap-list <path>` | 创建 LHCb AP 数据列表任务(动态生成 `dataList.txt`,需自行填写 AP 查询参数) |
| `add-apd-token <token>` | 为当前 LHCb AP 数据列表任务添加 APD token(存入 `.celebi/config.local.json`) |

## 连接对象与参数

| 命令 | 作用与用法 |
|---|---|
| `add-algorithm <path>` | 为当前任务关联算法(任务里将以 `code/` 形式可见) |
| `add-input <path> <alias>` | 为当前任务/算法添加输入,用别名引用(别名系统让重组更安全) |
| `input` | `add-input` 的别名 |
| `add-multi-inputs <base> <n>` | 批量添加多个输入 |
| `remove-input <alias>` | 移除输入 |
| `remove-multi-inputs` | 批量移除多个输入 |
| `add-parameter <name> <value>` | 为任务添加参数,对应算法命令里的 `${name}` |
| `add-parameter-subtask <dirname> <name> <value>` | 给目录内的指定子任务添加参数 |
| `remove-parameter <name>` | 移除参数 |
| `predecessors` | 列出当前对象的前驱 |
| `successors` | 列出当前对象的后继 |

## 配置与编辑

| 命令 | 作用与用法 |
|---|---|
| `config` | 用默认编辑器打开当前对象的 `celebi.yaml`(不存在则创建模板) |
| `set-environment <env>` | 设置执行环境:脚本型用 `script`,否则用 Docker 镜像名 |
| `setenv` | `set-environment` 的别名 |
| `set-memory-limit <limit>` | 设置内存上限,如 `256Mi` |
| `set-descriptor <text>` | 设置对象的描述(descriptor) |
| `setdescriptor` | `set-descriptor` 的别名 |
| `add-source <path>` | 添加外部源文件/目录到当前对象(参与依赖追踪) |
| `comment <text>` | 给对象添加评论 |
| `edit-readme` | 编辑当前对象的 README |
| `edit-script <file>` | 编辑脚本文件 |
| `watermark` | 显示对象水印(创建元数据、版本与签名信息) |
| `history` | 显示对象的执行与修改历史 |
| `changes` | 显示对象最近的改动 |

## 印象(Impression)

| 命令 | 作用与用法 |
|---|---|
| `impress [names...]` | 为当前对象(或指定的子对象)创建 impression —— 封存当前状态 |
| `impression` | 获取当前对象的 impression |
| `view` | 查看当前任务的 impressions |
| `viewurl` | 获取 impression 的 URL |
| `search-impression <prefix>` | 按 UUID 前缀搜索 impression |
| `trace` | 追溯生成 impression 的任务/算法(沿依赖图回溯) |
| `draw-dag-graphviz <output> [--exclude-algorithms]` | 用 Graphviz 绘制依赖 DAG(支持 PDF/SVG/PNG) |
| `bookkeep` | 项目级 impression 整理(存储、索引与清理) |
| `bkkurl` | 获取 bookkeeping URL |
| `viewbkk` | 打开 bookkeeping URL |
| `homekeep` | 清理 runner 上的工作流 |
| `clean-impressions` | 清理 impressions(开发者工具) |
| `purge-impressions` | 清除当前对象的 impression |
| `purge-old-impressions` | 清除旧 impression 数据,只保留近期/关键快照 |
| `doctor` | 系统诊断,检查并修复 repository 的完整性 |

## 执行

| 命令 | 作用与用法 |
|---|---|
| `submit [runner] [names...]` | 提交当前对象(或指定子对象)执行;可选指定 runner,如 `submit --runner cern` |
| `jobs` | 显示当前算法/任务的作业信息 |
| `status` | 显示当前对象的状态(本地状态 + DITE 作业状态,详见[任务与算法的状态](/zh/guide/task-and-algorithm-states/)) |
| `kill` | 终止当前对象的执行进程 |
| `log` | 显示当前对象的日志 |
| `collect [all\|plots\|data\|logs\|<glob>\|<name>]` | 收集任务结果;默认收集 plots + logs |
| `engine-logs` | 从 DITE 获取工作流引擎日志 |
| `auto-download` | 开启/关闭结果自动下载 |
| `cache-on-runner` | 开启/关闭 EOS 缓存使用 |
| `test` | 在 Docker 容器中执行测试工作流 |
| `workaround [--reference <alg>] [--skip-input <task>]` | 本地模拟运行环境调试任务,所见即所跑 |

## DITE 与服务器

| 命令 | 作用与用法 |
|---|---|
| `dite` | 显示 DITE 连接信息 |
| `set-dite <url>` | 设置 DITE(Yuki)服务器地址;不带参数则显示当前配置 |
| `add-host <name> <url>` | 注册主机,如 `add-host localhost http://127.0.0.1:8080` |
| `hosts` | 列出所有主机及状态 |
| `register-booking-server [url] [token]` | 向 Yuki 注册 REANA 服务器与访问 token(缺省读环境变量) |
| `booking-server` | 查看已注册的 REANA 服务器 URL 与状态 |
| `book-reana` | 把当前项目打包上传到 REANA(经 Yuki,流式显示进度) |

## Runner 管理

| 命令 | 作用与用法 |
|---|---|
| `runners` | 列出所有可用 runner 及完整配置 |
| `register-runner <name> <url> <secret>` | 向 DITE 注册新 runner |
| `request-runner <name>` | 为当前任务指定执行 runner |
| `test-runner <name>` | 探测 runner 能力(snakemake/conda/workdir) |
| `runner-envs <name>` | 列出 runner 上的 conda 环境(ssh/native) |
| `remove-runner <name>` | 移除 runner |
| `update-runner <name> ...` | 更新 runner 设置(url、token、backend_type、Kerberos、EOS 挂载点等) |

## 数据管理

| 命令 | 作用与用法 |
|---|---|
| `upload-data <path>` | 上传本地路径到 DITE |
| `register-ssh-data` | 把 ssh runner 上的数据注册进 Yuki 托管存储(计算 MD5,后台任务复制,显示字节进度条) |
| `verify-data` | 校验当前数据任务:重算 MD5 与注册 UUID 对比 |
| `attach-data <uuid> [path]` | 把 Yuki impression 附加到 rawdata 任务 |
| `import <path>` / `import-file` | 导入外部文件到当前对象(支持 `/*` 通配导入整个目录) |
| `export <glob>` | 把匹配文件导出到 `project/export/` |
| `rm-file <file>` | 删除对象内的文件 |
| `mv-file <src> <dst>` | 移动对象内的文件 |
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
| `system-shell` | 进入系统 bash;`exit` 或 Ctrl-D 返回 Celebi shell |
| `danger-call <cmd>` | 直接执行系统命令(慎用) |
| `EOF` | 退出 Celebi shell(同 Ctrl-D) |
| `help` | 列出所有命令 |
| `helpme` | 获取当前对象的帮助 |
