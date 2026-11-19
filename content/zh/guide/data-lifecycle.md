---
title: "数据位置与生命周期"
weight: 30
guide_group: "core-data"
summary: "注册外部数据,定位和迁移结果,并管理保留策略。"
---

Celebi 用 impression UUID 标识数据与结果;Yuki 跟踪它们的物理位置。一份结果可能
位于 Yuki Storage、runner 托管缓存或 workflow workspace。终态工作流的状态和
`whereabouts` 会说明本地副本是否可用。

## 注册输入数据

按数据来源选择命令:

```sh
# 将本地数据复制进 Yuki
celebi-cli create-data MyData
cd MyData
celebi-cli upload-data /local/path

# 注册并暂存 SSH runner 上已有的目录
celebi-cli register-ssh-data RUNNER /remote/path

# 冻结 XRootD 清单,不通过 Yuki 复制数据载荷
celebi-cli register-xrootd-data RUNNER \
  root://host.example//path/sample --checksum auto

# 采用 Yuki 中已有的 impression
celebi-cli attach-data IMPRESSION_UUID --path MyData
```

XRootD 清点在指定的 SSH runner 上执行,该主机必须提供 `python3`、`xrdfs` 和所需
凭据。`--checksum required` 会拒绝没有服务端 checksum 的条目;
`--checksum none` 跳过 checksum 查询。LHCb AP 列表可用
`create-lhcb-ap-list NAME` 创建,随后编辑 `ap_config`,并用 `add-apd-token` 添加
只保存在本地的 APD token。普通执行 Task（包括 `lb-conda` Task）也可以使用同一
本地 token。它保存在 Git 排除的配置中；Yuki 只在执行工作区暂存权限为 `0600`
的 token 文件，不把 token 值写入命令或日志。

为任务连接数据时必须给出 alias:

```sh
celebi-cli add-input ../MyData raw
```

运行时直接以 `raw/` 访问该输入,其输出位于 `raw/stageout/`。

## 定位、收集与迁移结果

在要管理其 active impression 的任务中运行:

```sh
celebi-cli whereabouts
celebi-cli collect          # 图片和日志
celebi-cli collect data     # ROOT 等数据文件
celebi-cli collect all      # 所有类别
celebi-cli refresh-filelists
```

`refresh-filelists` 要求 runner 为已经终态的工作流重新列出文件。失败工作流仍产出
有用文件时使用 `collect --allow-failed`。

迁移命令的位置写成 `yuki` 或 `runner:NAME`:

```sh
celebi-cli transfer runner:source yuki
celebi-cli transfer yuki runner:destination
celebi-cli cache-results RUNNER
```

native 执行与 Yuki Storage 属于同一存储域,因此 native 不是单独的迁移位置。

## 通过 SSH 分享完整 impression

当另一套 Celebi/Yuki 需要完整、不可变的 Task 快照，而不是部分结果文件时，使用：

```sh
celebi-cli share-ssh-impressions --export RUNNER
celebi-cli share-ssh-impressions --import RUNNER
```

在 Task 中运行时只处理一个 active impression；在目录或项目中运行时处理全部后代
Task。Algorithm 不是合法范围。该命令使用 SSH runner 的受管 impression 区，与
在 `yuki` 和 `runner:NAME` 之间选择性迁移 stageout 的 `transfer` 不同。

Celebi/Yuki 1.1.0 会在 SSH impression 双向分享时排除所有
`config.local.json` 和 `lbapi_key.json`。不可变快照仍可使用，但目标环境若需执行
APD 任务，必须自行提供本地凭据。

## 保留与清理

`purge-data` 删除当前 impression 在 Yuki 中已收集的副本。默认情况下,若 runner
上没有可恢复副本,Yuki 会拒绝删除;`--force` 会有意覆盖这层保护。删除前先运行
`whereabouts`。runner 范围的缓存和工作流清理见
[运维与恢复](/zh/guide/operations/)。

## 托管 EOS 缓存

从 `1.1.2b1` 起，可通过 [EOS 统计与清理](/zh/guide/eos-cache/) 区分 live、non-live 和 unknown，预览删除清单并通过独立 REANA 作业复查。删除 REANA workflow 不会删除其 EOS 缓存。
