# Adoption Memo — CUE as the fleet's workflow-policy layer

- **Date:** 2026-11-02
- **Decision:** **ADOPT** — CUE in exactly one lane: external `cue vet`
  policy schemas for GitHub workflow files, owned by this repo.
- **Evidence:** [the delta matrix](2026-11-02_cue-vs-actionlint-delta-matrix.md).

## Why adopt

1. The pilot produced a real, otherwise-uncaught defect (missing release
   concurrency guard) within minutes of the schema existing, and the
   schema's policy checks (pin formats, SHA pins, allowlists, permissions)
   have no actionlint counterpart.
2. The tools did not double-report a single finding — adoption adds a
   detection axis instead of duplicating one.
3. The cost measured is small and one-time (schema authoring), with
   near-zero runtime and maintenance cost by construction (schemas change
   only when fleet policy changes).

## Why not more than this lane

- Not a Go dependency: fleet policy (`how-to-golang`) owns in-Go validation
  (govalid/Huma/go-faster-yaml); the httputil depguard allowlist does not
  admit `cuelang.org/go`. Nothing in the pilot contradicts that — the value
  found lives entirely in the untyped YAML layer.
- Not a replacement for actionlint: expression semantics and injection
  checks are actionlint's core competency; the pilot's other real finding
  came from there. Both tools stay.

## What adoption means concretely

1. `#ReleaseWorkflow` (this repo) vets every fleet `release.yml`; the
   schema is the policy, consumer repos carry no copies.
2. `#CIWorkflow` follows for `ci.yml`/`nightly-fuzz.yml`-shaped files
   (authored next, M12).
3. Wiring: the vet lands in the per-repo CI (httputil first) and as a
   BuildFlow detect-only step (M11), mirroring the apidiff both-layer
   ruling.
4. Adoption status per repo is recorded in each repo's living docs; this
   repo remains the canonical home for schemas and their rationale.

## Review trigger

Re-decide if either tool stops pulling its weight: cue vet producing zero
unique findings across the fleet for ~2 quarters, or a second maintainer
cost incident (schema false-positive blocking a release). Next scheduled
look: the 30-day fleet rollout review (M15).
