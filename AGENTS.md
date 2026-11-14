# AGENTS.md — cue-policy

Central CUE policy module for the LarsArtmann fleet: machine-checked schemas
(`#ReleaseWorkflow`, `#CIWorkflow`) for GitHub workflow files, replacing rules
that previously lived only in humans' heads and `docs/RELEASE.md` copies.
There is **no Go code, no flake.nix, no CI of its own** — the repo is two CUE
schema files plus decision records. Consumer repos check it out (path
convention `./cue-policy`, pinned by commit SHA) and run `cue vet` against
their own workflows.

## Commands

```bash
cue vet -c .        # THE quality gate: self-check, schemas unify cleanly
cue fmt .           # owns .cue files (tabs); dprint does NOT cover CUE
dprint fmt          # everything else: json/yaml/markdown/dockerfile
dprint check        # CI-equivalent format gate

# the consumer invocation shape (run from a consumer repo):
cue vet -d '#ReleaseWorkflow|#CIWorkflow' ./cue-policy <repo>/.github/workflows/<wf>.yml

# pin-watching (both must agree, currently v0.17.1):
nix eval --raw nixpkgs#cue.version
cue version
```

## Hard boundaries — violating these defeats the repo's purpose

- **CUE is a tool here, never a Go dependency.** `cuelang.org/go` is banned
  from fleet Go modules (depguard allowlists per `how-to-golang`). Do not add
  Go code, a go.mod, or Go consumers of these schemas. Validation inside Go
  stays govalid/Huma/go-faster-yaml.
- **Canonical doc home.** Everything about these schemas — invariants,
  rationale, adoption status — is documented HERE. Consumer repos link; they
  never fork copies of the rules. A fleet rule with two doc homes is a split
  brain.
- **Schemas encode only already-decided fleet policy.** Encoding a new rule
  (e.g. requiring concurrency on CI workflows) is new fleet policy and must be
  decided fleet-wide first. `#CIWorkflow` deliberately does NOT require
  `concurrency:` for exactly this reason (see its header comment).
- **Structural invariants only.** Step-order and step-presence contracts stay
  with per-repo CI gates, not in these schemas.

## Schema design patterns (learned the hard way in wave 1)

- **Open structs everywhere** (`...` at every level): fleet-legal constructs —
  manual dispatch with inputs, `paths`/`paths-ignore` filters,
  `pull_request: null`, workflow env beyond GOTOOLCHAIN, `id-token`
  permissions, glob-style tags — must not fail vet. The first schema draft
  rejected several of these and had to be generalized (commit `a3e9c79`).
  When a consumer workflow fails vet, first ask: real policy drift, or a
  fleet-legal shape the schema has never seen?
- **Format-checks-when-present:** absence of an env pin (`GO_VERSION`,
  `GOTOOLCHAIN`, `GOLANGCI_LINT_VERSION`) is fleet-legal; only the FORMAT is
  enforced when present.
- **Workflow-type discrimination:** each schema rejects the wrong workflow
  type loudly (e.g. `#ReleaseWorkflow` on a ci.yml fails on
  `on.pull_request: field not allowed`) — that is intended, it is the
  negative control from the delta matrix.
- Runner allowlists differ: `#CIWorkflow` allows `ubuntu-latest` +
  `ubuntu-24.04-arm` (arm64 for arch-specific native jobs, decided
  2026-11-10); `#ReleaseWorkflow` allows only `ubuntu-latest`.
- Actions `uses:` must be 40-char commit SHA pins
  (`^[^@ ]+@[0-9a-f]{40}( .*)?$`).
- The YAML `on:` key parses as the string `"on"` under cue's YAML decoding —
  no YAML 1.1 bool-true mangling to work around.

## Pin-watching protocol (README "Pin watching" is authoritative)

- Consumer CI pins TWO things independently: the cue tool version AND this
  repo's commit SHA. A schema change without a consumer SHA bump silently
  enforces the old policy forever; a tool bump without a schema check can
  enforce the wrong one. After changing schemas here, consumer repos must
  bump their `cue-policy` checkout SHA.
- CUE is pre-1.0 and may churn between minors: before any bump (v0.18+),
  re-run `cue vet -c .` here AND the httputil vet invocations; schemas may
  need `cue fmt` or constraint updates. Record the new pin in README, in
  `cue.mod/module.cue` (`language.version` moves in lockstep), and in
  consumer CI (`go install cuelang.org/go/cmd/cue@vX.Y.Z` + checkout SHA).
- The nixpkgs cue binary may report `version (devel)` — the nix derivation is
  the pin, not the binary string.

## Repo layout

- `release_workflow.cue` / `ci_workflow.cue` — both `package policy`, flat in
  the repo root. `#ReleaseWorkflow`: release.yml (tag-or-dispatch trigger,
  `contents: write`, REQUIRED concurrency guard, pin formats, SHA-pinned
  actions, ubuntu-latest). `#CIWorkflow`: ci.yml/nightly shapes
  (`contents: read`, GOTOOLCHAIN exact-pin-if-present, runner allowlist).
- `docs/` — dated decision records (`YYYY-MM-DD_topic.md`). The adoption memo
  (2026-11-02) is the ADR: CUE adopted in exactly one lane (external vet),
  complementing actionlint, never replacing it. Rollout wave 1 found exactly
  one defect class fleet-wide: missing release concurrency guards.
- `.config/metadata.yaml` — meta inventory registration (generated).
- `SECURITY.md` — maintained with `securitymd`.
- `.gitignore` — BuildFlow-managed block between `>>> buildflow-managed`
  markers; edit outside the markers only.

## Gotchas

- `cue vet -c .` (the `-c`) is what makes the self-check meaningful — it
  checks concreteness, not just parse success.
- `-d '#ReleaseWorkflow|#CIWorkflow'` is a disjunction: one command, schema
  selected per file. Single-schema form for targeted runs.
- Generated files (`.config/metadata.yaml`, `SECURITY.md`) come back
  unformatted when their generators rerun — re-run `dprint fmt` afterwards.
- dprint reflows Markdown tables to padded columns; `**/CHANGELOG.md` is
  excluded by config.
- Rollout remediation (adding concurrency blocks, enabling policy-vet CI) is
  owned by each consumer repo's session under its own AGENTS constraints —
  do not do consumer-repo work from here. The httputil release.yml is the
  copy-paste template for the concurrency block.
