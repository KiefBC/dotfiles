---
name: secure-coding
description: Use when handling untrusted input, building an endpoint or file/network boundary, doing auth or sessions, touching secrets or crypto, adding or auditing a dependency, or when a task reassures you a boundary is "internal", "behind the VPN", or "already token-gated".
---

# Secure Coding

## Overview

Boundary-input instinct for the common injections is decent; the failures are trusting a reassurance ("it's internal / VPN / token-gated") and getting stale on the fast-moving parts (secrets norms, supply chain, crypto params). A network perimeter gates *who* reaches code — it does nothing against an authenticated caller, a stolen token, or an SSRF/XSS pivot.

<HARD-GATE>
1. **Map the trust boundary before writing/reviewing boundary code.** Name what's untrusted (request params, file names, headers, upstream responses) and validate it AT the boundary, ONCE, into a typed/constrained form. Capture the boundary as a one-line comment where the code lives. "Internal / behind the VPN / token-gated" does not move the boundary — a reassurance about the perimeter is not a reason to skip validation.
2. **Secrets never in code, logs, or VCS.** State where they actually live (env from a secret manager, OIDC-federated short-lived token). If you can't say where a secret lives, that's the finding.
</HARD-GATE>

## Injection is one bug class, many surfaces

Parameterize/escape at the boundary — never sanitize by string-munging:
- **SQL** → parameterized queries (never string-format values in).
- **Command** → arg arrays, never `shell=True`/string concatenation.
- **Path traversal** → reject `/`, `\`, `..`; then resolve the real path and confirm its parent is the intended dir (defeats symlink escape). `?name=../users.db` reads your DB.
- **SSRF** → allowlist destinations; a user-supplied URL is untrusted. (IMDSv2 is not a complete fix.)
- **Deserialization** → never deserialize untrusted data into live objects.

## Authn vs authz

- **Authentication** = who you are; **authorization** = what you may touch. OAuth is authorization — use OIDC ID tokens for identity, never an access token.
- The dominant real-world hole is **BOLA/IDOR**: object endpoints that check you're logged in but not that you own *this* object. Every `GET /thing/:id` needs a per-object ownership check.
- Pin JWT `alg` server-side (reject `none` and алгorithm-confusion); prefer PKCE.

## Crypto (use current parameters, not training-era ones)

- Passwords: **Argon2id** (≥19 MiB, t=2) preferred; scrypt; bcrypt (cost ≥10). If PBKDF2, **≥600,000** SHA-256 iterations — old 100k/310k figures are stale.
- Never roll your own; use libsodium/age. MD5/SHA-1/DES for security = automatic finding.

## Supply chain (a coding agent's live hazard)

- **Every new dependency is code execution at install** (the Shai-Hulud npm worm harvested credentials via install scripts). Vet before adding — see the dependency-vetting skill.
- **Slopsquatting**: LLMs hallucinate plausible package names that don't exist (or that attackers pre-register). Never add a package you haven't confirmed exists and is the real one.
- Run the ecosystem auditor (`cargo audit`/`cargo deny`, `pip-audit`, `osv-scanner`, `npm audit`); commit lockfiles; prefer OIDC trusted publishing over long-lived tokens.

## Red flags

| Flag | Reality |
|---|---|
| "It's internal / behind the VPN, so skip validation" | Perimeter ≠ authorization. Validate at the boundary anyway. |
| Sanitizing input by removing bad chars | Parameterize/allowlist; blocklists leak. |
| Secret in code "just for now" / printed in a log | It's in git history / log storage forever. Move it out. |
| Rolling a crypto primitive | Use a vetted library. |
| Adding a package by name without confirming it exists | Slopsquatting — verify it's real and correct first. |
| Validating "later" | Boundary code without validation is the vulnerability, now. |

OWASP Top 10:2025, ASVS 5.0, current crypto params, secrets tooling, SLSA/provenance, audit commands: see [references/ecosystem.md](references/ecosystem.md).
