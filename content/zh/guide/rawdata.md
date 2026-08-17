---
title: "使用原始数据"
weight: 2
summary: "把数据引入 Celebi —— 本地、来自 DITE、或直接从 SSH runner 上登记,并以 MD5 管理。"
---

Celebi 中的原始数据存放在**数据任务**里:普通的任务目录,其
`celebi.yaml` 带有 `environment: rawdata` 和一个 `uuid`。UUID 是**数据内容的
MD5** —— 同一份数据无论在哪里登记,总是得到同一个 UUID。数据任务不执行,它是
下游分析任务作为输入引用的容器。

```yaml
environment: rawdata
uuid: 779f83aa862dd6fb4a32989718d70bdd
descriptor: MyData
```

有四种方式把数据引入项目,按数据当前所在的位置选择:

| 数据目前在... | 命令 |
|---|---|
| 本机上属于某个任务的文件 | `create-data` + `import` |
| 本机上的一个目录 | `upload-data` |
| DITE 上已有的印象 | `attach-data` |
| SSH runner 上的一个目录 | `register-ssh-data` |

## 1. `create-data` + `import` —— 任务内的文件

`create-data` 创建一个空的原始数据任务;`import` 把本地文件拷入其中。文件会
随任务一起提交,因此适合每个任务专属的小文件(配置、小表格),不适合大数据集。

```text
>>>> create-data MyData
>>>> cd @/MyData
>>>> import /path/to/file.txt
```

## 2. `upload-data` —— 本地目录到 DITE

`upload-data`(旧名 `send`)把本地目录上传到 DITE 服务器,带进度条。系统计算
MD5、把数据存入 Yuki 存储并登记印象 —— 之后本地任务只是指向它的一根指针。

```text
>>>> upload-data /data/lhcb/samples
The md5 of the dir is: 779f83aa862dd6fb4a32989718d70bdd
```

## 3. `attach-data` —— 领养 DITE 上已有的印象

`attach-data`(旧名 `use-data`)把 DITE 上已存在的印象 —— 由其他项目或
`yuki-create-data` 创建 —— 变成本地的数据任务。**不传输任何数据**;本地任务是
一根指针,UUID 从服务端元数据填充。

```text
>>>> attach-data 17d47e297f50cbeed12b821fde672ea9
```

如果你在已有的原始数据任务里运行它,该任务的 UUID/descriptor 会被更新而不是
新建任务。

## 4. `register-ssh-data` —— 数据已经在 SSH runner 上

当数据已经躺在计算农场上时,不要把它拉到笔记本再上传。`register-ssh-data`
**在 runner 上**计算 MD5,并把数据拷贝到 Yuki 在**该 runner 上**的受管
impressions 区域 —— 数据完全不经过你的网络。命令显示哈希进度的实时字节
进度条,**哈希计算完成即返回**;拷贝作为后台任务在 Yuki 上继续执行。

```text
>>>> register-ssh-data pkufarm212 /home/user/workdir/TestData --descriptor MyData
register-ssh-data: job 37013596... started on 'pkufarm212'
register-ssh-data: hashing  4.2G/4.2G [██████████] 100% 00:25
Registered: md5=779f83aa862dd6fb4a32989718d70bdd impression=17d47e297f50cbeed12b821fde672ea9 — copying in background
Updated rawdata task at MyData (register-ssh-data) with new impression data
```

登记分为两个阶段:哈希(MD5 + 生成印象)由命令等待完成;拷贝作为独立的
后台任务运行(hashing → copying → done)。用 `status` 查看拷贝进度:

```text
>>>> status
...
Data registration: copying — 1.2GiB/4.2GiB
```

拷贝完成(或失败)后 `status` 分别显示 `Data registration: archived` 或
`failed — <错误信息>`。重复登记同一路径时**总是重新计算哈希**:内容未变则
直接复用已有登记(哈希完成后立即返回);内容变了则生成新的印象,并重新
拷贝托管区。数据任务的默认 runner 会被设为托管数据的那个 runner。

## 5. 下游使用数据

把数据任务加为分析任务的输入,然后提交:

```text
>>>> cd @/FitTask
>>>> add-input ../MyData
>>>> submit pkufarm212
```

数据如何进入工作流取决于 runner:

- **SSH runner**:数据从 runner 本地的 impressions 缓存 staging。原始数据输入
  会**自动缓存** —— 第一个工作流上传数据(或从受管区拷贝)并写入
  `[remote-workdir]/impressions/<project>/<impression>/`;之后同一 runner 上的
  每个工作流都是本地拷贝,零网络传输。
- **REANA runner**:开启 `cache_on_runner` 后,数据经由 EOS 流转。
- `register-ssh-data` 登记的数据绑定在其 runner 上:把需要它的工作流提交到其他
  runner 会被明确报错拒绝(通过 `collect` 搬运这类数据已在计划中)。

## 6. `cache_on_runner` —— 结果缓存在哪里

每个任务都有 `cache_on_runner` 选项(shell 中:`cache_on_runner on|off`)。
效果取决于 runner 类型:

| Runner 类型 | `cache_on_runner` 开启时 |
|---|---|
| REANA | 结果拷贝到 EOS(runner 的 `eos_mount_point`) |
| SSH | 结果拷贝到 runner 的受管 impressions 区域 |
| native / dry | 无效果(产物本来就在 Yuki 存储中) |

## 7. `verify-data` —— 校验数据完整性

`verify-data` 重新计算 MD5 并与登记的 UUID 比对。托管在 SSH runner 上的数据
在 runner 上重算;Yuki 存储中的数据在本地重算。

```text
>>>> verify-data
Data verified: md5 matches (779f83aa862dd6fb4a32989718d70bdd) on runner pkufarm212
```

不匹配意味着磁盘上的数据发生了变化,命令会同时给出两个值。

## 8. 状态与可见性

数据任务的状态反映其登记生命周期:拷贝进行中为 `running`,落定后为 `archived`。
`status` 命令显示与分析任务相同的文件表 —— 文件名、大小、类型、以及文件是否已
在本地(Yuki)存储中:

```text
>>>> status
Job status: [coda][archived]
Stageout files:
    NAME                            SIZE  TYPE   IN YUKI
    111.txt                           5 B  data   ✗
```

## 9. 使用 SSH runner

两条命令帮你检查 SSH runner:

- `test-runner <runner>` —— 探测连通性、snakemake、conda 与远端工作目录,并把
  结果保存下来(由 `runners` 展示)。
- `runner-envs <runner>` —— 列出 runner 上可用的 conda 环境。

注册与配置 runner(包括 SSH 密钥,`register-runner` 会自动上传)见
[Runner](/concepts/runner/)。
