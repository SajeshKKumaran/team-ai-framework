---
name: plan-implementation
description: Turn a user story or bug into a reviewed implementation plan before any code is written - goal, affected files, approach, tests mapped to acceptance criteria, risks and a step order - and optionally create the tasks in Azure DevOps. Use at the start of every story or non-trivial bug fix.
argument-hint: "[work item id]"
---

# Plan the implementation

Planning first is the single most effective habit for AI-assisted development: it catches misunderstandings while they are cheap, and it keeps the agent's changes small and reviewable.

## Steps
1. Read the work item, its acceptance criteria, parent and linked items with `ado-work-items` (`Get-WorkItem.ps1 -Id <id> -IncludeDiscussion`). Read any linked ADR or design note.
2. Explore the code. Search for the entry points, the classes and tables involved, and existing tests around them. Note the target framework of each project you'll touch (.NET Framework 4.x vs .NET 10).
3. Write the plan below. Be concrete: real file paths and type names, not "update the service".
4. **Stop.** Show the plan and wait for the engineer to approve or change it. Do not edit files in this skill.
5. If asked, create the tasks: save them as JSON in `.ai/drafts/tasks-<id>.json` and run `New-WorkItem.ps1 -InputFile ...` (preview, approval, then `-Apply`), each with `parentId` set to the story.

## Plan format

```markdown
# Plan: #<id> <title>

## Goal
<two or three sentences in your own words; call out anything you're unsure you understood>

## Open questions
- <question> (blocking? yes/no)

## Approach
<the design in a few sentences; why this approach over the obvious alternative>

## Changes
| # | File / component | Change | Framework |
|---|---|---|---|

## Tests
| Acceptance criterion / scenario | Test (level: unit/integration/e2e) | File |
|---|---|---|

## Risks and side effects
- <regression risk, performance, data migration, config change, deployment order>

## Out of scope
- <things you noticed but won't change>

## Steps
1. <small, verifiable step> -> verify: <build/test command>
2. …

## Tasks (optional)
| Title | Estimate (h) |
```

## Rules
- Prefer the smallest change that meets the acceptance criteria.
- Flag any need for a new package, schema change, pipeline change or config change as a decision for the engineer.
- If the story is unclear, the plan's first step is getting answers, not coding.
