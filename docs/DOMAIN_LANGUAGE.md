# Domain Language

> The ubiquitous language of this project. Every term used in code,
> conversations, and docs should be defined here unambiguously.

## Core terms

| Term                       | Definition                                                                                                                                                     | Where used                                           |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| fleet                      | The set of LarsArtmann repositories sharing one written policy; the collective owner of every rule encoded here                                                | README, `docs/`, schema comments                     |
| policy schema              | A CUE definition (`#ReleaseWorkflow`, `#CIWorkflow`) encoding fleet invariants that are already decided                                                        | `release_workflow.cue`, `ci_workflow.cue`            |
| fleet-legal                | A construct the fleet allows; schemas must pass it through (open structs), never reject it                                                                     | schema comments, `docs/2026-11-02_rollout-wave-1.md` |
| format-checks-when-present | Pattern: a pin's ABSENCE is fleet-legal; only its FORMAT is enforced when present                                                                              | env blocks of both schemas                           |
| skew-preflight contract    | The rule that any `GOTOOLCHAIN` env, wherever set, must be an exact patch pin (`goX.Y.Z`)                                                                      | `ci_workflow.cue` env comment                        |
| pin-watching               | The protocol keeping three things agreed: nixpkgs cue pin, installed binary, consumer CI pins (tool + repo SHA)                                                | README "Pin watching", `AGENTS.md`                   |
| wave                       | A rollout batch of consumer repos vetted read-only with the exact CI invocation shape (wave 1: library-policy, go-etag, go-error-family)                       | `docs/2026-11-02_rollout-wave-1.md`                  |
| M-milestone                | Numbered milestone in the fleet rollout plan (M11 BuildFlow detect-only step, M12 `#CIWorkflow`, M15 30-day review); the plan lives in httputil's research doc | `docs/2026-11-02_adoption-memo.md`                   |
| negative control           | Evidence that a schema rejects the wrong workflow type loudly (workflow-type discrimination)                                                                   | `docs/2026-11-02_cue-vs-actionlint-delta-matrix.md`  |
| delta matrix               | The pilot evidence doc mapping which tool catches which defect class — proof CUE and actionlint are complementary                                              | `docs/2026-11-02_cue-vs-actionlint-delta-matrix.md`  |
| canonical doc home         | This repo: the single place schema invariants, rationale, and adoption status are documented; consumers link, never fork                                       | README "Canonical doc home", `AGENTS.md`             |

## Bounded contexts

None yet: the vocabulary is small and used consistently across schemas,
README, and decision records.

## Deprecated terms

None recorded.
