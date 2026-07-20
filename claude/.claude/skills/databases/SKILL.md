---
name: databases
description: Use when designing a schema, writing or optimizing a query, adding an index, changing a table, choosing or migrating a datastore, or investigating a slow query — across PostgreSQL, MySQL, SQLite, or MongoDB.
---

# Databases

## Overview

Query analysis instinct is reliable; the risk is schema changes that aren't captured as replayable, non-blocking migrations. A `CREATE INDEX` typed into a live prod DB is where downtime incidents come from — the same reflex that's harmless on SQLite locks a table on Postgres/MySQL.

<HARD-GATE>
1. **Optimize from the plan, not a guess.** Before adding an index or rewriting a query, run `EXPLAIN`/`EXPLAIN ANALYZE` (`EXPLAIN QUERY PLAN` on SQLite) and read it. The claim "this is faster" must quote before/after plans, not just times.
2. **Every schema change is a replayable migration**, committed as a file — never a bare mutation of a live database. A change you can't re-run on another environment or roll back isn't done.
3. **No destructive migration** (DROP column/table, type narrowing, NOT NULL on existing data) without a stated backup + rollback plan.
4. **On engines where DDL locks** (Postgres, MySQL), build the non-blocking way: `CREATE INDEX CONCURRENTLY`, `ADD CONSTRAINT ... NOT VALID` then `VALIDATE`, online DDL / gh-ost. SQLite has no concurrent build — but the migration-file rule still holds.
</HARD-GATE>

## Migration safety: expand → migrate → contract

Never change a column's shape in one step while code depends on the old shape. Three deploys:
1. **Expand** — add the new column/table (nullable, no constraint); deploy code that writes both.
2. **Migrate** — backfill in batches; switch reads to the new shape.
3. **Contract** — drop the old column once nothing reads it. The destructive step is last, isolated, and reversible up to that point.

A migration that both adds the new and drops the old in one transaction is the anti-pattern — it has no safe rollback and no window to catch a bad backfill.

## Modeling & indexing

- Normalize until it hurts; denormalize only with a measured read pattern that needs it.
- Indexes come from query plans, not vibes. Prefer covering (`INCLUDE`) and partial (`WHERE`) indexes for hot queries. Every index has a write-cost and size-cost — name it.
- Know which anomaly your isolation level prevents. Defaults differ and bite on porting: **Postgres = READ COMMITTED, MySQL/InnoDB = REPEATABLE READ.** SERIALIZABLE/locking code must retry on serialization-failure/deadlock — it is not automatic.

## Relational vs document

Default to relational (Postgres) with JSONB for the genuinely schemaless columns. Reach for a document store only when the access pattern is overwhelmingly whole-document by key and you accept weaker cross-document transactions. "We might need flexibility later" is not evidence.

## Red flags

| Flag | Reality |
|---|---|
| `SELECT *` in application code | Name columns; `*` breaks on schema change and reads dead columns |
| Adding an index "to see if it helps" | Read the plan first; confirm the planner uses it after |
| N+1 (query in a loop) | One query with a join / `IN`, or a batch load |
| "We'll add the index later" | Later is the incident. Add it with the query that needs it |
| DDL typed into prod directly | Write it as a migration; run non-blocking |
| Destructive migration, no backup stated | State backup + rollback before running |

Per-engine EXPLAIN syntax, migration tooling status, isolation details, version facts: see [references/ecosystem.md](references/ecosystem.md).
