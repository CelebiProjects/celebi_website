---
title: "Data locations and lifecycle"
weight: 5
summary: "Register external data, locate and transfer results, and manage retention."
---

Celebi identifies data and results by impression UUID; Yuki tracks their physical
locations. A result may exist in Yuki Storage, a managed runner cache, or a workflow
workspace. Terminal workflow status and `whereabouts` tell you whether a local copy
is available.

## Register input data

Choose the command that matches the source:

```sh
# Copy local data into Yuki
celebi-cli create-data MyData
cd MyData
celebi-cli upload-data /local/path

# Register and stage a directory already on an SSH runner
celebi-cli register-ssh-data RUNNER /remote/path

# Freeze an XRootD inventory without copying payloads through Yuki
celebi-cli register-xrootd-data RUNNER \
  root://host.example//path/sample --checksum auto

# Adopt an impression that already exists in Yuki
celebi-cli attach-data IMPRESSION_UUID --path MyData
```

XRootD inventory runs on the named SSH runner, which must provide `python3`, `xrdfs`,
and the required credentials. `--checksum required` rejects entries without a server
checksum; `--checksum none` skips checksum queries. LHCb AP lists can instead be
created with `create-lhcb-ap-list NAME`; edit its `ap_config` and add the local APD
token with `add-apd-token`.

Wire data into a task with an explicit alias:

```sh
celebi-cli add-input ../MyData raw
```

Inside the task runtime the direct alias path is `raw/`, so its outputs are under
`raw/stageout/`.

## Locate, collect, and transfer results

Run these commands from the task whose active impression you are managing:

```sh
celebi-cli whereabouts
celebi-cli collect          # plots and logs
celebi-cli collect data     # ROOT and other data files
celebi-cli collect all      # every category
celebi-cli refresh-filelists
```

`refresh-filelists` asks the runner to re-list files for an already terminal
workflow. Use `collect --allow-failed` when a failed workflow still produced useful
stageout files.

Locations in transfer commands are `yuki` or `runner:NAME`:

```sh
celebi-cli transfer runner:source yuki
celebi-cli transfer yuki runner:destination
celebi-cli cache-results RUNNER
```

Native execution and Yuki Storage are one storage domain, so native is not a
separate transfer location.

## Retention and cleanup

`purge-data` removes the collected Yuki copy of the current impression. By default
Yuki refuses if no runner copy can be used to recover it; `--force` deliberately
overrides that protection. Inspect `whereabouts` before purging. Runner-wide cache
and workflow cleanup is described in [Operations and recovery](/guide/operations/).
