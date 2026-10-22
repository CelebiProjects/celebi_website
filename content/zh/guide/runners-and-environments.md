---
title: "Runner 与环境"
weight: 4
summary: "配置 REANA、native、SSH、IHEP 执行后端和项目环境。"
---

Yuki 当前支持 `reana`、`native`、`ssh` 与 `ihep` 四类后端。提交前先列出并探测
runner:

```sh
celebi-cli runners
celebi-cli test-runner RUNNER
celebi-cli yuki-overview
```

## 注册 runner

完整的位置参数是:

```text
celebi-cli register-runner NAME URL SECRET BACKEND_TYPE [OPTIONS]
```

- `reana` 通过 REANA 服务执行容器化工作流。
- `native` 使用 Yuki host agent 和本机 `--workdir`。
- `ssh` 使用 `--ssh-host`、`--ssh-user`、`--ssh-key-path` 与
  `--remote-workdir` 在远程主机执行。
- `ihep` 使用 SSH 传输,但通过 `hep_sub` 提交 coordinator 和规则作业;远程工作目录
  必须同时对登录节点和 worker 节点可见。

后端专属的资源、Conda 与 Snakemake 选项请看
`celebi-cli register-runner --help`。secret 与私钥是运维凭据,不要写进项目 README
或提交到 Git。

用 `request-runner NAME` 设置任务默认 runner,或只为一次提交覆盖:

```sh
celebi-cli submit --runner NAME
```

## 项目级 Conda 环境

`celebi-cli init` 会创建 `.celebi-env/default.yaml`。新增环境写成
`.celebi-env/NAME.yaml`,再安装到 SSH、IHEP 或 native runner:

```sh
celebi-cli install-environment RUNNER NAME
celebi-cli runner-environments RUNNER
celebi-cli set-environment NAME
```

Yuki 将环境安装到
`<runner-workdir>/environments/<project_uuid>/<name>`。项目 UUID 可防止不同项目中
的同名环境共用 prefix。再次安装会执行 `conda env update --prune`;YAML 的 `name`
字段不决定安装路径。若环境缺失,提交会提前失败并给出安装提示。

## 容器与 LHCb 环境

对 REANA 来说,普通 `environment` 可以是容器镜像。命令继承任务环境的算法使用
`environment: script`。

LHCb release 可通过 `lb_run` 块声明,其中 `project`、`version` 必填,`platform`
可选。普通 `environment` 仍须提供 ABI 兼容的基础环境。native、SSH、IHEP 主机
必须已有 `/cvmfs/lhcb.cern.ch`;REANA 则需挂载该仓库。

使用指定日期的 LbConda 环境:

```yaml
environment: lb-conda/default/2020-05-14
```

格式为 `lb-conda/PACKAGE/DATE`;同一任务不能同时使用 `lb-conda/...` 与 `lb_run`。
