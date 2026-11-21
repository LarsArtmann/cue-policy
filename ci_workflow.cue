package policy

// #CIWorkflow pins the invariants shared by the fleet's continuous
// workflows (ci.yml, nightly-fuzz.yml shapes): least-privilege read-only
// contents permission, exact GOTOOLCHAIN pins wherever a GOTOOLCHAIN env is
// set (the skew-preflight contract from the 2026-10-05..09 nightly crash
// streak), the runner allowlist (ubuntu-latest, plus ubuntu-24.04-arm
// for arch-specific native jobs), and SHA-pinned actions.
// Trigger sets vary per workflow (push+PR vs schedule+dispatch, with
// fleet-legal path filters) and are only shape-checked here. Top-level env
// beyond GOTOOLCHAIN is fleet-legal and unconstrained. Concurrency is
// deliberately NOT required for CI workflows — encoding that would be new
// fleet policy, and policy schemas only encode rules the fleet has already
// decided.
#CIWorkflow: {
	name!: string

	on!: {
		push?: {
			branches?: [...string]
			paths?: [...string]
			"paths-ignore"?: [...string]
			tags?: [...string]
			...
		}
		pull_request?: null | {
			branches?: [...string]
			paths?: [...string]
			"paths-ignore"?: [...string]
			...
		}
		schedule?: [...{cron!: string}]
		workflow_dispatch?: _
		...
	}

	// CI workflows never publish: contents stays read. Additional scopes
	// (issues: write for nightly fuzz findings, id-token for OIDC) must be
	// explicit string levels, never implicit.
	permissions!: {
		contents!: "read"
		[string]:  "read" | "write" | "none"
	}

	// The skew-preflight contract: IF a GOTOOLCHAIN env exists anywhere in
	// the workflow, it must be an exact patch pin (goX.Y.Z). Other env
	// keys are fleet-legal and unconstrained.
	env?: {
		GOTOOLCHAIN?: string & =~"^go[0-9]+\\.[0-9]+\\.[0-9]+$"
		...
	}

	jobs!: [string]:
		// A job is a run job (the default lane) or a reusable-call job
		// (job-level `uses` naming a reusable workflow or local action).
		// GitHub's grammar makes the pair mutually exclusive: a call job
		// MUST NOT carry runs-on/steps (the API rejects them), a run job
		// must carry both. Before 2026-11-21 the policy required
		// runs-on/steps unconditionally, making every reusable-call job
		// unsatisfiable — the shape that forced workflow-staging commits
		// fleet-wide through --no-verify (cmdguard SU45/T27).
		{
			// Runner allowlist: the default x86 hosted lane, plus GitHub's
			// arm64 hosted runner for arch-specific jobs that must execute
			// natively (e.g. an aarch64 TCG boot proof: an x86 runner
			// cannot run that suite, and the arm label is free for public
			// repositories; decided in nix-international-telephony's
			// ci.yml check-aarch64 job, 2026-11-10).
			"runs-on"!: "ubuntu-latest" | "ubuntu-24.04-arm"
			steps!: [...{
				uses?: string & =~"^[^@ ]+@[0-9a-f]{40}( .*)?$"
				...
			}]
			// Job-level uses would make this a reusable-call job; the
			// bottom value prunes this branch so the disjunction
			// resolves to the call-job lane instead of staying open.
			uses?: _|_
			...
		} | {
			// GitHub forbids runs-on/steps on call jobs; runs-on is not
			// modeled here, and the steps bottom-discriminator prunes
			// this branch for run jobs.
			uses!:  string
			steps?: _|_
			...
		}
	...
}
