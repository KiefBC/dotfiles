# Databases Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. Numbers move fast — treat as "as of early July 2026." The gates this backs: EXPLAIN-before-optimizing, replayable migrations, expand→migrate→contract, non-blocking DDL, isolation-default awareness.

## Per-engine table

| Engine | Current | EXPLAIN syntax + how to read | Online / non-blocking DDL | Isolation default |
|---|---|---|---|---|
| **PostgreSQL** | **18** (18.0, 2025-09-25) | `EXPLAIN` = estimate only; `EXPLAIN (ANALYZE, BUFFERS)` runs it + real timings (BUFFERS **auto under ANALYZE in PG18**; write it explicitly pre-18). Read **bottom-up**. First signal: **estimated `rows` vs `actual rows`** — big divergence = stale stats, fix with `ANALYZE`/`default_statistics_target`/`CREATE STATISTICS` *before* indexing. `actual time × loops` = real cost; high-loop Nested Loop = should've been a Hash Join. `Rows Removed by Filter` → partial index candidate; high `Heap Fetches` → `VACUUM`. | `CREATE/DROP/REINDEX INDEX CONCURRENTLY` (no ACCESS EXCLUSIVE lock; not in a txn block; failed build leaves INVALID index to drop+rebuild). `ADD COLUMN` w/ non-volatile default = metadata-only since PG11. Constraints: `ADD ... NOT VALID` then `VALIDATE CONSTRAINT` (weaker lock). Set short `lock_timeout` — a DDL waiting for ACCESS EXCLUSIVE blocks everything queued behind it. | **READ COMMITTED** |
| **MySQL / InnoDB** | **9.7 LTS** (2026-05); **8.4 LTS** (2025-04, supported to 2032) is the conservative prod pick | Formats: `TRADITIONAL` (default), **`FORMAT=TREE`** (readable, iterator-based, closest to PG), `FORMAT=JSON` (most detail + costs). **`EXPLAIN ANALYZE`** (8.0.18+) executes + reports actual time/rows/loops. New JSON output landed 8.3, in 8.4/9.x (old optimizer needs `explain_json_format_version=2`). Red flags: `type: ALL` (full scan), `key: NULL` (no index), `Extra: Using filesort`/`Using temporary`. `Using index` = covering (good). | `ALGORITHM=INSTANT` (metadata-only, size-independent): `ADD COLUMN` any position since 8.0.29, rename column, extend VARCHAR in size class. `INPLACE` rebuilds, allows concurrent DML for many ops. `COPY` = blocking rebuild (avoid on big tables). When native can't stay online, external copy tool: **gh-ost** (triggerless, tails binlog, preferred default 2026) or **pt-online-schema-change** (trigger-based, more portable). | **REPEATABLE READ** |
| **SQLite** | **3.53.x** (3.53.3, 2026-06-26) | `EXPLAIN QUERY PLAN` (EQP) is the human tool: `SCAN table` (full — ok small, bad large) vs `SEARCH table USING INDEX ...`. `USE TEMP B-TREE FOR ORDER BY` = sort not index-supported. Plain `EXPLAIN` dumps VDBE bytecode (rarely wanted). | No concurrent build. Only `ADD COLUMN`, `DROP COLUMN` (3.35+), `RENAME COLUMN` (3.25+). Anything else (reorder, retype, add/drop constraint) = the **official 12-step rebuild**: `PRAGMA foreign_keys=OFF`; BEGIN; create new table; `INSERT INTO new SELECT FROM old`; drop old; rename; recreate indexes/triggers/views; FK check; COMMIT; re-enable FKs. Tools hit "ALTER TABLE not supported" and fall back to copy mode. | SERIALIZABLE (single-writer; not a porting concern) |
| **MongoDB** | **8.2 / 8.3** (8.0 = LTS baseline, 2024-10) | `db.coll.explain("executionStats").find(...)` (or `"allPlansExecution"`). `winningPlan.stage`: **`COLLSCAN` = full scan (bad at scale)** vs `IXSCAN`. Compare `nReturned` to **`totalDocsExamined`** / **`totalKeysExamined`** — ideal `totalDocsExamined ≈ nReturned`. `FETCH` after `IXSCAN` = left the index to read docs (not covered). `executionTimeMillis` = wall clock. | Index builds online since 4.2 (hybrid build). Mostly lazy/on-read or background-script "migrations." Schema validation (`$jsonSchema`) tightened via `validationLevel: moderate` to grandfather old docs. Still apply expand/contract in the *app* (read-both/write-both) when reshaping. | Snapshot for multi-doc txns (default read concern `local`) |

