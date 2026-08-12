---
title: "Architecture"
weight: 1
summary: "A code and metadata repository, plus a production factory that executes workflows."
---

The Celebi system has two halves:

![Overview of the Celebi system](/images/concepts/architecture.png)

- **Celebi Repository** — the code and metadata repository. It holds the workflow
  system (code, environments, and parameters, organized as a
  [materialized workflow](/concepts/materialized-workflow/)) and the versioning
  system ([Impressions](/concepts/impression/) — a snapshot of each workflow node).
- **Production Factory** — [Yuki](/concepts/yuki/) orchestrates the workflow and its
  inputs, dispatches jobs to external [runners](/concepts/runner/) (e.g. REANA), and
  retrieves the results.

## Design principles

1. **Data manipulation is strictly forbidden** — if you operate on data by hand, it
   becomes impossible to know how it was produced.
2. **The code repository stays clean** — data is not versioned, or the folder would
   blow up.
3. **Outdated results are cleaned in time** — and can be brought back with the time
   machine (impressions).
4. **Any change to the code is detectable.**
5. **The status of every datum is known** — you can always tell whether data is valid
   or not.
