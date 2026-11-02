# cue-policy

Central CUE policy module for the LarsArtmann fleet: machine-checked schemas
for the data files every repo repeats by hand, starting with GitHub workflow
invariants that `actionlint` cannot see.

## What lives here

CUE schemas (`#ReleaseWorkflow`, `#CIWorkflow`, …) encoding the fleet's
written release and CI invariants — the rules currently kept by humans
reading `docs/RELEASE.md` — so `cue vet` can fail a run the moment a
workflow file drifts from them.

Repos consume the policies with an external `cue vet` invocation (CUE is a
tool here, never a Go dependency — the fleet's Go validation lanes stay
govalid/Huma/go-faster-yaml per `how-to-golang` policy; the depguard
allowlists are untouched).

## Canonical doc home

Everything about these schemas — invariants, rationale, adoption status —
is documented HERE, in this repository. Consumer repos link in; they do not
fork copies of the rules. A fleet rule with two doc homes is a split brain.

## Status

Pilot (2026-11-02): `#ReleaseWorkflow` authored against
`LarsArtmann/httputil`'s three workflows; adopt/retire decision pending the
CUE-vs-actionlint delta matrix (see httputil
`docs/status/2026-11-02_04-56_cue-research-and-adoption-decision.md`).

## Usage

```bash
cue version                       # nixpkgs pin: cue 0.17.1
cue vet -c .                    # self-check: the policies unify cleanly
cue vet -c '#ReleaseWorkflow' <repo>/.github/workflows/release.yml
```

Workflows are validated after a `yaml.Unmarshal`-conformant conversion —
see the schema files for the exact invocation each policy expects.
