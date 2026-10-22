---
title: "Operations and recovery"
weight: 6
summary: "Monitor and recover workflows, maintain storage, publish bookkeeping, and operate Yuki."
---

## Monitor and stop workflows

```sh
celebi-cli submit --runner RUNNER --timeout 300
celebi-cli status --wait --poll-interval 5
celebi-cli log 0 --follow
celebi-cli engine-logs --fetch
```

The submission timeout is an HTTP/SSH operation timeout, not a workflow runtime
limit. A timed-out request may still have reached Yuki, so check `status` before
submitting again. Use `cancel` for the current task's running impressions.

For stale or detached state:

```sh
celebi-cli sync-live
celebi-cli purge-stale-workflows RUNNER --dry-run
celebi-cli stop-orphaned-workflows RUNNER --dry-run
celebi-cli stop-workflow WORKFLOW_UUID
```

Preview cleanup first. `stop-workflow` is the targeted escape hatch for a known
zombie workflow UUID.

## Cache and impression maintenance

```sh
celebi-cli purge-stale-cache RUNNER --dry-run
celebi-cli impression-stats
celebi-cli gc-impressions                 # dry-run
celebi-cli gc-impressions --execute
celebi-cli pack-impressions
celebi-cli migrate-impressions --dry-run
```

The purge commands use the project's synced live set. Unknown impressions are
treated as live, so a failed `sync-live` does not make deletion more aggressive.
Only use execution/pruning options after reviewing their dry-run output.

## Publish bookkeeping

Celebi bookkeeping publishes shareable Git state plus eligible collected images and
UTF-8 text. It is separate from the older REANA booking commands.

```sh
celebi-cli register-celebi-server \
  --server http://bookkeeping-host:3320 \
  --token ANALYSIS_TOKEN \
  --yuki http://yuki-host:3315

celebi-cli bookkeep --commit "Publish fit results" --tag v1
```

Collect results before publishing. `--allow-partial` permits a publication with
missing result archives; retry later without a new tag after collection finishes.
Credentials are saved in Git-excluded local configuration.

## Celebi-aware Git operations

```sh
celebi-git enable
celebi-git status
celebi-git hooks --install
celebi-git validate
celebi-git merge BRANCH --strategy interactive
```

The merge wrapper validates Celebi metadata and regenerates impressions. Use
`--dry-run` to inspect a planned merge.

## Yuki service commands

```sh
yuki server status
yuki native-runner status
yuki native-runner logs
yuki impression-export UUID --project-uuid PROJECT_UUID -o backup.tar.gz
yuki impression-import backup.tar.gz --project-uuid PROJECT_UUID
yuki env-map list
yuki purge-ssh-runner-cache --help
```

Use `yuki server stop` and `yuki native-runner stop` for planned shutdowns. The
`env-map` commands maintain compatibility mappings; prefer project-scoped
`.celebi-env` installations for new workflows.
