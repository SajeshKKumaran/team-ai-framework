---
name: write-adr
description: Record an architecture decision as an ADR with context, options considered, trade-offs, the decision and its consequences. Use when the team makes or needs to make a significant technical decision (technology choice, integration pattern, data ownership, migration approach, cross-cutting standard).
argument-hint: "[decision topic]"
---

# Write an Architecture Decision Record

## When an ADR is worth writing
The decision is hard to reverse, affects more than one team or component, sets a standard others must follow, or the team will ask "why did we do this?" in six months.

## Steps
1. Find where ADRs live in this repo (look for `docs/adr/`, `docs/architecture/decisions/` or similar). If none exists, propose `docs/adr/` and ask. <!-- TEAM-CUSTOMIZE: fix the location -->
2. Find the next number from existing files (`NNNN-short-title.md`).
3. Gather context from the user and the code: what forces the decision, constraints (on-prem Windows hosting, Azure DevOps Server, SQL Server, .NET Framework/.NET 10 mix, licensing, skills on the team), and what has already been tried.
4. Describe **at least two real options** (including "do nothing" when it's viable) with honest pros and cons. Don't build a straw man.
5. Write the ADR with the template below. Status starts as **Proposed**; only the Solutions Architect or team changes it to Accepted.
6. If the decision changes how code should be written, propose the matching edit to `.github/copilot-instructions.md` or an `.instructions.md` file so every agent follows it.

## Template

```markdown
# NNNN. <Decision title in the imperative: "Use Azure Service Bus for new integrations">

- Status: Proposed | Accepted | Superseded by NNNN | Deprecated
- Date: YYYY-MM-DD
- Deciders: <roles/names>
- Related: #<work item>, ADR NNNN

## Context
What forces this decision: the problem, constraints, quality attributes that matter most.

## Options considered
### Option 1: <name>
<short description>
- Pros: …
- Cons: …
- Cost/effort: …

### Option 2: <name>
…

## Decision
We will <decision>, because <the deciding reasons, tied to the context>.

## Consequences
- Positive: …
- Negative / accepted trade-offs: …
- Follow-up work: <items, with work item ids if created>

## Compliance and operations
Security, data protection, licensing (Black Duck), monitoring, support impact.
```

## Rules
- Be honest about the downsides of the chosen option.
- Don't invent benchmarks, costs or vendor facts; mark estimates as estimates and cite sources.
