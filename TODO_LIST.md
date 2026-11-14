# TODO List

> Short-term, actionable, bounded work items, verified against the actual
> code. For long-term vision and unrefined ideas, use `ROADMAP.md`. Items are
> ranked by impact. Status is verified, not assumed.

## Status legend

| Status           | Meaning                                                     |
| ---------------- | ----------------------------------------------------------- |
| 🔴 `TODO`        | Not started. Needs doing.                                   |
| 🟡 `IN_PROGRESS` | Actively being worked on.                                   |
| 🔵 `BLOCKED`     | Cannot proceed; external dependency or decision needed.     |
| 🟢 `DONE`        | Completed. Remove from this list and log in `CHANGELOG.md`. |

## High Impact

| Task                                                                                                                                                                                          | Status    | Impact | Effort | Evidence                                                                                                   |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ------ | ------ | ---------------------------------------------------------------------------------------------------------- |
| Add this repo's own CI gate: `.github/workflows/ci.yml` running `cue vet -c .` and `dprint check`, dogfooding `#CIWorkflow` on itself (`cue vet -d '#CIWorkflow' . .github/workflows/ci.yml`) | 🔴 `TODO` | High   | 1h     | No `.github/` directory exists; the self-check is manual (README "Usage")                                  |
| Add a schema regression corpus: conformant + deliberately-non-conformant workflow fixtures under `tests/` with a runner asserting vet pass/fail, wired into the CI gate                       | 🔴 `TODO` | High   | 1h     | Schema behavior verified only by manual positive/negative runs this session (docs/status/2026-11-14_12-06) |

## Medium Impact

| Task                                                                                                                                                                            | Status    | Impact | Effort | Evidence                                                                            |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ------ | ------ | ----------------------------------------------------------------------------------- |
| Wire the docs-gates battery into the CI gate (`nix run github:Artmann-Technologies/docs-gates -- run .`); seed `.docs-gates.json` only if defaults misfit                       | 🔴 `TODO` | Med    | 30min  | `docs/status/` now exists (first report 2026-11-14); the battery has never run here |
| 30-day fleet rollout review (~2026-12-02, "M15"): aggregate per-repo signal/noise from consumer repos and re-affirm or adjust the ADOPT decision per the memo's review triggers | 🔴 `TODO` | Med    | 2h     | `docs/2026-11-02_adoption-memo.md` "Review trigger" section                         |

> Consumer-repo rollout work (adding missing concurrency guards, enabling
> policy-vet CI lanes, the BuildFlow detect-only step) is owned by each
> consumer repo's own TODO_LIST — see `AGENTS.md` "Gotchas". It is
> deliberately NOT mirrored here.
