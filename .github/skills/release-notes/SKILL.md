---
name: release-notes
description: Draft release notes from completed stories and bugs in Azure DevOps, in business language for users and stakeholders, with an optional technical section for support and operations. Use at the end of a sprint or before a release.
argument-hint: "[sprint, release tag, or list of work item ids] [audience]"
---

# Release notes

## Steps
1. Get the completed work:
   - for a sprint: `Get-SprintItems.ps1 -Timeframe past` (or current), keeping Resolved/Closed stories and bugs;
   - or `Find-WorkItems.ps1` with the query the user gives;
   - or the IDs the user lists.
2. Read each item with `Get-WorkItem.ps1` to understand the user-facing change.
3. Group by user benefit: **New**, **Improved**, **Fixed**. Skip internal-only items (refactoring, test work, pipeline changes) in the user section; list them in the technical section.
4. Write each line from the user's point of view: what they can now do or what no longer goes wrong. One or two sentences, no jargon.
5. Ask about anything you can't describe confidently from the work item.

## Output

```markdown
# Release notes - <release or sprint> (<date>)

## New
- **<Short benefit headline>.** <What users can now do and where.>

## Improved
- …

## Fixed
- …

## Known issues
- …

---
## Technical notes (support and operations)
| ID | Type | Title | Notes (config changes, migrations, feature flags) |
```

## Rules
- Never include client names, employee data or internal system names in the user section.
- Don't claim a fix or feature shipped unless its work item is Resolved or Closed; list uncertain items for the user to confirm.
