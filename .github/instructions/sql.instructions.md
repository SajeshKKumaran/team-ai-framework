---
name: sql
description: SQL Server 2022 conventions for scripts, procedures and migrations
applyTo: "**/*.sql"
---

# SQL Server

- Name columns explicitly; no `SELECT *` in application queries, views or procedures.
- Parameterize everything. Dynamic SQL only through `sp_executesql` with parameters, and only when unavoidable.
- Deployment scripts must be idempotent and re-runnable (`IF NOT EXISTS`, `CREATE OR ALTER`).
- Consider indexes and execution plans for queries over large tables; call out likely table scans.
- Wrap multi-statement changes in a transaction with `SET XACT_ABORT ON`.
- Schema changes for EF Core-managed databases go through EF Core migrations, not hand-written scripts. <!-- TEAM-CUSTOMIZE: confirm -->
- Never include real employee or client data in scripts, seed data or examples. Use clearly synthetic values.
- Destructive statements (`DROP`, `TRUNCATE`, `DELETE` without a narrow `WHERE`) must be flagged in the response and never run by the agent.

<!-- TEAM-CUSTOMIZE: naming conventions (tables, procs, indexes), schema ownership, DBA review requirements. -->
