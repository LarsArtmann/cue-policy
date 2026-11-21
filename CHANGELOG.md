# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and
this project adheres to [Semantic Versioning](https://semver.org/). No
releases are tagged yet; everything below is unreleased.

## [Unreleased]

### Fixed

- `#CIWorkflow`'s runner allowlist admitted `ubuntu-latest` and
  `ubuntu-24.04-arm` but not the pinned `ubuntu-24.04` x86 lane, so every
  fleet repo holding that pin (go-sse, crush-daily, go-paperless, …) was
  unsatisfiable under `cue vet` — reported as `conflicting values` at the
  `runs-on` field. The label is now allowed; it is the deliberate hedge
  while GitHub migrates `ubuntu-latest` to Ubuntu 26.

### Added

- `#ReleaseWorkflow` schema pinning the fleet's release.yml invariants:
  tag-or-dispatch triggering, `contents: write` permission floor, a REQUIRED
  concurrency guard, env pin formats, SHA-pinned actions, `ubuntu-latest`
  runner (`release_workflow.cue`).
- `#CIWorkflow` schema pinning the continuous-workflow invariants:
  `contents: read`, exact `GOTOOLCHAIN` pin whenever present, runner
  allowlist, SHA-pinned actions (`ci_workflow.cue`).
- Decision-record docs in `docs/`: the adoption memo (ADR: CUE adopted in
  exactly one lane — external `cue vet`, complementing actionlint), the
  CUE-vs-actionlint delta matrix, and the rollout wave-1 record.
- Pin-watching protocol in the README; meta inventory registration
  (`.config/metadata.yaml`).
- BuildFlow-managed `.gitignore` block, dprint formatting config, and a
  `SECURITY.md` private-disclosure policy.
- MIT license.
- Living documentation set: `AGENTS.md`, `FEATURES.md`, `TODO_LIST.md`,
  `ROADMAP.md`, this changelog, and `docs/DOMAIN_LANGUAGE.md`.

### Fixed

- Generalized both schemas from wave-1 rollout evidence: opened trigger
  shapes (dispatch with inputs, path filters, `pull_request: null`), turned
  env pins into format-checks-when-present, and admitted `id-token`
  permissions and glob-style tag patterns — fleet-legal constructs the pilot
  schemas wrongly rejected.
- `#CIWorkflow` runner allowlist now admits `ubuntu-24.04-arm` for
  arch-specific jobs that must execute natively on arm64.
- README consumer invocation: the schema selector needs `-d`; the previously
  documented `cue vet -c '#ReleaseWorkflow' <file>` form fails on cue
  v0.17.1.
