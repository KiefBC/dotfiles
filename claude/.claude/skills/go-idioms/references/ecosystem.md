# Go Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. Current stable: **Go 1.26** (Feb 2026); Go 1.27 expected Aug 2026. Support window: **1.25 + 1.26**. Skill targets **Go 1.24+ semantics** — mention a feature's version only when it is 1.25/1.26-new.

## Version landscape

| Version | Date | Idiom-relevant additions |
|---|---|---|
| 1.21 (2023) | | `min`/`max`/`clear` builtins, `log/slog`, `slices`/`maps`/`cmp` packages, `context.AfterFunc` |
| 1.22 (2024) | | Per-iteration loop variables (kills the `v := v` copy idiom), `range` over int, `math/rand/v2`, `cmp.Or` |
| 1.23 (2024) | | Range-over-func stable, `iter` package (`iter.Seq`, `iter.Seq2`), iterator functions in `slices`/`maps` |
| 1.24 | Feb 2025 | Fully generic type aliases, `testing.B.Loop`, `t.Context()`, json `omitzero` tag, `tool` directives in go.mod, weak pointers, `strings.SplitSeq`/`Lines` |
| 1.25 | Aug 2025 | `sync.WaitGroup.Go`, `testing/synctest` GA, container-aware `GOMAXPROCS`, experimental `encoding/json/v2` (GOEXPERIMENT=jsonv2), Green Tea GC experiment, flight recorder |
| 1.26 | Feb 2026 | `new(expr)` (operand may be an expression giving the initial value), self-referential generic type parameters, Green Tea GC **on by default**, experimental `goroutineleak` pprof profile, `crypto/hpke`, experimental `simd/archsimd` |

## Feature status notes

- **`encoding/json/v2`**: still experimental (GOEXPERIMENT=jsonv2 as of 1.25/1.26). Mention, don't default to it. Do use `omitzero` (1.24) over `omitempty` for `time.Time` and structs.
- **`goroutineleak` pprof profile**: experimental in 1.26; `go.uber.org/goleak` remains the CI tool.
- **Container-aware `GOMAXPROCS`** (1.25): makes `go.uber.org/automaxprocs` redundant in k8s services.
- **`testing/synctest`**: GA in 1.25 — virtual clock for concurrent/timeout tests.
- **`sync.WaitGroup.Go`** (1.25): replaces the Add/defer-Done pattern.
- **`testing.B.Loop` and `t.Context()`**: 1.24.
- **Generics maturity**: fully generic type aliases (1.24), self-referential generic type parameters (1.26). Method-level type parameters remain unsupported.
- **Error-handling syntax**: officially closed June 2025 — go.dev/blog/error-syntax; `?` operator proposal golang/go#71203 declined, as were `check`/`handle` and `try`. Library-level helpers (e.g. `cmp.Or` for coalescing) are the sanctioned direction.

## Project layout guidance

- **Official**: https://go.dev/doc/modules/layout — the only authoritative layout document.
- **NOT official**: https://github.com/golang-standards/project-layout (~54k stars). Russ Cox publicly stated "this is not a Go standard" (golang-standards/project-layout#117). Its `pkg/` convention is not recommended by the Go team.

## Key sources

- go.dev/doc/go1.24, go.dev/doc/go1.25, go.dev/doc/go1.26
- go.dev/blog/go1.25, go.dev/blog/go1.26
- go.dev/blog/error-syntax (June 2025 decision)
- go.dev/blog/range-functions; go.dev/blog/when-generics; go.dev/blog/slog
- go.dev/blog/container-aware-gomaxprocs
- go.dev/doc/modules/layout
- github.com/golang/go#71203 (declined `?` proposal)
- pkg.go.dev/golang.org/x/sync/errgroup
- github.com/uber-go/goleak
- github.com/golang-standards/project-layout#117 ("this is not a standard")
