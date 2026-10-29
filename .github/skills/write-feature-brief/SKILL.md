---
name: write-feature-brief
description: Turn customer feedback, stakeholder requests, support tickets or a rough idea into an outcome-focused feature brief with problem, evidence, success metrics, scope and risks. Use when shaping a new feature or epic, or when a request arrives as a solution without a clear problem.
argument-hint: "[idea, notes, or feature/epic id]"
---

# Write a feature brief

## Steps
1. Collect the inputs: the user's notes, pasted feedback or tickets, and (if an ID is given) the feature or epic via the `ado-work-items` skill.
2. Find the problem behind the request. If the input is a solution ("add an export button"), ask what the user is trying to achieve and what happens today.
3. Sort every statement into **Evidence** (with source) or **Assumption** (with a way to test it). Never upgrade an assumption to evidence.
4. Define 1-3 measurable outcomes. If no baseline exists, say so and propose how to get one.
5. Draft the brief in the format below. Keep it to about one page.
6. List open questions and who should answer them.

## Format

```markdown
# <Feature name>

## Problem
Who is affected, what they do today, what it costs (time, errors, tickets, risk).

## Evidence
- <fact> — source: <ticket/data/interview/feedback>

## Assumptions to validate
- <assumption> — how we'll test it: <…>

## Outcomes and success measures
| Outcome | Measure | Baseline | Target | How we'll measure |
|---|---|---|---|---|

## Users and scenarios
Primary users, and the 2-4 key scenarios this must support.

## Scope
**In:** … **Out:** … **Later:** …

## Risks and dependencies
Technical, compliance, data, other teams, timing.

## Open questions
| Question | Owner |
|---|---|

## Next step
e.g. "BA to break into stories with the refine-story skill; SA to review integration with <system>."
```

## Rules
- No invented metrics, quotes, customer names or market data.
- Summarize client or employee feedback without identifying details.
- Creating the feature in Azure DevOps is optional and only on request: `New-WorkItem.ps1 -Type Feature ...` through `ado-work-items` (preview, approval, then `-Apply`).
