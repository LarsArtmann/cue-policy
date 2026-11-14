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

Adopted (2026-11-02): the [adoption memo](docs/2026-11-02_adoption-memo.md)
decided CUE serves the fleet in exactly one lane — external `cue vet` policy
schemas, complementing actionlint, never replacing it (evidence:
[delta matrix](docs/2026-11-02_cue-vs-actionlint-delta-matrix.md)). Both
schemas are live: `#ReleaseWorkflow` and `#CIWorkflow`. Rollout
[wave 1](docs/2026-11-02_rollout-wave-1.md) vetted three repos read-only and
found one consistent defect class fleet-wide: missing release concurrency
guards. Research provenance: httputil
`docs/status/2026-11-02_04-56_cue-research-and-adoption-decision.md`.

## Usage

```bash
cue version                       # nixpkgs pin: cue 0.17.1
cue vet -c .                      # self-check: the policies unify cleanly

# consumer-side, from a repo with this one checked out at ./cue-policy:
cue vet -d '#ReleaseWorkflow|#CIWorkflow' ./cue-policy .github/workflows/<wf>.yml
```

The consumer line is the exact CI invocation shape wave 1 ran. cue converts
the YAML itself — the `on:` key parses as the string `"on"`, so there is no
YAML 1.1 bool-true mangling to work around.

## Pin watching

Two pins must agree, and both need periodic re-checks (nixpkgs can move,
CUE is pre-1.0 and may churn between minors):

```bash
nix eval --raw nixpkgs#cue.version        # the nixpkgs pin (0.17.1 as of 2026-11-02)
cue version                                # the installed binary
```

- When CUE ships a new minor (v0.18+), re-run the self-check
  (`cue vet -c .`) and the httputil vet invocations before bumping any
  consumer pin — schemas may need `cue fmt` or constraint updates.
- When nixpkgs updates the package, confirm the version still vets the
  fleet schemas clean, then record the new pin here and in the consumer
  repos' CI (`go install cuelang.org/go/cmd/cue@vX.Y.Z` + the checkout SHA).
- Consumer CI pins TWO things independently: the cue tool version and this
  repo's commit SHA. A schema change without a consumer SHA bump silently
  enforces the old policy forever; a tool bump without a schema check can
  enforce the wrong one.
