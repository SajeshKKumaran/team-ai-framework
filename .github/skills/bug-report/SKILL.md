---
name: bug-report
description: Turn rough observations, error messages, logs or screenshots into a reproducible Azure DevOps bug with clear steps, expected vs actual results, environment, severity rationale and masked data, and optionally a likely root-cause area from the code. Use when a defect is found in testing, a demo or production support.
argument-hint: "[notes, error text, or log file]"
---

# Write a bug report

## Steps
1. Read what the user gives you (notes, pasted errors, log excerpts, the story being tested via `ado-work-items`).
2. **Mask sensitive data first.** Replace names, employee IDs, SSNs, bank details, pay amounts tied to a real person, emails and tokens with placeholders (`<employee A>`, `<ssn>`). Tell the user what you masked.
3. Ask for missing essentials: environment, build/version, user role, exact steps, frequency (always / sometimes / once), and whether it worked before.
4. Write the bug in the format below. Steps must start from a known state and be reproducible by someone else.
5. Suggest **severity** (impact) and **priority** (urgency) with a one-line rationale each, using the team's scale. <!-- TEAM-CUSTOMIZE: severity definitions -->
6. Optional: search the code for the error message, endpoint or component to suggest a likely area, clearly labelled as a hypothesis.
7. Check for duplicates: `Find-WorkItems.ps1 -Type Bug -TitleContains '<key words>'`.
8. On request, create it: `New-WorkItem.ps1 -Type Bug -Title '...' -Fields @{ 'Microsoft.VSTS.TCM.ReproSteps' = '<markdown>'; 'Microsoft.VSTS.TCM.SystemInfo' = '<markdown>'; 'Microsoft.VSTS.Common.Severity' = '2 - High' } -ParentId <story>` (preview, approval, then `-Apply`).

## Format

```markdown
Title: <Component> - <what goes wrong> when <condition>

## Steps to reproduce
1. Sign in as <role> (<synthetic test user>)
2. …

## Expected result
## Actual result
<include exact error text, masked>

## Environment
Environment: <DEV/QA/UAT/PROD>, build: <…>, browser/OS: <…>, user role: <…>

## Frequency
Always | Intermittent (<n> of <m> tries) | Once

## Impact
Who is affected, how many, workaround available?

## Evidence
Screenshots, log excerpts (masked), correlation ID, time of occurrence.

## Notes
Related story #<id>; possible area (hypothesis): <…>
```

## Rules
- Never paste unmasked personal, pay or client data into a bug, even in production incidents.
- Describe behavior, not blame.
