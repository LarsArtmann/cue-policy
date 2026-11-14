# TODO List

> Short-term, actionable, bounded work items, verified against the actual
> code. For long-term vision and unrefined ideas, use `ROADMAP.md`. Items are
> ranked by impact. Status is verified, not assumed.

## Status legend

| Status           | Meaning                                                 |
| ---------------- | ------------------------------------------------------- |
| 🔴 `TODO`        | Not started. Needs doing.                               |
| 🟡 `IN_PROGRESS` | Actively being worked on.                               |
| 🔵 `BLOCKED`     | Cannot proceed; external dependency or decision needed. |
| 🟢 `DONE`        | Completed. Remove from this list and log in `CHANGELOG.md`. |

## High Impact

| Task                                                                                                                            | Status       | Impact | Effort | Evidence                                                                                                  |
| ------------------------------------------------------------------------------------------------------------------------------- | ------------ | ------ | ------ | --------------------------------------------------------------------------------------------------------- |
| Add this repo's own CI gate: `.github/workflows/ci.yml` running `cue vet -c .` and `dprint check` on every push/PR              | 🔴 `TODO`    | High   | 1h     | No `.github/` directory exists; the self-check is manual (`README.md` "Usage")                            |
| The new ci.yml must itself conform to `#CIWorkflow` (dogfood: contents:read, SHA-pinned actions, runner allowlist) — part of the row above, verify with `cue vet -d '#CIWorkflow' . .github/workflows/ci.yml` | 🔴 `TODO` | High   | 15min  | `ci_workflow.cue` defines the contract; nothing currently enforces it on this repo |

## Medium Impact

| Task                                                                                                                                           | Status    | Impact | Effort | Evidence                                                                        |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ------ | ------ | ------------------------------------------------------------------------------- |
| 30-day fleet rollout review (~2026-12-02, "M15"): aggregate per-repo signal/noise from consumer repos and re-affirm or adjust the ADOPT decision per the memo's review triggers | 🔴 `TODO` | Med    | 2h     | `docs/2026-11-02_adoption-memo.md` "Review trigger" section                     |

> Consumer-repo rollout work (adding missing concurrency guards, enabling
> policy-vet CI lanes, the BuildFlow detect-only step) is owned by each
> consumer repo's own TODO_LIST — see `AGENTS.md` "Gotchas". It is
> deliberately NOT mirrored here.
