package policy

// #CIWorkflow pins the invariants shared by the fleet's continuous
// workflows (ci.yml, nightly-fuzz.yml shapes): least-privilege read-only
// contents permission, exact GOTOOLCHAIN pins wherever a GOTOOLCHAIN env is
// set (the skew-preflight contract from the 2026-10-05..09 nightly crash
// streak), the ubuntu-latest runner allowlist, and SHA-pinned actions.
// Trigger sets vary per workflow (push+PR vs schedule+dispatch) and are
// only shape-checked here. Concurrency is deliberately NOT required for
// CI workflows — encoding that would be new fleet policy, and policy
// schemas only encode rules the fleet has already decided.
#CIWorkflow: {
	name!: string

	on!: {
		push?: branches?: [...string]
		pull_request?: branches?: [...string]
		schedule?: [...{cron!: string}]
		workflow_dispatch?: _
		...
	}

	// CI workflows never publish: contents stays read. Additional scopes
	// (e.g. issues: write for nightly fuzz findings) must be explicit
	// string levels, never implicit.
	permissions!: {
		contents!: "read"
		[string]: "read" | "write" | "none"
	}

	// The skew-preflight contract: IF a GOTOOLCHAIN env exists anywhere in
	// the workflow, it must be an exact patch pin (goX.Y.Z).
	env?: GOTOOLCHAIN?: string & =~"^go[0-9]+\\.[0-9]+\\.[0-9]+$"

	jobs!: [string]: {
		"runs-on"!: "ubuntu-latest"
		steps!: [...{
			uses?: string & =~"^[^@ ]+@[0-9a-f]{40}( .*)?$"
			...
		}]
		...
	}
	...
}