## The isolation-default trap (the most common porting footgun)

Porting SQL between MySQL and Postgres **silently changes the isolation level** (RR ↔ RC).

- **Postgres default = READ COMMITTED.** Its REPEATABLE READ is true **snapshot isolation** (blocks phantoms, allows write skew). Its **SERIALIZABLE = SSI**: tracks read/write dependencies and *aborts* one txn at commit with serialization error **`40001`** — **application code must retry**. Abort rate typically <1% low-contention. Code assuming SERIALIZABLE just "blocks" is wrong.
- **MySQL/InnoDB default = REPEATABLE READ.** MVCC snapshots + **gap/next-key locks** for phantoms (different mechanism than PG). InnoDB quirk: under RR a plain `SELECT` reads the snapshot, but `SELECT ... FOR UPDATE`/`UPDATE` read the *latest* committed row.
- **Both allow write skew at RR** — only SERIALIZABLE fixes it (PG via SSI + retry, MySQL via broader locking). Classic write-skew cases: on-call scheduling, balance checks.
- If code relies on "re-read same row, same value in a txn," PG default RC will **not** give it — request REPEATABLE READ.

| Level | Prevents | Still allows |
|---|---|---|
| READ COMMITTED | dirty read | non-repeatable read, phantom, write skew |
| REPEATABLE READ (snapshot) | dirty + non-repeatable | phantom*, **write skew** |
| SERIALIZABLE | everything (some serial order) | — (PG: aborts w/ `40001`) |

## Why the planner ignores an index you added (all engines)

1. **Predicate/expression doesn't match syntactically** — an index on `lower(email)` is used only if the query literally says `lower(email) = ...`. Postgres has **no theorem prover**; partial-index `WHERE` must be provably implied by the query's `WHERE`.
2. **Low selectivity / small table** — seq scan genuinely cheaper (not a bug).
3. **Type/collation mismatch** — driver binds wrong param type, function on the column, implicit charset conversion (MySQL). Kills index use silently.
4. **Leading-column rule** — B-tree on `(a,b,c)` helps `a`, `a,b`, `a,b,c`, not `b` alone. **PG18 skip scan** relaxes this for low-cardinality leading columns — don't rely on it cross-engine.
5. **Stale statistics** → misestimate → wrong plan. `ANALYZE` (PG/MySQL), `ANALYZE`+`PRAGMA optimize` (SQLite).

