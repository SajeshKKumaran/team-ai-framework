---
name: regression-risk
description: Analyze a branch, pull request or set of commits to decide what could break and what to retest - changed areas, their callers and consumers, shared code, data and config changes - and produce a prioritized retest list mapped to existing tests and test cases. Use before testing a PR, before a release, or when deciding how much regression testing a change needs.
argument-hint: "[branch or commit range, default <main>...HEAD]"
---

# Regression risk analysis

## Steps
1. Collect the change set: `git diff <target>...HEAD --stat`, the full diff, and `git log <target>..HEAD --oneline`. Read the linked work items with `ado-work-items`.
2. **Classify each change:** new code, modified behavior, refactoring only, configuration, database (schema, data, stored procedures), messaging contracts, UI only, build/pipeline.
3. **Find the blast radius.** For each modified public method, endpoint, stored procedure, message type or shared component, search for its callers and consumers (other projects in the solution, Angular services calling the endpoint, other systems consuming the queue). Shared libraries and base classes have the widest radius.
4. **Rate risk** per area: impact (money/pay, permissions, data integrity, many users) × likelihood (size and complexity of change, test coverage, history of bugs).
5. **Map to existing tests.** Find unit/integration tests that cover each area (search test projects for the changed types). Find Azure DevOps test cases related to the area (`Find-WorkItems.ps1 -Type 'Test Case' -TitleContains '<area>'`).
6. **Recommend** what to run, what's missing, and what to explore manually.

## Output

```markdown
# Regression risk: <branch or PR>

**Overall risk:** High | Medium | Low — <one-line reason>

## Changed areas
| Area | Type of change | Callers/consumers affected | Risk | Why |

## Retest list (priority order)
| # | What to test | How (existing test, test case #id, or new) | Level |

## Gaps
- <risky area with no automated test or test case>

## Exploratory charters
- Explore <area> with <data> to discover <risk>
```

## Rules
- Base every claim on the diff and code search; show the search you did for callers.
- Configuration and database changes are never "low risk" by default; explain the rating.
- Don't run destructive commands or modify code in this skill.
