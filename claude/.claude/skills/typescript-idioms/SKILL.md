---
name: typescript-idioms
description: Use when writing or reviewing TypeScript — new modules, refactors, PR review, or porting code from Java/C#/JavaScript — especially when choosing tsconfig options, modeling state with unions, narrowing, validating untrusted input, structuring ESM/CJS, or picking lint/test/build tooling.
---

# TypeScript Idioms

## Overview

Makes code native modern TypeScript (target TS 6.0 semantics; TS 7 "tsgo" imminent). Encodes settled mid-2026 consensus: model with types, parse untrusted input, write erasable syntax, let tsc check and bundlers/Node execute.

Version-sensitive facts (compiler timeline, flag status, library landscape, tool versions): see [references/ecosystem.md](references/ecosystem.md).

Two failure modes to reject on sight:
- **Java/C#-in-TypeScript**: `enum`, `namespace`, classes-for-everything, `FooImpl` interfaces, getters/setters, inheritance where a union fits.
- **Untyped-JavaScript-in-TypeScript**: `any` everywhere, `as` casts to silence errors, no schema at boundaries, `catch (e: any)`, optional-field soup instead of unions.

## Core Idioms

### 1. Discriminated unions + exhaustive `never` check (the core idiom)

Model states so impossible states are unrepresentable. One literal discriminant per variant; a `never` assignment in `default` makes adding a variant a compile error.

```ts
// WRONG: boolean/optional soup — { loading:true, error:.., data:.. } is representable
interface State { loading: boolean; error?: Error; data?: User[] }

// RIGHT
type State =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "error"; error: Error }
  | { status: "success"; data: User[] };

switch (state.status) {
  case "success": return render(state.data);   // narrowed: data exists
  case "error":   return show(state.error);
  case "idle":
  case "loading": return spinner();
  default: {
    const _exhaustive: never = state;           // compile error if a variant is added
    throw new Error(`unhandled: ${_exhaustive as string}`);
  }
}
```

Narrow with `typeof`, `in`, `instanceof`, and the discriminant before reaching for hand-written guards. TS ≥5.5 **infers type predicates** for simple guards and `.filter()` callbacks — `arr.filter(x => x !== null)` narrows to non-null with no guard. Write a `x is T` predicate only when structural narrowing genuinely can't.

### 2. `satisfies` — check the shape without widening away inference

```ts
// WRONG: annotation erases literal-level knowledge
const routes: Record<string, string> = { home: "/", user: "/user/:id" };
routes.hoem;   // no error — any string key allowed

// WRONG: no annotation — typos in keys/values ship silently

// RIGHT: validate against the type, keep the precise inferred type
const routes = { home: "/", user: "/user/:id" } satisfies Record<string, string>;
routes.home;   // ok; routes.hoem is a compile error
```

Use for: config objects checked against an interface while keeping literal keys; `satisfies Record<Status, Handler>` = compile-time exhaustiveness for lookup tables; typed `as const` data.

### 3. `as const` objects over `enum` (the standard enum replacement)

`enum` is non-erasable — it crashes under Node type stripping and `erasableSyntaxOnly`. TS 6 defaults + Node's runtime make it legacy.

```ts
// WRONG: runtime enum
enum Level { Debug, Info, Warn }

// RIGHT: const object + derived union — erasable, tree-shakeable, same ergonomics
const Level = { Debug: "debug", Info: "info", Warn: "warn" } as const;
type Level = (typeof Level)[keyof typeof Level];   // "debug" | "info" | "warn"
```

Also: `as const` on tuples/args for precise inference; `[...] as const satisfies readonly Foo[]` to check element shape while keeping the literal tuple.

### 4. `unknown`, never `any`

`any` is contagious — it silently disables checking on everything it touches downstream. `unknown` forces narrowing at the point of use.

```ts
// WRONG
function parse(json: string): any { return JSON.parse(json); }

// RIGHT
function parse(json: string): unknown { return JSON.parse(json); }
const v = parse(s);
if (typeof v === "object" && v !== null && "id" in v) { /* narrowed */ }
```

`catch (e)` is `unknown` under strict (`useUnknownInCatchVariables`) — check `e instanceof Error` before touching `.message`. Lint `no-explicit-any` / `no-unsafe-*` enforce this.

### 5. Branded (nominal) types for validated primitives

