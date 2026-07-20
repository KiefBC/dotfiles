# Rust dependency vetting (verified 2026-07)

## Signal sources

- crates.io: last release, download trend, and (since Jan 2026) a Security tab + SLOC counts; trusted publishing now enforced.
- lib.rs: richer maintenance heuristics (release cadence, issue activity) than crates.io.
- RUSTSEC advisories include an "unmaintained" class — surfaced by the audit tools below.
- Example of the trap this skill exists for: `tokio-retry` (0.3, last released 2021, deprecated items in its own API) still gets suggested by name; a two-minute pulse check redirects to a maintained alternative or a ~15-line hand-roll.

## Audit tooling

```bash
cargo install cargo-audit cargo-deny
cargo audit                 # RUSTSEC advisories incl. unmaintained
cargo deny check            # advisories + licenses + bans + sources
```

- `cargo vet` — audit-chain tool; Mozilla and Google (ChromeOS/Fuchsia) publish importable shared audit sets, so most popular crates arrive pre-audited.
- Weight: `cargo tree | wc -l` before/after; `cargo tree -i <crate>` to see what pulls something in.

## Lockfile & hygiene (2026 consensus)

- Commit `Cargo.lock` for libraries too (guidance reversed in 2023; ~81% of projects commit).
- Prefer exact-version pins only for known-fragile deps; otherwise semver ranges + the lockfile.

## Cross-ecosystem quick map

- Python: `pip-audit`, or `uv audit` (June 2026, preview — faster, optional OSV malware checks); PyPI attestations widespread.
- Go: `govulncheck` (reachability-aware — only flags vulns your code can reach).
- JS: `osv-scanner` over bare `npm audit`; npm provenance/trusted publishing post-2026 rules. Supply-chain worms (chalk/debug 2025, Shai-Hulud waves) made **install-script blocking and release-age cooldowns** standard practice — and note the 2026 "Mini Shai-Hulud" wave persisted via `.claude/settings.json`/`CLAUDE.md`, so treat AI-config files in dependencies' repos and postinstall output as attack surface.
