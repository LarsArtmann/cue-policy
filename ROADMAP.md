# Roadmap

> Long-term direction and raw ideas. Items here are NOT actionable tasks.
> When an idea is refined into bounded work, it moves to `TODO_LIST.md`.

## Themes

### 1. Grow the schema family — on demand

The repo exists to machine-check "the data files every repo repeats by hand";
GitHub workflows are only the start. New schemas follow a demand signal, not
a plan: author one when a fleet repo actually wants it vetted.

Raw ideas:

- `#Changelog` schema for the CHANGELOG.md compare-link rules (explicitly
  deferred there in `release_workflow.cue`'s header comment — they are a
  CHANGELOG policy, not a workflow policy)
- Other fleet-repeated data files beyond workflows (whatever the fleet ends
  up hand-copying between repos)

### 2. Fleet-wide enforcement

The schemas only protect repos whose CI actually runs the vet. Direction:
every fleet repo's CI pins both the cue tool and this repo's SHA, with a
BuildFlow detect-only step so non-adopters at least see the drift.

Raw ideas:

- Complete policy-vet CI enablement across consumer repos (the BuildFlow
  detect-only step, "M11" in the rollout plan)
- A standing signal/noise review cadence after the 30-day review, deciding
  expansion (more schemas) or retirement per the adoption memo's triggers

## Non-goals

Deliberately NOT pursued (all decided in the adoption memo):

- **A Go dependency:** fleet policy (`how-to-golang`) owns in-Go validation
  (govalid/Huma/go-faster-yaml); `cuelang.org/go` stays out of fleet go.mod
  files.
- **An actionlint replacement:** expression semantics and injection checks
  are actionlint's core competency; both tools stay.
- **A source of new fleet policy:** schemas encode only rules the fleet has
  already decided elsewhere.
- **Step-order/step-presence contracts:** those stay with per-repo CI gates;
  this repo pins structural invariants only.
