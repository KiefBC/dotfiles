# TypeScript Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. Current stable: **TS 6.0** (Mar 23, 2026, the last JS-codebase release); **TS 7.0** (Go-native "tsgo") RC shipped Jun 18, 2026, GA expected ~late July 2026. The TS 6→7 transition is mid-flight; dates matter.

## Compiler timeline

| Release | Date | What it is |
|---|---|---|
| TS 6.0 | Mar 23, 2026 | Last release on the JavaScript codebase; current stable. A **bridge release** — flips defaults, deprecates everything TS 7 drops. |
| TS 7.0 (tsgo) | RC Jun 18, 2026; GA ~late Jul 2026 | Go-native port, **not a rewrite** — identical type-checking semantics, ~10x faster (VS Code check ~78s → ~7.5s), parallel checking. Preview: `@typescript/native-preview` (`npx tsgo`). |
| TS 7.1 | after 7.0 | Stable programmatic API lands here, **not in 7.0**. |

Deprecated options **error** in 6.0 (unless `"ignoreDeprecations": "6.0"`) and are **removed entirely in 7.0**.

## TS 6.0 changed defaults

Empty tsconfig now yields:

| Option | Old default | New default (6.0) |
|---|---|---|
| `strict` | `false` | **`true`** |
| `module` | `commonjs` | **`esnext`** |
| `target` | `es2020` | **`es2025`** (floating current-year) |
| `types` | all `@types/*` | **`[]`** (list explicitly, e.g. `["node"]`) |
| `noUncheckedSideEffectImports` | `false` | **`true`** |
| `rootDir` | inferred | **`.`** (tsconfig dir) |
| `libReplacement` | `true` | `false` |

**Deprecated in 6.0 / removed in 7.0:** `target: es5`, `downlevelIteration`, `moduleResolution: node` (node10) and `classic`, `module: amd/umd/system/none`, `baseUrl` (use `paths` with explicit prefixes), `esModuleInterop: false`, `alwaysStrict: false`, `outFile` (use a bundler), legacy `module` keyword for namespaces, import `asserts` (use `with`).

**Migration state mid-2026:** stay on TS 6.0 stable for emit and day-to-day; run `tsgo --noEmit` as a non-blocking CI job beside `tsc --noEmit` to compare diagnostics (`--stableTypeOrdering` in 6.0 helps diff output). Bloomberg, Canva, Figma, Google, Slack, Vercel tested the native port pre-release. Expect tsgo to be the default checker for most codebases by late 2026. Settled division of labor: tsc/tsgo is the **type checker** (`--noEmit`) and `.d.ts` emitter; **transpilation belongs to bundlers** (Vite/esbuild/SWC/tsup/Rolldown); Node type stripping runs scripts directly. Never use `tsc` as the production build emitter.

## Node.js: run `.ts` directly

- **Current LTS mid-2026: Node 24** (Node 22 in maintenance; Node 26 is Current, LTS Oct 2026).
- **Type stripping is Stability 2 (Stable)** as of v24.12.0 / v25.2.0; enabled **by default** since v22.18.0 / v23.6.0. `node app.ts` just works — no flags, no `ts-node`, no build step. Node 26 removed the `--experimental-transform-types` flag.
- Mechanism: types replaced with whitespace (via `amaro`/SWC) — **no type checking is performed**; line numbers preserved, no sourcemaps needed.
- **Only erasable syntax runs.** `ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX` on: `enum`, namespaces with runtime code, class parameter properties, `import x = require(...)` aliases, legacy decorators. Type-only namespaces are fine.
- `tsconfig.json` is **ignored** at runtime: no `paths` aliases, no downleveling. Type-only imports **must** use `import type`. TypeScript source in `node_modules` is rejected — don't publish `.ts`.
- Corollary: write erasable TS (the same subset works in Node, Bun, Deno, every strip-only transpiler); enforce with `erasableSyntaxOnly: true` (added TS 5.8).

## ESM vs CJS — settled