```ts
// WRONG: structural aliases interchange freely
type UserId = string; type OrderId = string;
deleteOrder(userId);   // compiles, wrong at runtime

// RIGHT: phantom brand, zero runtime cost
declare const brand: unique symbol;
type Brand<T, B extends string> = T & { readonly [brand]: B };
type UserId = Brand<string, "UserId">;
const toUserId = (s: string): UserId => s as UserId;  // one blessed cast at the boundary
```

The validator is the only place the cast lives (in Zod: `z.string().uuid().brand<"UserId">()`). Use for IDs, sanitized strings, validated email, currency amounts.

### 6. Utility types — derive, don't duplicate

Know the built-ins before hand-rolling: `Partial`, `Required`, `Readonly`, `Pick`, `Omit`, `Record`, `Exclude`, `Extract`, `NonNullable`, `ReturnType`, `Parameters`, `Awaited`, `NoInfer` (5.4+).

```ts
// WRONG: mapped type reinventing Pick
type UserPreview = { [K in "id" | "name"]: User[K] };
// RIGHT
type UserPreview = Pick<User, "id" | "name">;
// RIGHT: one source of truth
type CreateUser = Omit<User, "id" | "createdAt">;
```

`interface` vs `type` is settled and boring: `interface` for object shapes you may extend/declaration-merge, `type` for unions/tuples/mapped/derived. Pick one house style, move on.

### 7. Template literal types — right-sized only

```ts
// RIGHT-sized: constraining string shapes
type Route = `/${string}`;
type EventName = `on${Capitalize<string>}`;
type CssVar = `--${string}`;
```

Type-level parsers, SQL engines, or string math in app code are WRONG — slow to check, unreadable errors, unmaintainable. That is library-author territory.

## Runtime validation: parse, don't validate

Untrusted data enters typed at exactly one place. Cast-and-hope is a lie to the compiler.

```ts
// WRONG: assert at the boundary, then shotgun-check
const user = (await res.json()) as User;
if (!user.email) throw new Error("bad");   // type is still a lie

// RIGHT: parse once; the schema is the source of truth, the type is derived from it
const UserSchema = z.object({
  id: z.string().uuid().brand<"UserId">(),
  email: z.string().email(),
  role: z.enum(["admin", "member"]),
});
type User = z.infer<typeof UserSchema>;
const user = UserSchema.parse(await res.json());   // or .safeParse for Result-style
```

Boundaries = HTTP responses, request bodies, env vars (`EnvSchema.parse(process.env)` at startup), queue messages, file/DB reads through untyped drivers, `JSON.parse`. Interior code trusts the types and never re-validates. In **library** APIs accept any `StandardSchemaV1` rather than hard-coding a validator. Default validator = Zod 4; see [references/ecosystem.md](references/ecosystem.md) for the landscape.

## Type-level vs runtime — keep them straight

| Concern | Lives in | Erased at runtime? |
|---|---|---|
| Shape correctness, narrowing, exhaustiveness | types (`type`/`interface`, `satisfies`, `never`) | yes — types are compile-only |
| Trust of external data | schema (`.parse` at boundary) | no — runs |
| Nominal identity of a validated value | brand (phantom type) + one cast in the validator | brand yes, cast site is the runtime gate |

A type annotation asserts a belief; it checks nothing at runtime. Never use `as` to make untrusted data "typed" — that is the untyped-JS anti-pattern wearing a type.

## Anti-Patterns

| Anti-pattern | Why wrong | Instead |
|---|---|---|
| `enum` / `namespace` / parameter properties | Non-erasable — crash under Node type stripping & `erasableSyntaxOnly` | `as const` objects + derived unions (§3); plain modules |
| `any` (or `as` to silence an error) | Contagious; disables checking; hides real bugs | `unknown` + narrow (§4); fix the type, don't cast past it |
| `as SomeType` on untrusted data | Lies to the compiler; no runtime check | Parse with a schema at the boundary |
| Boolean/optional-field soup for state | Impossible states representable | Discriminated union (§1) |
| `class`/inheritance where a union fits; `FooImpl implements Foo` | Java/C#-in-TS; interface-per-class ceremony | Union + functions; interface only for real polymorphism |
| Getters/setters wrapping plain fields | Java habit; no encapsulation gained | Public readonly fields, or a function |
| `catch (e: any)` then `e.message` | Defeats `useUnknownInCatchVariables` | `catch (e)` (unknown) + `e instanceof Error` |
| `tsc` as the production build emitter | tsc/tsgo are type checkers, not bundlers | Bundler/Node executes; `tsc --noEmit` checks |
| Re-enabling `baseUrl`, `moduleResolution: node`, `target: es5` | Deprecated in TS 6, removed in TS 7 | Trust TS 6 defaults; `paths` with explicit prefixes |

