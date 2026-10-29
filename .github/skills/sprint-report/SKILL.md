---
name: sprint-report
description: Produce a sprint status report from live Azure DevOps data - progress against the sprint goal, done and in-progress work, blockers, risks and asks - for the team (detailed) or stakeholders (short). Use for mid-sprint health checks, end-of-sprint summaries or stakeholder updates.
argument-hint: "[team | stakeholder] [optional: sprint goal]"
---

# Sprint report

## Steps
1. Run `Get-SprintItems.ps1` (or `-Timeframe past` for the sprint that just ended) via `ado-work-items`.
2. Ask for the sprint goal if the user hasn't given it; it isn't stored in work items.
3. Read the details of blocked and flagged items with `Get-WorkItem.ps1 -Id <ids> -IncludeDiscussion` to explain *why* they are blocked.
4. Choose the audience format below. Default to **team** if unclear.
5. State the data source and snapshot time at the bottom.

## Team format

```markdown
# <Sprint> status - <date>

**Sprint goal:** <goal> — **On track / At risk / Off track**, because <one line>.

## Progress
- Stories: <done>/<total> done (<points done>/<points total> pts)
- Working days left: <n>

## Done since last update
- #id Title

## In progress
| ID | Title | Owner | Remaining | Note |

## Blocked or at risk
| ID | Title | Why | What's needed | From whom |

## Data hygiene
- <items with no AC, no estimate, no remaining work, no update for 3+ days>

## Asks
- <specific request, owner, by when>
```

## Stakeholder format
Five to eight lines: goal status with one-line reason, what was delivered (in business language, no IDs unless asked), top risk and its mitigation, any decision or help needed. No internal jargon.

## Rules
- Report facts from the data. Mark interpretation as interpretation.
- Describe problems in terms of work and process, never individual performance.
- Don't forecast completion dates as commitments; show the assumption behind any projection.