- **`require(esm)` is stable and unflagged** on all supported LTS lines (v20.19+, v22.12+, marked stable late 2025). CJS consumers can synchronously `require()` ESM — the last blocker is gone.
- Ecosystem: ~65% of *new* npm packages ship ESM-first/only (2026); of the top 1000, ~42% ESM-only, ~38% dual, ~20% CJS-only. NestJS v12 going full ESM.
- New code: `"type": "module"`, write ESM. Libraries: ESM-only acceptable; dual-publish via `exports` only to support Node < 20.19. Never write new CJS.

## Runtime validation landscape

| Library | Status | Pick when |
|---|---|---|
| **Zod v4** | Current (2025 rewrite): much faster than v3, core 57% smaller; `zod/mini` ~3.9 kB gz tree-shakeable. **Default choice** — largest ecosystem gravity. | Default. |
| Valibot 1.x | Smallest bundles (~1.4 kB gz small schema; modular). | Client bundle size is a hard constraint. |
| ArkType 2.x | Fastest runtime (~1.7–4x Zod 4), TS-syntax DSL. | Type-driven authoring. |

**Standard Schema** is the 2026 interop story: Zod 4, Valibot, ArkType, TypeBox all conform; tRPC, TanStack Form, etc. accept any conforming schema. In library APIs accept `StandardSchemaV1` rather than hard-coding Zod. All three validators are credible; none is "wrong."

## Tooling defaults (mid-2026)

| Concern | Default | Notes |
|---|---|---|
| Lint | **ESLint 10 + typescript-eslint v8** | ESLint 10 (Feb 2026) **removed eslintrc entirely** — flat `eslint.config.js` only; `LegacyESLint` compat gone; requires Node ≥ 20.19. typescript-eslint v8+ required (v7 lacks flat-config). Use `config()` helper + `projectService: true` for type-aware rules. |
| Lint/format alt | **Biome 2.3** | Type-aware linting **in-process** (no tsc server), 423+ rules, 10–20x faster; `noFloatingPromises` catches ~85% of typescript-eslint's. Common hybrid: Biome format+lint, thin ESLint layer for type-aware gaps. Oxlint is the third player (fast, fewer rules). |
| Format | Prettier or Biome | Either fine; don't hand-format. |
| Tests | **Vitest 4** | Default for new TS projects: TS/ESM out of the box, module-graph watch, top State-of-JS satisfaction; Angular 21 adopted as default. Jest only for React Native/legacy. `node:test` acceptable for zero-dep libraries. |
| Package manager | **pnpm** (safe default) | Best speed/disk/strictness; strict node_modules catches phantom deps. **Bun** viable greenfield (order-of-magnitude faster installs, runs TS natively) with minor compat risk; npm merely fine. Commit lockfile; use `corepack`/`packageManager`. |
| Run TS in dev | `node --watch app.ts` (or `tsx` for tsconfig-paths/older Node) | ts-node is legacy. |
| Build (libraries) | tsup/tsdown/unbuild + `tsc --emitDeclarationOnly` | Ship ESM + `.d.ts`. |
| Typecheck in CI | `tsc --noEmit` now; parallel `tsgo --noEmit` | Swap to tsgo as blocking once diagnostics match. |

## Type-idiom version notes

- **Inferred type predicates** (`.filter(x => x !== null)` narrows; simple `x is T` guards inferred): TS ≥5.5.
- **`NoInfer<T>`** utility: TS 5.4+.
- **`erasableSyntaxOnly`**: TS 5.8.
- Zod branding: `z.string().uuid().brand<"UserId">()`.

## Key sources

- devblogs.microsoft.com/typescript/announcing-typescript-6-0 · visualstudiomagazine.com (TS 6.0 final JS release, 2026-03-23; TS 7.0 RC, 2026-06-22)
- github.com/microsoft/typescript-go · typescriptlang.org/tsconfig/erasableSyntaxOnly
- nodejs.org/api/typescript.html (v26.4.0) · joyeecheung.github.io/blog/2025/12/30 (require(esm) stability) · pkgpulse.com (CJS→ESM migration 2026)
- pkgpulse.com (Zod v4 vs ArkType vs Valibot 2026; Biome vs ESLint vs Oxlint 2026; node:test vs Vitest vs Jest 2026; State of TS tooling 2026) · valibot.dev/guides/comparison
- eslint.org/blog/2026/02/eslint-v10.0.0-released · typescript-eslint.io/getting-started · hirenodejs.com/blog/nodejs-package-managers-2026
