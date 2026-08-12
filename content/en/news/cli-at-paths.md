---
title: "CLI: project-root @/ paths with tab completion"
date: 2026-07-09
summary: "Task-configuration commands now resolve @/ paths relative to the project root, with shell tab completion support."
---

The Celebi shell now understands `@/` as an alias for the project root:

- `@/` paths resolve in all task-configuration commands.
- Tab completion works for `@/` paths, so deep object paths are quick to type.
- The change ships with a full test suite for path resolution.

```sh
celebi> configure @/analysis/selection --param threshold=0.9
```
