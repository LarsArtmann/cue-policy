# Rollout wave 1 — policy vet on library-policy, go-etag, go-error-family

Date: 2026-11-02 (post schema-generalization `a3e9c79`). Method: the
wave-1 session ran the exact CI invocation shape (`cue vet -d
'#ReleaseWorkflow|#CIWorkflow' ./cue-policy <repo>/.github/workflows/<wf>.yml`,
cue v0.17.1) against every workflow of three fleet repos, read-only.

## Results after schema generalization

| Repo              | Workflow           | Schema            | Result |
| ----------------- | ------------------ | ----------------- | ------ |
| library-policy    | ci.yml             | #CIWorkflow       | PASS   |
| library-policy    | release.yml        | #ReleaseWorkflow  | **FINDING: no concurrency guard** |
| go-etag           | ci.yml             | #CIWorkflow       | PASS   |
| go-etag           | release.yml        | #ReleaseWorkflow  | **FINDING: no concurrency guard** |
| go-error-family   | ci.yml             | #CIWorkflow       | PASS   |
| go-error-family   | website-check.yml  | #CIWorkflow       | PASS   |
| go-error-family   | website-deploy.yml | #CIWorkflow       | PASS   |
| go-error-family   | release.yml        | #ReleaseWorkflow  | **FINDING: no concurrency guard** |

## Triage

- **The only real finding class: missing release concurrency guards** —
  the identical defect the pilot caught in httputil (a manual second tag
  push can race an in-flight publish). All three repos affected, zero
  other policy drift detected fleet-wide (pins, runners, permissions,
  actions all conform).
- The schema fixes en route (first vet round) were NOT repo findings:
  fleet-legal constructs the pilot schemas had never seen — manual
  dispatch with inputs, `paths`/`paths-ignore` filters, `pull_request:`
  null, workflow-level env beyond GOTOOLCHAIN, `id-token` permissions,
  glob-style tag patterns. Opened where policy does not care; the env pin
  triad became format-checks-when-present.

## Remediation owner (per the wave protocol)

Per-repo fixes (add the concurrency block) + `policy-vet` CI enablement +
the 30-day signal/noise review belong to each repo's own session under
its own AGENTS constraints — tracked in httputil's TODO_LIST "Fleet
rollout wave 1" row. The httputil release.yml is the copy-paste template:

```yaml
concurrency:
  group: release-${{ github.ref }}
  cancel-in-progress: false
```
