---
name: sprint-planning-prep
description: Prepare for sprint planning - check backlog readiness, find carry-over from the current sprint, flag stories missing acceptance criteria or estimates, surface dependencies and risks, and draft a proposed sprint goal. Use a day or two before sprint planning.
argument-hint: "[optional: next sprint path or capacity notes]"
---

# Sprint planning prep

## Steps
1. **Current sprint carry-over.** Run `Get-SprintItems.ps1` (via `ado-work-items`). List items that won't finish: open stories and their remaining task hours.
2. **Next sprint candidates.** Run `Get-SprintItems.ps1 -Timeframe future`. If the next sprint is empty, ask which backlog items are candidates, or run `Find-WorkItems.ps1 -Type 'User Story' -State New -Top 30` for the top of the backlog.
3. **Readiness check** for each candidate story (read with `Get-WorkItem.ps1`):
   - acceptance criteria present and testable,
   - estimated,
   - dependencies known and not blocking,
   - open questions in the discussion answered.
4. **Capacity.** Ask the user for known absences and holidays if they haven't given them. Do not guess capacity. Compare proposed story points against the team's recent velocity only if the user gives it or it's in the data.
5. **Risks:** large stories, stories touching the same area, external dependencies, stories without a QE review.
6. **Draft a sprint goal** (one sentence, outcome-focused) from the highest-priority ready stories.

## Output

```markdown
# Sprint planning prep: <sprint>

## Proposed sprint goal
<one sentence> (draft for the team to change)

## Carry-over from <current sprint>
| ID | Title | State | Remaining | Note |

## Candidates
| ID | Title | Pts | Ready? | Gaps |

## Not ready - fix before planning
| ID | What's missing | Suggested owner |

## Risks and dependencies
- …

## Capacity notes
- <from the user, or "not provided">

## Questions for the team
- …
```

## Rules
- This is preparation, not a decision. The team commits in planning.
- Don't move items between sprints or change estimates. Suggest; don't apply.