Engine index notes: PG covering (`INCLUDE`) index-only scans **need a VACUUM-clean visibility map** — a dirty map forces Heap Fetches and defeats it (#1 "why is my covering index still slow" answer). Types: GIN (JSONB/arrays/FTS), GiST (geometry/ranges), BRIN (huge append-only). MySQL: everything clustered on PK → **keep the PK small**; UUIDv4 PK causes page splits, use UUIDv7/ordered. MongoDB compound field order = **ESR: Equality, Sort, Range**.

## Migration tooling status (2026)

| Tool | Ecosystem | Status | Note |
|---|---|---|---|
| **Alembic** | Python/SQLAlchemy | Standard, active | Autogenerate diffs still need human review |
| **Flyway** | JVM/CLI, 50+ DBs | Maintained, **licensing messy** | Redgate discontinued free **Teams** tier for new customers (2025) → Enterprise. OSS core works. ~12.x |
| **Liquibase** | JVM/CLI | Active, v5.0 | XML/YAML/JSON/SQL changelogs; enterprise-leaning |
| **Atlas** (ariga) | Go, any DB | Active, ascendant | Schema-as-code (declarative) + versioned; lint/CI; Prisma/GORM integration |
| **Prisma Migrate** | Node/TS | Maintained | Declarative schema → SQL; does **not** auto-do expand/contract |
| **golang-migrate** | Go | **Slowing** (Snyk: "Inactive"; v4.19.1, 2025-11) | Fine for existing; for **new** Go prefer **`pressly/goose`** |
| **goose** (pressly) | Go | Active | Recommended default for new Go projects |
| **sqlx migrate** | Rust | Maintained | Built into sqlx; compile-time-checked queries |
| **refinery** | Rust | Maintained (rust-db) | Standalone; PG/MySQL/SQLite/MSSQL |

Don't recommend golang-migrate as default for a *new* Go project — point at goose. Don't assume Flyway Teams is free.

## Deltas vs common (stale) training assumptions

1. **PostgreSQL 18 is current** (Sept 2025), not 15/16 — and it changed a default: **generated columns are VIRTUAL by default** now (was STORED-only in 16/17). Added B-tree skip scan, async I/O, `uuidv7()`.
2. **MySQL default = REPEATABLE READ, Postgres = READ COMMITTED** — models blur this; porting changes semantics.
3. **Postgres SERIALIZABLE (SSI) aborts your txn** (`40001`) — you must retry.
4. **Covering/index-only scan defeated by a dirty visibility map** — "added `INCLUDE`, still slow" is usually VACUUM.
5. **golang-migrate is slowing**; prefer goose. **Flyway free Teams tier discontinued** for new customers (2025).
6. **MySQL `ADD COLUMN` is INSTANT** since 8.0.29 at any position — "adding a column rebuilds the table" is outdated; gh-ost/pt-osc are for what INSTANT/INPLACE can't do.
7. **Mongo multi-doc txns are real** (since 4.0) but bounded: **60s default lifetime, ≤1000 docs, ≤16MB oplog**, replica-set/sharded only, app retries write conflicts — meant to be the exception.
8. **`jsonb_set` rewrites the entire JSONB value** (MVCC new tuple) — the real reason update-heavy document workloads can favor Mongo's field-level `$set`/`$inc` in-place mutations.
9. **SQLite still can't do arbitrary ALTER** — reorder/retype/add-constraint need the 12-step rebuild.

## Defaults for greenfield

- **PostgreSQL 18** for greenfield relational (JSONB + GIN covers ~90% of app workloads).
- **MySQL 8.4 LTS** (not 9.x Innovation) when a shop wants maximum stability.
- **SQLite** for embedded/single-writer/local-first.
- **MongoDB 8.x** only when the data model is genuinely document-shaped (whole-document-by-key access, frequent internal mutation at high concurrency).

## Settled vs contested

**Settled:** EXPLAIN-before-optimizing; expand/contract; rows-est-vs-actual as first diagnostic; leading-column rule; MySQL RR vs PG RC; write skew needs SERIALIZABLE; PG SSI needs app retry; covering index needs clean visibility map; SQLite 12-step ALTER; Mongo txns real but bounded.

**Contested / moving:** declarative (Atlas) vs versioned (Flyway) migrations; gh-ost vs pt-osc (opposite mechanisms, both fine); MySQL 9.x Innovation vs 8.4 LTS; JSONB-vs-Mongo for update-heavy document workloads; how far to lean on PG18 skip scan (new, don't assume portable).

## Key sources

- PostgreSQL 18 release notes: postgresql.org/docs/current/release-18.html; transaction-iso.html; SSI wiki
- MySQL 8.4/9.7: dev.mysql.com/doc/refman/8.4/en/mysql-releases.html; EXPLAIN docs; PlanetScale "State of Online Schema Migrations in MySQL"; gh-ost repo
- SQLite: sqlite.org/lang_altertable.html (12-step); stricttables.html
- MongoDB 8.0/8.2 release notes; reference/limits.html (txn bounds)
- Migration tooling: Bytebase Flyway-vs-Liquibase; atlasgo.io/atlas-vs-others; Snyk golang-migrate advisor; pressly/goose
- Expand/contract: Prisma data guide
