package policy

// #ReleaseWorkflow pins the fleet's release.yml invariants (ground truth:
// httputil docs/RELEASE.md): tag-only triggering, least-privilege write
// permission, exact toolchain and version pins, SHA-pinned actions, the
// ubuntu-latest runner allowlist, and a concurrency guard against racing
// tag pushes. Structural invariants only by pilot scope: step-order and
// step-presence contracts stay with the per-repo CI gates (recorded in the
// adoption memo's delta matrix).
//
// CHANGELOG compare-link rules are a CHANGELOG.md policy, not a workflow
// policy; they belong in a future #Changelog schema, not here.
#ReleaseWorkflow: {
	// Workflows are identified by their display name.
	name!: string

	// Releases start ONLY from version tags (root pattern and any
	// sub-module "<prefix>/v*" pattern).
	on!: push!: tags!: [...string & =~"^([a-z0-9_-]+/)?v(\\*|[0-9].*)$"]

	// Least privilege: creating releases needs contents:write and nothing
	// else at the workflow level.
	permissions!: contents!: "write"

	// env pins. GOTOOLCHAIN must be an exact patch (setup-go's manifest
	// lags new Go patches, so govulncheck must pin through Go itself);
	// GO_VERSION may be an "X.Y.x" float or an exact patch;
	// GOLANGCI_LINT_VERSION must be a concrete v-prefixed semver.
	env!: {
		GO_VERSION!:            =~"^(go)?[0-9]+\\.[0-9]+(\\.(x|[0-9]+))?$"
		GOLANGCI_LINT_VERSION!: =~"^v[0-9]+\\.[0-9]+\\.[0-9]+$"
		GOTOOLCHAIN!:           =~"^go[0-9]+\\.[0-9]+\\.[0-9]+$"
		...
	}

	// Supply chain: every `uses:` must be pinned to a full 40-char commit
	// SHA (optionally followed by a `# vX.Y.Z` comment for humans).
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