## Design patterns, natively

- **Strategy / dependency injection** = a function argument or an object of functions, not an interface hierarchy. `type Handler = (req: Req) => Res`.
- **Builder** = an object literal validated with `satisfies`, or a schema `.parse`; rarely a fluent class.
- **Enum / state machine** = discriminated union + `as const` map (§1, §3), not a class per state.
- **Result/Either** = `.safeParse`'s `{ success: true; data } | { success: false; error }`, or a discriminated union you own — not exceptions for expected failures.
- **Singleton / namespace grouping** = a module. `import * as thing`; the file is the boundary.

## Project & module conventions

- **ESM only for new code.** `"type": "module"`; write ESM, period. `require(esm)` is stable, so ESM-only libraries are now acceptable; dual-publish only to support Node < 20.19. Never write new CJS.
- Libraries ship an explicit `exports` map with `types` first, plus ESM + `.d.ts`:
  ```jsonc
  { "type": "module",
    "exports": { ".": { "types": "./dist/index.d.ts", "default": "./dist/index.js" } } }
  ```
- **Write erasable TypeScript** — the subset that Node/Bun/Deno/strip-only transpilers run directly. No `enum`, runtime `namespace`, or parameter properties. Enforce with `erasableSyntaxOnly: true`.
- **`import type` for type-only imports** — without it, Node's type stripping keeps a runtime import of a stripped binding and crashes. `verbatimModuleSyntax` enforces the discipline.
- Relative imports carry extensions: `./helper.ts` in source run by Node/bundler, `./helper.js` in emitted library source. No extensionless (CJS habit; breaks under nodenext/ESM).
- Naming: `PascalCase` types/interfaces/classes/enums-as-const, `camelCase` values/functions, `SCREAMING_SNAKE` only for true module-level constants. No `I`-prefix on interfaces (that's a C# tell). No `utils`/`helpers` grab-bag modules — name by capability.

## tsconfig defaults

Trust the TS 6.0 defaults (`strict`, ESM `module`, current-year `target`, `types: []`, `noUncheckedSideEffectImports`); add the opt-ins below. Never re-enable deprecated options.

```jsonc
{ "compilerOptions": {
    "module": "nodenext",             // or "preserve" + moduleResolution "bundler" for bundled apps
    "types": ["node"],                // TS 6 default is [] — list what you use
    "noEmit": true,                   // bundler or Node type-stripping executes
    "verbatimModuleSyntax": true,
    "erasableSyntaxOnly": true,       // if code runs under Node type stripping
    "noUncheckedIndexedAccess": true  // still opt-in, still worth it
} }
```

Division of labor is settled: **tsc/tsgo type-check (`--noEmit`) and emit `.d.ts`; bundlers/Node execute.** Don't use `tsc` as your production emitter. See [references/ecosystem.md](references/ecosystem.md) for the TS 6→7 migration and tool versions.

## Tooling defaults

- **Run TS in dev:** `node --watch src/main.ts` — no `ts-node`, no build step. `tsx` only for tsconfig-paths or older Node.
- **Typecheck:** `tsc --noEmit` in CI; add a parallel non-blocking `tsgo --noEmit` job to compare diagnostics ahead of the TS 7 swap.
- **Lint:** ESLint 10 flat config (`eslint.config.js`) + typescript-eslint v8 `strictTypeChecked` with `projectService: true`; or Biome 2 for in-process type-aware linting. No `.eslintrc` (hard error on ESLint 10).
- **Test:** Vitest 4 (TS/ESM out of the box). `node:test` for zero-dep libraries; Jest only for React Native/legacy.
- **Build (libraries):** tsup/tsdown/unbuild + `tsc --emitDeclarationOnly`.
- **Package manager:** pnpm (safe default); Bun for greenfield; commit the lockfile via `corepack`/`packageManager`.

```js
// eslint.config.js (flat)
import tseslint from "typescript-eslint";
export default tseslint.config(
  ...tseslint.configs.strictTypeChecked,
  { languageOptions: { parserOptions: { projectService: true } } },
);
```
