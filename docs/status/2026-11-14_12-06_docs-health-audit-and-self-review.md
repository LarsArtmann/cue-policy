# Status Report — docs-health audit, AGENTS.md authoring, and self-review

- **Date:** 2026-11-14 12:06 (session clock via `date`)
- **Session scope:** turn 1 created AGENTS.md + fixed dprint drift; turn 2 ran
  the full docs-health AUDIT (BUILD + HARVEST + VERIFY); turn 3 (this) ran the
  brutal self-review and wrote this report.

## Scope line

**Verified here** (fresh commands, ~11:45–12:06, HEAD `120d343` unless noted):

- `cue vet -c .` — PASS (run 3× across the session; final run after all edits).
- `dprint check` — CLEAN (after fixing 2 pre-existing drifts and formatting all
  new docs).
- Consumer invocation exercised end-to-end from a simulated consumer checkout
  (`/tmp/consumer` with this repo at `./cue-policy`): conformant ci.yml →
  rc=0; guard-less release.yml → rc=1, `concurrency: field is required but not
  present`. Also: README's OLD documented form `cue vet -c '#ReleaseWorkflow'
  <file>` → rc=1 (`cannot determine package name for "#ReleaseWorkflow"`) —
  that failure output is the Critical finding, captured live.
- Pin triangle: `nix eval --raw nixpkgs#cue.version` → 0.17.1 = `cue version`
  = `cue.mod/module.cue` language.version.
- Temporal-pollution grep on AGENTS.md (hashes / dates / versions) → zero
  matches. File sizes via `wc -c`. CHANGELOG entries cross-checked against
  `git log` (11 commits, no tags — `git tag -l` empty).

**NOT verified here, and why:**

- Cross-repo claims: the httputil research-doc path cited as provenance
  (kept from the original README), whether consumer repos actually pinned
  this repo's SHA, and whether wave-1 concurrency remediation landed — all
  require checkouts of other repos; out of scope for this session.
- The docs-gates battery was never executed. My claim that "the ritual gates
  have no inputs" was read from the skill doc, not measured — the battery may
  still have routing/annotate legs that apply. Filed as a TODO row.
- Generator behavior on the two dprint-reformatted files
  (`.config/metadata.yaml`, `SECURITY.md`): the generators are not identified
  or runnable from here; "harmless reformat" is an assumption (YAML semantics
  unchanged, but generator round-trip untested). See question g)3.
- "Every doc-internal link resolves" in the audit report was asserted by
  construction, not by a mechanical link checker.

## a) FULLY DONE

1. **AGENTS.md created** (turn 1) and **quality-passed** (turn 2: temporal
   pollution removed, README-duplication compressed, 5.6 KB — sweet spot).
   Evidence: file on disk; pollution grep zero matches.
2. **Five missing living docs built**: CHANGELOG.md (every entry maps to a
   real commit; single `[Unreleased]` block — no tags exist), TODO_LIST.md,
   ROADMAP.md, FEATURES.md, docs/DOMAIN_LANGUAGE.md. Evidence: files + git log.
3. **README Critical fix**: the flagship consumer invocation was BROKEN on the
   pinned cue 0.17.1; replaced with the `-d '#ReleaseWorkflow|#CIWorkflow'`
   disjunct form and verified positive+negative from a simulated consumer.
4. **README staleness fixed**: Status section said "adopt/retire decision
   pending" — decided ADOPT 2026-11-02; now reflects adopted state with
   in-repo links. Dangling "see the schema files for the exact invocation"
   pointer fixed (schema files carry no invocations).
5. **Pre-existing dprint drift fixed** on `.config/metadata.yaml` +
   `SECURITY.md` (2 files). Evidence: `dprint check` CLEAN.
6. **Pin triangle confirmed current** (0.17.1 across nixpkgs, binary,
   module.cue).
7. **Inline docs-health report delivered**: Accuracy 8.5 / Fitness 3.5
   as-found, with visible math and per-doc findings.
8. **This turn (self-review fallout, fixed on sight)**: TODO_LIST rows merged
   (removed my own "part of the row above" smell) + 2 new rows routed
   (regression corpus, docs-gates wiring); README re-gained the
   `version (devel)` gotcha that turn-2 compression had orphaned (it survived
   only in a historical doc; README owns the protocol, so it went there).

## b) PARTIALLY DONE

1. **docs-health AUDIT**: BUILD/HARVEST/VERIFY done; the docs-gates battery
   leg NOT run (see scope line). Remaining: wire the battery once CI exists
   (TODO_LIST row). Effort to finish: S.
