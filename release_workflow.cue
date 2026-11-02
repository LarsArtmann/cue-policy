package policy

// #ReleaseWorkflow pins the fleet's release.yml invariants (ground truth:
// httputil docs/RELEASE.md): tag-or-dispatch triggering, least-privilege
// write permission, exact toolchain and version pins, SHA-pinned actions,
// the ubuntu-latest runner allowlist, and a concurrency guard against
// racing tag pushes. Structural invariants only by pilot scope: step-order
// and step-presence contracts stay with the per-repo CI gates (recorded in
// the adoption memo's delta matrix).
//
// Trigger shapes are fleet-wide legal (manual dispatch, input parameters,
// path filters on push) and are shape-checked, not restricted: the policy
// cares about what a workflow REQUIRES, not which knobs trigger it.
//
// CHANGELOG compare-link rules are a CHANGELOG.md policy, not a workflow
// policy; they belong in a future #Changelog schema, not here.
#ReleaseWorkflow: {
	// Workflows are identified by their display name.
	name!: string

	// Releases start from version tags (root pattern and any sub-module
	// "<prefix>/v*" pattern — glob or glob-ish spellings both allowed) or
	// from manual dispatch.
	on!: {
		push?: tags?: [...string & =~"^([a-z0-9_-]+/)?v"]
		workflow_dispatch?: _
		...
	}

	// Least privilege AT THE FLOOR: creating releases needs contents:write;
	// additional scopes (id-token for OIDC signing, packages) must be
	// explicit string levels.
	permissions!: {
		contents!: "write"
		[string]:  "read" | "write" | "none"
	}

	// Pin-format policy: IF one of the fleet's Go pins is present, it must
	// have the fleet's shape — GO_VERSION an "X.Y.x" float or exact patch,
	// GOLANGCI_LINT_VERSION a concrete v-prefixed semver, GOTOOLCHAIN an
	// exact patch (setup-go's manifest lags new Go patches, so
	// govulncheck must pin through Go itself). Absence is fleet-legal:
	// not every release workflow uses the setup-go env pattern.
	env?: {
		GO_VERSION?:            =~"^(go)?[0-9]+\\.[0-9]+(\\.(x|[0-9]+))?$"
		GOLANGCI_LINT_VERSION?: =~"^v[0-9]+\\.[0-9]+\\.[0-9]+$"
		GOTOOLCHAIN?:           =~"^go[0-9]+\\.[0-9]+\\.[0-9]+$"
		...
	}

	// One publish at a time per ref, never cancelling an in-flight release.
	// REQUIRED: this is the fleet's adopted release policy (the pilot's
	// first real finding — a racing tag push could collide with an
	// in-flight publish).
	concurrency!: {
		group!:                string
		"cancel-in-progress"!: bool
	}

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
