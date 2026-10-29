---
name: refine-story
description: Draft, improve or split user stories with testable Gherkin acceptance criteria, find gaps and ambiguities, and check INVEST and the Definition of Ready. Use for backlog refinement, when a story is vague or too big, or when asked to write acceptance criteria.
argument-hint: "[work item id, or a rough description of the need]"
---

# Refine a user story

## Inputs
- A work item ID: read it with the `ado-work-items` skill (`Get-WorkItem.ps1 -Id <id> -IncludeDiscussion`), plus its parent feature.
- Or rough notes, a feature brief, an email or meeting notes pasted by the user.

## Steps
1. **Understand the need.** Restate in one sentence who needs what and why. If you can't, stop and ask.
2. **List open questions** before drafting. Business rules, calculations, eligibility, permissions, data sources, deadlines and compliance rules must come from the user or a document. Never invent them; write them as questions.
3. **Draft the story** with [the story template](references/story-template.md).
4. **Write acceptance criteria in Gherkin.** Cover:
   - the main success path,
   - each business rule (one scenario per rule; use `Scenario Outline` with an `Examples` table for data variations),
   - validation and error cases,
   - permissions (who can and can't),
   - empty, boundary and large-volume data where relevant.
   Each scenario must be observable from outside the code. Avoid UI details ("click the blue button") unless they are the requirement.
5. **Check quality.** Run the INVEST and Definition of Ready checks in the template and report failures honestly.
6. **Split if too big** (more than ~5 scenarios, more than one user goal, or the team would estimate it above their split threshold). Split by workflow step, business rule, data variation, or simple-first/exceptions-later. Never split by technical layer (UI/API/DB).
7. **Flag hand-offs:** integration, data, security or performance concerns → Solutions Architect; scenarios ready for test design → Quality Engineer.

## Output
1. The story (or stories, if split) in the template format.
2. Open questions, each with who should answer it.
3. INVEST / Definition of Ready result.
4. Suggested next step.

## Writing back to Azure DevOps
Only when the user asks. Use `ado-work-items`:
- Update an existing story: `Update-WorkItem.ps1 -Id <id> -Description "<md>" -AcceptanceCriteria "<md>"` (preview, approval, then `-Apply`).
- Create split stories: save a JSON array to `.ai/drafts/stories-<parentId>.json` and run `New-WorkItem.ps1 -InputFile ...` (preview, approval, then `-Apply`).

## Rules
- Use synthetic examples in scenarios (Test Employee A, $1,000.00). Never real names, IDs or pay data.
- Keep acceptance criteria free of implementation decisions unless the decision is a stated constraint.
