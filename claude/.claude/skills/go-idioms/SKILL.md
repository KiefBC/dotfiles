---
name: go-idioms
description: Use when writing or reviewing Go code — new packages, refactors, PR review, or porting code from other languages — especially when choosing error handling, interfaces, concurrency patterns, project layout, test structure, logging, or deciding between generics and interfaces.
---

# Go Idioms

## Overview

Makes Go code idiomatic modern Go (target Go 1.24+ semantics; current stable 1.26). Encodes settled 2026 consensus — what to write, what to reject, and where the community has genuinely closed debate.

Version-sensitive facts (1.24/1.25/1.26 feature availability, layout links): see [references/ecosystem.md](references/ecosystem.md).

## Core Idioms

### 1. Error wrapping: `%w`, `errors.Is`/`As` — and the syntax debate is CLOSED

The Go team officially stopped pursuing error-handling syntax (June 2025, go.dev/blog/error-syntax; `?` proposal golang/go#71203 declined). `if err != nil` IS the idiom. Never suggest waiting for new syntax.

```go
// WRONG
return fmt.Errorf("open config: %v", err)       // %v breaks the chain
if err == sql.ErrNoRows { ... }                  // misses wrapped errors
if e, ok := err.(*MyErr); ok { ... }             // type assertion misses wrapping

// RIGHT
return fmt.Errorf("open config %q: %w", path, err)
if errors.Is(err, sql.ErrNoRows) { ... }
var myErr *MyErr
if errors.As(err, &myErr) { ... }
```

Messages: lowercase, no trailing punctuation, add context (operation, key values) — not "failed to" stutter at every layer. `%w` makes the inner error part of your API; if the cause is an implementation detail, translate to a sentinel or use `%v`. Sentinels: exported `var ErrNotFound = errors.New(...)`. Multi-error: `errors.Join`.

### 2. Small interfaces, defined at the consumer

Accept interfaces, return structs. The package that *uses* the dependency declares the 1–2 method interface it needs; producers export concrete types. No interface with one implementation "for testability" until a second consumer or a test needs it.

```go
// WRONG: producer-side god interface
package store
type Store interface { Get(...); Put(...); Delete(...); List(...); Watch(...) }

// RIGHT: consumer defines what it needs
package billing
type invoiceGetter interface { GetInvoice(ctx context.Context, id string) (Invoice, error) }
func NewService(g invoiceGetter) *Service { ... }
```

Exception (judgment, not dogma): returning an interface is fine for genuinely polymorphic factories (`error`, `io.Reader` wrappers).

### 3. Useful zero values

Design types so `var x T` works (`bytes.Buffer`, `sync.Mutex`, `http.Client` style). No mandatory `Init()`. If the zero value can't be valid, provide `NewT()` and use unexported fields so the constructor can't be skipped.

```go
// WRONG
var b Buffer
b.Init()          // forgettable, panics later if skipped

// RIGHT
var b bytes.Buffer
b.WriteString("ready immediately")
```

### 4. Table tests with t.Run

```go
// WRONG
func TestAdd(t *testing.T) { if Add(1, 2) != 3 { t.Fail() } }  // no message, no cases

// RIGHT
tests := []struct{ name string; a, b, want int }{{"pos", 1, 2, 3}}
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        t.Parallel()  // 1.22+ loop semantics: no tt := tt copy needed
        if got := Add(tt.a, tt.b); got != tt.want {
            t.Errorf("Add(%d, %d) = %d, want %d", tt.a, tt.b, got, tt.want)
        }
    })
}
```

Never emit pre-1.22 `v := v` loop-variable copies.

### 5. slog for logging

`log/slog` is the assumed default; zap/zerolog only for measured hot paths, logrus is legacy.

```go
// WRONG
log.Printf("user %s failed login: %v", id, err)

// RIGHT
slog.ErrorContext(ctx, "login failed", "user_id", id, "err", err)
```

JSON handler in prod, text in dev; snake_case keys, consistent names (`trace_id`, `latency_ms`); use `*Context` variants; child loggers via `logger.With("component", "billing")`; libraries accept `*slog.Logger`, never construct their own global. Never log secrets.

### 6. errgroup.WithContext + SetLimit for parallel subtasks

```go
// WRONG: unbounded fan-out, manual WaitGroup + error channel
var wg sync.WaitGroup
errs := make(chan error, len(items))
for _, it := range items { wg.Add(1); go func() { defer wg.Done(); ... }() }

// RIGHT
g, ctx := errgroup.WithContext(ctx)
g.SetLimit(8)  // set BEFORE any Go; must not change while goroutines run
for _, it := range items {
    g.Go(func() error { return process(ctx, it) })
}
if err := g.Wait(); err != nil { return err }
```

First error cancels ctx. When you don't need errors: `wg.Go(f)` (1.25) replaces Add/defer-Done.

### 7. Context as first parameter

```go
// WRONG
type Server struct{ ctx context.Context }        // don't store ctx in structs
func (s *Server) Fetch(id string) error { ... }

// RIGHT
func (s *Server) Fetch(ctx context.Context, id string) error { ... }
```

Named `ctx`, always first. Never pass nil — use `context.TODO()`. Values only for request-scoped cross-cutting data. `context.WithoutCancel` to detach background work. Every `go func()` needs a one-sentence answer to "what event makes this goroutine exit?"

### 8. Iterators: iter.Seq where the caller only ranges

```go
// WRONG: channel generator (leaks goroutines, slow) or []T when caller only ranges
func (s *Store) AllKeys() <-chan string { ch := make(chan string); go func() { ... }(); return ch }

// RIGHT
func (s *Store) Keys() iter.Seq[string] {
    return func(yield func(string) bool) {
        for _, k := range s.keys {
            if !yield(k) { return }  // MUST return when yield returns false
        }
    }
}
```

Name methods `All()`/`Keys()`/`Values()`; `iter.Seq2[K,V]` for pairs; consume with `slices.Collect`, `maps.Collect`, `slices.Sorted`. `strings.SplitSeq`/`Lines` over `strings.Split` when only iterating. Don't chain 3+ iterator adapters LINQ-style — a plain loop is preferred.

### 9. Generics where they earn it

Use: to eliminate a type assertion/`any` with a narrow constraint (`comparable`, `cmp.Ordered`, one-method interface); data structures (stack, set, cache); deduplicating identical code differing only in type. Avoid: when all you do is call a method (use an interface); paragraph-length constraints; deduping two five-line functions.

```go
// WRONG: generic where an interface suffices
func Print[T fmt.Stringer](v T) { fmt.Println(v.String()) }

// RIGHT
func Print(v fmt.Stringer) { fmt.Println(v.String()) }
```

`Result[T]`/`Option[T]`: only at single-value boundaries (channels, futures). `(T, error)` remains the norm. `any` in application code is a smell — a type parameter or interface almost always exists.

### 10. Functional options: public libraries only

Accepted for public libraries with many optional evolving parameters (grpc, zap style), but overused. Internal code with few knobs: plain config struct or parameters.

```go
// WRONG (internal code, two knobs)
srv := NewServer(WithPort(8080), WithTimeout(5*time.Second))

// RIGHT
srv := NewServer(Config{Port: 8080, Timeout: 5 * time.Second})  // defaults via cmp.Or
```

## Anti-Patterns

| Anti-pattern | Why wrong | Instead |
|---|---|---|
| `panic` for control flow / expected failures | Exceptions-thinking; panics are for programmer bugs and unrecoverable states | Return `error`; `recover` only at goroutine/handler boundaries |
| Java-style interface-per-struct (`FooImpl` implements `Foo`) | Interface with one implementation, defined by producer | Concrete types; consumer defines interfaces when needed (§2) |
| `pkg/` directory | Noise; Go team doesn't recommend it | Packages at root or under `internal/` |
| Ignoring errors with `_` | Silently swallows failures | Handle, wrap with `%w`, or comment why discard is safe (`_ = f.Close() // best-effort`) |
| `utils`/`helpers`/`models` package | Named for what it is, not what it provides | Name by capability: `ratelimit`, not `ratelimitutil` |
| Channel-based generators for iteration | Goroutine leaks, slow | `iter.Seq` (§8) |

## Project Layout

Official guidance is **go.dev/doc/modules/layout**. The golang-standards/project-layout repo is explicitly NOT official (Russ Cox: "this is not a Go standard") — treat it as an anti-pattern source, especially its `pkg/`.

- Start with `go.mod` + `main.go`. Add structure when forced, not before.
- Multiple binaries: `cmd/<binary-name>/main.go`. One binary: `main.go` at root.
- `internal/` is compiler-enforced — default home for non-exported packages; keeps the public API deliberate.
- Avoid `pkg/`, `src/`, empty deep hierarchies.

```text
WRONG: /src/pkg/utils/helpers.go, /pkg/models/user.go
RIGHT: go.mod, main.go                                        (small tool)
RIGHT: cmd/api/main.go, cmd/worker/main.go, internal/billing/ (multi-binary)
```

## Testing Conventions

- Table tests + `t.Run` subtests (§4) are the core idiom.
- **testify: no consensus — match the existing codebase.** For new code, stdlib + `google/go-cmp` (`cmp.Diff`) is the safe recommendation; testify `require` acceptable. Avoid testify `suite`; avoid Ginkgo/Gomega unless the team already does BDD.
- Prefer modern helpers: `t.Cleanup`, `t.TempDir`, `t.Setenv`, `t.Context()`, `for b.Loop()` (not `for i := 0; i < b.N; i++`).
- **goleak** (go.uber.org/goleak): `goleak.VerifyTestMain(m)` in `TestMain` for packages spawning goroutines (required with `t.Parallel`); `defer goleak.VerifyNone(t)` per-test otherwise; document any `IgnoreCurrent()`.
- **Native fuzzing** for parsers/decoders/anything consuming untrusted bytes: `func FuzzX(f *testing.F)`, `f.Add` seeds, `go test -fuzz=.`, corpus in `testdata/fuzz/`.
- Concurrency/timeout tests: `testing/synctest` virtual clock — never `time.Sleep` in tests. See [references/ecosystem.md](references/ecosystem.md) for version availability.

## Concurrency Defaults

- `errgroup.WithContext` + `SetLimit` for parallel work with errors (§6); `sync.WaitGroup.Go(f)` when errors aren't needed.
- `testing/synctest` for testing time-dependent concurrent code.
- Race detector in CI: `go test -race` is non-negotiable for any package with goroutines.
- Container-aware `GOMAXPROCS` is built in (1.25): delete `go.uber.org/automaxprocs` from k8s services.
- goleak in CI for leak detection (see Testing above).

## Baseline Modernisms

`min`/`max`/`clear` builtins; `cmp.Or` for defaults; `slices`/`maps` packages (`Contains`, `SortFunc`, `Keys`/`Values` iterators, `Collect`); `math/rand/v2` (no seeding); `omitzero` over `omitempty` for `time.Time` and structs; `go.mod` `tool` directive over the `tools.go` hack. gofmt non-negotiable; `staticcheck` + `go vet` assumed; `golangci-lint` the meta-runner norm. Feature-to-version mapping: [references/ecosystem.md](references/ecosystem.md).
