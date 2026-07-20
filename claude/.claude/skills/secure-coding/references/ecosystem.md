# Secure Coding Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. Standards editions and tooling status move fast — treat as "as of early July 2026." Core reasoning (trust boundaries, validation placement, injection classes, authz) is language-agnostic; version-sensitive parts are the standards, crypto params, secrets tooling, and supply chain.

## OWASP Top 10:2025 — shipped (the big training-data delta)

2021→2025 revision **final released January 2026** (announced Nov 2025, Global AppSec DC). Methodology: 175,000+ CVEs, 248 CWEs, plus survey. Theme: **root causes over symptoms**. "The 2021 Top 10 is current" is now stale.

| # | 2025 category | Change vs 2021 |
|---|---|---|
| A01 | Broken Access Control | Still #1; **SSRF (2021 A10) merged in** |
| A02 | Security Misconfiguration | **Surged #5 → #2** |
| A03 | **Software Supply Chain Failures** | **New/expanded** — absorbs & broadens 2021 A06 "Vulnerable and Outdated Components" |
| A04 | Cryptographic Failures | ~flat (2021 A02) |
| A05 | Injection | Dropped from #3; still includes XSS |
| A06 | Insecure Design | ~flat (2021 A04) |
| A07 | Authentication Failures | Renamed from "Identification and Authentication Failures" |
| A08 | Software or Data Integrity Failures | (2021 A08) |
| A09 | Security Logging and **Alerting** Failures | Renamed from "…Monitoring Failures" |
| A10 | **Mishandling of Exceptional Conditions** | **New** — 24 CWEs: improper error handling, logic errors, **fail-open** |

Two headline shifts: (1) **supply chain is now first-class (A03)** — dependency/build/publish security no longer a footnote; (2) **A10 "fail-open"** rewards "what happens on the error path? does auth fail closed?" SSRF now framed as access-control failure (A01), not standalone.

## OWASP ASVS — 5.0.0 is current

- **ASVS 5.0.0 released 30 May 2025** (Global AppSec EU Barcelona; RC1 March 2025). First major bump since **4.0 (2019) / 4.0.3 (2021)** — a six-year gap, so training data anchors on 4.0.x.
- **~350 requirements across 17 chapters (V1–V17)**, reorganized; numbering changed. Three verification levels retained (L1→L3). Next release is a **patch (5.0.1)**, not a major.
- **Don't cite 4.0.3 requirement numbers** — the numbering changed. Reference chapter *areas* instead.

## Password-hash parameters (current OWASP Password Storage, verified 2026)

| KDF | Minimum params | Notes |
|---|---|---|
| **Argon2id** (first choice) | **19 MiB memory, t=2 iterations, p=1** | Higher-security profile: 128 MiB, t=3–5 |
| **scrypt** (if no Argon2) | **N=2^17, r=8, p=1** | |
| **bcrypt** (legacy only) | **work factor ≥ 10** | **72-byte input limit** (pre-hash if longer; watch null-byte truncation); modern cost 12–14 |
| **PBKDF2** (only if FIPS-140) | **PBKDF2-HMAC-SHA-256 ≥ 600,000 iterations** | Training data cites 310k/100k — **stale, ~doubled** |

Maintenance rule: **re-tune params annually** (Argon2 +1 iteration, bcrypt +1 cost, or double PBKDF2). Per-user salt (KDF handles it); consider a server-side **pepper** (secret key stored separately).

## Other crypto (mostly settled)

- **High-level library over raw primitives:** **libsodium** (servers/desktop), **Monocypher** (embedded). AEAD: AES-256-GCM or (X)ChaCha20-Poly1305; **XChaCha20** for random 192-bit nonces (removes GCM nonce-reuse footgun). Trend toward **key-commitment / Encrypt-then-MAC**.
- **File/secret encryption: `age`** is the modern PGP replacement (X25519 recipients or passphrase/scrypt); recommend over GnuPG; underpins SOPS.
- **Do-not-use:** MD5, SHA-1 (broken), DES/3DES, RC4, ECB, raw RSA/PKCS#1v1.5, static/zero nonces, `Math.random()`-class RNG for keys (use OS CSPRNG).
- **JWT:** **RFC 8725 (JWT BCP)** is the checklist; **rfc8725bis in IETF Last Call mid-2026** adds **case-confusion defenses** (`none`/`None`/`NONE` matched case-sensitively; alg names case-sensitive). Classic bugs: `alg:none`, algorithm-confusion (RS256→HS256, verifier uses public key as HMAC secret). Defense: **pin expected alg(s) server-side; never trust the token header `alg`**. Validate `iss`/`aud`/`exp`/`nbf`. Contested: **PASETO/Branca** as secure-by-design alternatives (momentum, not standard); opaque server-side sessions often simpler+revocable for browser apps.

