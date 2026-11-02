# CUE vs actionlint Delta Matrix — httputil workflows (pilot evidence)

- **Date:** 2026-11-02 (session clock via CLI)
- **Inputs:** `.github/workflows/{release,ci,nightly-fuzz}.yml` at master
  `48b664e`; schemas `#ReleaseWorkflow` in this repo; `cue` nixpkgs 0.17.1
  (binary reports `version (devel)`; the nix derivation is the pin);
  `actionlint` v1.7.12.
- **Scope:** one schema (`#ReleaseWorkflow`) vs actionlint's general checks,
  over the three workflows. `#CIWorkflow` (ci.yml, nightly-fuzz.yml) is
  gated behind this adoption decision.

## The matrix

| Check class | finding | cue vet `#ReleaseWorkflow` | actionlint 1.7.12 | remediation |
| --- | --- | --- | --- | --- |
| Missing concurrency guard on the release publish job | release.yml had none | **CAUGHT** — `concurrency: field is required but not present` | not checked (no such rule) | fixed same-session (`release-${{ github.ref }}`, no cancel) |
| Attacker-controlled `github.head_ref` spliced inline into `run:` | ci.yml:255 commit-lint step | not checked (out of schema scope: expression semantics) | **CAUGHT** — `expression` rule, env-var mitigation prescribed | fixed same-session (env indirection) |
| env pin formats (`GOTOOLCHAIN: goX.Y.Z` exact, `GOLANGCI_LINT_VERSION: vX.Y.Z`, `GO_VERSION` float-or-patch) | all conform | **enforced** (regex violations fail vet) | not checked (no format policy) | n/a |
| Actions pinned to 40-char commit SHAs | all conform | **enforced** | partially (shellcheck/scoring only; pinning is advisory in scoreboard mode) | n/a |
| Runner allowlist (`ubuntu-latest` only) | all conform | **enforced** | not checked | n/a |
| Least-privilege workflow `permissions` (`contents: write` exactly) | conforms | **enforced** | not checked | n/a |
| Tag-only trigger shape (`([a-z0-9_-]+/)?v*` globs) | conforms | **enforced** | not checked | n/a |
| Workflow-type discrimination (negative control: release schema vs ci.yml) | — | **rejects loudly** (`on.pull_request: field not allowed`) | n/a (single generic checker) | n/a |
| Expression syntax/semantics, matrix expansion, shell quoting inside `run:` | — | not covered (deliberate) | **core competency** | n/a |
| `on:` YAML key handling | — | parses correctly as the string `"on"` (no YAML 1.1 bool-true mangling) | n/a | n/a |

## Verbatim capture — the two real findings

```
$ cue vet -d '#ReleaseWorkflow' release_workflow.cue <httputil>/.github/workflows/release.yml
concurrency: field is required but not present:
    ./release_workflow.cue:38:2

$ actionlint <httputil>/.github/workflows/ci.yml
.github/workflows/ci.yml:255:89: "github.head_ref" is potentially untrusted.
avoid using it directly in inline scripts. [...]
```

Both findings were local to LarsArtmann/httputil and were fixed in the same
session (commit `48b664e`) — no upstream issues to file. Negative-control
output (schema rejecting the wrong workflow type) is recorded in the matrix.

## Interpretation

The tools are complementary, not competing: CUE pins **fleet policy that
actionlint has no concept of** (pin formats, allowlists, concurrency,
permissions shape), actionlint pins **GitHub Actions semantics that a data
schema cannot see** (expression validity, injection). Zero overlap findings
were produced by both tools; each of the two real defects had exactly one
detector. The discriminating negative control shows schema vetting is
workflow-type-aware, which actionlint structurally is not.

## Cost

Schema authoring for `#ReleaseWorkflow`: ~100 lines of CUE including the
rationale comments, one afternoon slice including the CUE-syntax learning
curve (`...string & regex` element constraints, closed-vs-open struct
semantics). Runtime cost of `cue vet`: single-digit milliseconds per file.
Maintenance: the schema changes only when the FLEET POLICY changes, which is
exactly the property that makes it a policy — not a mirror of the file.