2. **Documentation set is built but unenforced**: nothing re-runs
   `cue vet -c .`, `dprint check`, or doc gates on push — the docs can silently
   rot exactly like the README invocation did. Blocker: no CI (see f)1).
3. **FEATURES sweep anchor**: dated "through `13acc06`"; two daemon reflow
   commits landed after. Content-only-reflow, no factual staleness — but the
   anchor line is already one commit behind. Cosmetic.

## c) NOT STARTED

1. **Repo self-CI gate** (`.github/workflows/ci.yml`) — TODO_LIST High row.
   Not started because the repo never had CI; see question g)2.
2. **Schema regression corpus** (`tests/` fixtures + runner) — TODO_LIST High
   row. Currently schema behavior is verified by one-off manual runs.
3. **docs-gates adoption** (+ optional `.docs-gates.json` seed) — TODO_LIST.
4. **M15 30-day fleet rollout review** (~2026-12-02) — TODO_LIST; waiting on
   the date, aggregates per-repo signal/noise.
5. **Cross-repo wiring** (consumer policy-vet CI lanes, BuildFlow detect-only
   step "M11") — owned by consumer repos / the BuildFlow repo; deliberately
   not mirrored here (TODO_LIST footnote).
6. **`#Changelog` schema** — DEMAND_GATED (FEATURES row); built only on a
   real consumer demand signal.
7. **Release/tagging strategy** — blocked on question g)1.

## d) TOTALLY FUCKED UP

1. **README's flagship consumer command was broken for 12 days.** From the
   first commit (081e3dc, 2026-11-02), README documented
   `cue vet -c '#ReleaseWorkflow' <file>` — which FAILS on the pinned cue
   0.17.1 (`cannot determine package name for "#ReleaseWorkflow"; set it
   explicitly with ':'`). Severity: Critical for any consumer following the
   docs verbatim; the repo's entire purpose is being the trusted policy
   source. Root cause: no CI gate on this repo, and no session ever EXECUTED
   the documented command — including my turn 1: I wrote a different (working)
   form into AGENTS.md without testing README's, which is how the break
   survived my own first pass. Fixed + verified this session (see a)3).
2. **Turn-1 AGENTS.md shipped the exact defects the docs-health catalog
   names**: inline commit hash, dated qualifiers, "currently v0.17.1",
   changelog-narrative, and a near-full duplicate of README's pin-watching
   protocol. Root cause: I authored AGENTS.md without loading the
   agents-quality-guide (loaded it only during turn 2's audit). Self-caused
   rework, caught one turn later by my own audit — the audit working is not
   an excuse for the authoring debt.
3. **One multiedit edit failed** on a wrap mismatch (pin-watching section) —
   recovered by re-reading exact text. No damage; pure process waste.

## e) WHAT WE SHOULD IMPROVE

1. **Verify-before-documenting, in the same turn.** Any command written into
   a doc gets executed before the doc is saved. (Turn 1 violated this for a
   command I copied from a sister doc; turn 2's Critical find was the bill.)
2. **Load a skill's quality guides BEFORE authoring**, not only when auditing.
   The agents-quality-guide existed; authoring without it manufactured the
   turn-2 findings.
3. **Mechanical link checking** instead of asserting "every link resolves".
4. **Determine generator ownership before reformatting generated files** —
   or pre-emptively dprint-exclude them (pending g)3).
5. **Run the tool before claiming its behavior** — the docs-gates "no inputs"
   claim was read, not measured (verify-external-claims principle).
6. **Multi-file fact drift risk introduced**: "this repo has no CI" now lives
   in AGENTS.md (orientation), FEATURES.md (status note), and TODO_LIST
   (evidence). When CI lands, three docs must flip together. The TODO_LIST
   row is the tripwire; consider a canonical-facts check when the CI gate is
   built.
7. **TODO_LIST row granularity**: never emit a "part of the row above" row —
   merge or split cleanly (fixed this turn).
8. **Ghost systems / split brains / removed-useful check** (self-review
   questions): no ghost systems found — both schemas are live and consumed;
   the one removed-useful item (the `(devel)` gotcha) was restored this turn;
   the no-CI triplication in e)6 is the only split-brain-shaped risk found.

## f) Next tasks

23 honest items (padding to 50 would manufacture noise). Routed: **T** = in
TODO_LIST, **R** = in ROADMAP, **X** = cross-repo (owned elsewhere), **Q** =
blocked on a question below.