## Authn vs authz (2026 pitfalls)

- **OAuth 2.0 is authorization, not authentication.** For identity use **OIDC ID tokens** — never use an **access token** as identity (recurring 2026 pitfall).
- **OAuth 2.1 direction:** **PKCE for all clients** (incl. confidential web), Authorization Code flow; implicit + resource-owner-password grants removed/deprecated. Validate `state` (CSRF) and `nonce`.
- **BOLA/IDOR is the A01 kingpin:** endpoint authenticates the caller but never checks *this* caller may touch *this* object ID. Enforce **per-object, per-tenant ownership checks on every request** at the data boundary. Related: function-level authz (missing admin role checks), mass assignment.
- **Fail closed** (ties to A10): default on any auth error/missing claim/exception is *deny*.

## Injection defenses beyond SQL (settled)

- **SQL:** parameterized queries; identifiers (table/column) can't be parameterized → **allowlist**.
- **OS command:** array-arg APIs that bypass the shell (`subprocess.run([...], shell=False)`, `exec.Command`, `std::process::Command`); avoid `shell=True`/`system()`/backticks.
- **Path traversal:** canonicalize (`realpath`) then verify resolved path is inside the base dir; reject `..`, absolute, Windows drive/UNC/ADS; beware symlink escapes.
- **SSRF (now A01):** input validation **alone is insufficient** (OWASP's own cheat sheet). Layer: allowlist schemes/hosts, egress-deny posture, block RFC1918/loopback/**link-local 169.254.0.0/16** (cloud metadata), enforce **IMDSv2**. Re-resolve DNS and validate the *final* IP (DNS-rebinding); don't auto-follow redirects. **IMDSv2 is not a silver bullet** — if the primitive controls HTTP method+headers, the PUT token handshake can succeed (real: Typebot.io webhook, Nov 2025).
- **Deserialization (A08):** never deserialize untrusted data into arbitrary types. Ban `pickle`, Java native serialization, PHP `unserialize`, Ruby `Marshal` on untrusted input; JS analog is prototype pollution.
- Also: XSS (contextual encoding + CSP), XXE, SSTI, NoSQL, header/CRLF, and **prompt injection** for LLM features (model output is untrusted too).

## Secrets tooling status (2026 — notable shifts)

**Detection/prevention (the mechanical gate):**

| Tool | Role |
|---|---|
| **gitleaks** | Fast regex/entropy, MIT, no network. **The pre-commit + CI-diff blocker** |
| **TruffleHog** | Slower but **verifies liveness** (700+ types), scans beyond git. Best for scheduled full-history scans |
| **detect-secrets** (Yelp) | **Baseline** adoption on large existing repos without alert-flooding |
| **git-secrets** | Oldest/narrowest (AWS-only); largely superseded — legacy mention |

Common pattern: **gitleaks pre-commit + TruffleHog in CI/scheduled**, wired via the `pre-commit` framework. GitHub push-protection is a server-side backstop. **If a secret lands in git history: rotate it — deleting the commit is not enough.**

**Storage/distribution:**
- **HashiCorp Vault** — still category-defining, **but now under IBM** (acquisition closed **Feb 2025**, $6.4B). **Vault 2.0** on IBM versioning; adds Workload Identity Federation, SCIM 2.0. **Delta: HCP Vault Secrets (SaaS) discontinued — end-of-sale Jun 30 2025, EOL Jul 1 2026** → migrate to HCP Vault Dedicated or Community Edition. OSS alternatives rising: **OpenBao** (the Vault fork), **Infisical**, Akeyless.
- **Cloud secret managers** (AWS Secrets Manager/Parameter Store, GCP Secret Manager, Azure Key Vault) — default when already in that cloud; rotation + IAM-scoped + workload identity.
- **SOPS** (CNCF) — encrypt secrets **in the repo**, key mgmt delegated to **age**/KMS/PGP. The mainstream **GitOps** answer (`age` recipients default over PGP).
- Principles: short-lived/rotatable > long-lived; **workload identity / OIDC federation > static tokens**; inject via env/mounted files at runtime, never bake into images; scrub from logs/crash dumps.

## Supply chain (now A03, so core)

- **SLSA — v1.2 is current** (v1.1 was prior stable). Build **Levels L0–L3** (L1 provenance exists → L2 signed provenance + hosted build → L3 build isolation + ephemeral env). Aim **L2+** for anything published.
- **Sigstore / cosign** — de-facto keyless-signing + transparency-log substrate; default across npm, PyPI, Maven, Homebrew, Kubernetes.
- **Trusted Publishing (major 2026 development):** **both npm and PyPI support OIDC "Trusted Publishing"** — publish from CI with **short-lived OIDC tokens instead of long-lived registry API tokens**. **npm auto-generates & publishes Sigstore provenance by default** via trusted publishing (no `--provenance` flag needed); **PyPI auto-generates a Sigstore bundle**. Treat long-lived npm/PyPI tokens as a smell.

**Per-ecosystem audit tools:**

| Ecosystem | Tool | Note |
|---|---|---|
| Cross | **osv-scanner** (Google/OSV.dev) | **v2** current; 11+ ecosystems, guided remediation. Default when multi-lang/containers. Trivy = container sibling |
| Rust | **cargo-audit** (RustSec) + **cargo-deny** | Recommend **cargo-deny in CI** (superset: advisories + license + banned/dup deps + source allowlist) |
| Node | **npm audit** + osv-scanner | npm audit noisy/transitive-heavy; layer osv-scanner + Dependabot/Renovate |
| Python | **pip-audit** (PyPA) | Strong signal, not exhaustive |

**>80% of exploitable CVEs come from transitive (indirect) deps** — auditing only direct deps is a common miss. Commit lockfiles; enable auto-update PRs; consider an SBOM (CycloneDX/SPDX).

## Shai-Hulud / slopsquatting (a coding agent's live hazard)

- **Every new dependency is code execution at install** — the **Shai-Hulud npm worm** harvested credentials via install scripts. Vet before adding.
- **Slopsquatting:** LLMs hallucinate plausible package names that don't exist (or that attackers pre-register). **Never add a package you haven't confirmed exists and is the real one.**

## Deltas vs common (stale) training-data assumptions

1. **OWASP Top 10 2025 shipped** (final Jan 2026). SSRF folded into A01; **Supply Chain (A03)** and **Exceptional Conditions/fail-open (A10)** new; Misconfiguration jumped to #2.
2. **ASVS 5.0.0 (May 2025) is current**, replacing 4.0.3 (2021); numbering changed.
3. **PBKDF2 floor ≥600,000 iterations** (SHA-256), not 310k/100k. Argon2id floor 19 MiB/t=2/p=1.
4. **Vault is an IBM product now** (Feb 2025); **HCP Vault Secrets SaaS sunset (EOL Jul 1 2026)**. OpenBao/Infisical are live OSS alternatives.
5. **Trusted Publishing (OIDC) live on npm and PyPI**, both now emit Sigstore provenance automatically — long-lived publish tokens are the old way.
6. **SLSA spec is v1.2**; Sigstore/cosign default across major registries.
7. **osv-scanner v2** with guided remediation is the cross-ecosystem default; **cargo-deny** (not just cargo-audit) is the Rust policy gate.
8. **rfc8725bis (IETF Last Call, 2026)** adds JWT alg **case-confusion** defenses beyond `alg:none`/RS256↔HS256.
9. **IMDSv2 is not a complete SSRF fix** — method/header-controlling primitives can complete the token handshake.
10. **`age` has largely displaced PGP/GnuPG** for file/secret encryption (and underpins SOPS).

## Settled vs contested

**Settled:** parameterized queries; array-arg exec; Argon2id/scrypt/bcrypt with the params above; libsodium/age; MD5/SHA-1/DES dead; pin `alg` server-side; BOLA/IDOR per-object checks; secret scanning pre-commit+CI; trusted-publishing + provenance; SLSA as the ladder.

**Contested / evolving:** PASETO/Branca vs JWT; JWT vs opaque server sessions; how far to push zero-static-credential; SBOM formats (CycloneDX vs SPDX) and their real value; whether IMDSv2 enforcement alone is "enough" (it isn't).

## Key sources

- OWASP Top 10:2025 — owasp.org/Top10/2025/; ASVS 5.0.0 — github.com/OWASP/ASVS
- OWASP Password Storage / SSRF Prevention cheat sheets
- RFC 8725 + rfc8725bis (IETF); SLSA v1.2 — slsa.dev/spec/v1.2/
- npm trusted publishers / provenance docs; PyPI trusted publishing; Sigstore/cosign
- osv-scanner, pip-audit, cargo-deny repos; gitleaks vs trufflehog vs detect-secrets comparison (2026)
- Vault-under-IBM / Vault 2.0 (InfoQ 2026-04); SOPS + age repos