| #  | Task                                                                                                        | Impact | Effort | Category      | Route |
| -- | ----------------------------------------------------------------------------------------------------------- | ------ | ------ | ------------- | ----- |
| 1  | CI gate: ci.yml running `cue vet -c .` + `dprint check` + `cue fmt` check (dprint does not cover .cue)      | High   | M      | Quality       | T     |
| 2  | Dogfood `#CIWorkflow` on the new ci.yml (`cue vet -d '#CIWorkflow' . .github/workflows/ci.yml`)             | High   | S      | Quality       | T(1)  |
| 3  | Schema regression corpus: conformant + non-conformant fixtures + assert pass/fail runner, wired into CI     | High   | M      | Quality       | T     |
| 4  | Wire docs-gates battery into CI; seed `.docs-gates.json` only if defaults misfit                            | Med    | S      | Quality       | T     |
| 5  | M15 30-day fleet rollout review (~2026-12-02): aggregate per-repo signal/noise, re-affirm/adjust ADOPT      | Med    | M      | Documentation | T     |
| 6  | Decide release/tagging strategy (v0.1.0 vs SHA-pins forever) — unblocks consumer version pins               | High   | S+M    | Decision      | Q1    |
| 7  | On schema changes: notify/bump consumer cue-policy SHA pins (protocol exists in AGENTS; make it a habit)    | Med    | S      | Process       | —     |
| 8  | Fleet audit: verify each consumer repo pins cue version + cue-policy SHA (two-pin contract holds)           | Med    | M      | Quality       | X     |
| 9  | Verify wave-1 concurrency remediation landed in library-policy, go-etag, go-error-family                    | Med    | S      | Quality       | X     |
| 10 | Verify the httputil provenance doc path cited in README Status actually exists                              | Low    | S      | Documentation | X     |
| 11 | BuildFlow detect-only policy-vet step ("M11") so non-adopters see drift                                     | Med    | M/L    | Feature       | X     |
| 12 | Pin-watch sweep when cue v0.18 ships (self-check + consumer invocations BEFORE any pin bump)                | Med    | S      | Process       | —     |
| 13 | Mechanical markdown link checker for docs (one-off script or gate leg)                                      | Low    | S      | Quality       | —     |
| 14 | Identify generators for `.config/metadata.yaml` / `SECURITY.md`; dprint-exclude them if they rewrite format | Low    | S      | Cleanup       | Q3    |
| 15 | `#Changelog` schema (CHANGELOG.md compare-link rules)                                                       | Low    | M      | Feature       | R/Q   |
| 16 | README footer links to the living docs (CHANGELOG, FEATURES, ROADMAP, TODO_LIST)                            | Low    | S      | Documentation | —     |
| 17 | Re-date the FEATURES sweep line on the next schema change (anchor is `13acc06`+reflows)                     | Low    | S      | Documentation | —     |
| 18 | securitymd re-run before any first tagged release (SECURITY.md freshness)                                   | Low    | S      | Documentation | Q1    |
| 19 | Meta inventory entry revisit after the docs expansion (tags/importance in `.config/metadata.yaml`)          | Low    | S      | Cleanup       | —     |
| 20 | GitHub repo description/topics for discoverability                                                          | Low    | S      | Documentation | —     |
| 21 | Consider a canonical-facts check (no-CI triplication, pin number single-home) as a CI leg                   | Low    | M      | Quality       | —     |
| 22 | docs/status README index once a second report lands (fleet live-index convention)                           | Low    | S      | Documentation | —     |
| 23 | Encode the delta-matrix negative control as an automated test when corpus (f)3 exists                       | Med    | S      | Quality       | T(3)  |

## g) Questions I cannot answer myself

1. **Should this repo cut tagged releases (e.g. v0.1.0), or stay commit-SHA
   pinned forever?** I tried to answer: CHANGELOG ("no releases tagged"),
   the adoption memo, and README pin-watching all describe SHA pinning and
   none states a release policy — there is no recorded intent either way.
   This decides how consumers learn about breaking schema changes (tags +
   semver vs. reading CHANGELOG + manual SHA bumps) and gates f)6/f)18.
2. **Does the absence of `.github/workflows/` in this repo mean "not yet" or
   "deliberately gate-less"?** I grepped every doc for self-CI intent —
   nothing either way. My TODO_LIST assumes "not yet" (a policy repo whose
   own invariants rot is a bad look — the broken README command proves the
   failure mode). If it was deliberate minimalism, rows 1–4 get dropped.
3. **Do the tools that generate `.config/metadata.yaml` and `SECURITY.md`
   rewrite those files in their own formatting on regeneration?** I cannot
   run the generators from here. The answer picks between dprint-excluding
   them (stop fighting the generator) and the current re-fmt-after-regen
   gotcha in AGENTS.md.
