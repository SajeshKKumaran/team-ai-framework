---
name: pr-description
description: Write a clear pull request title and description from the branch diff and the linked work item - what changed and why, how it was tested, risks, deployment notes and an AI-assistance note. Use when opening or updating a pull request in Azure Repos.
argument-hint: "[target branch, default main]"
---

# Pull request description

## Steps
1. Gather: `git diff <target>...HEAD --stat`, `git diff <target>...HEAD`, `git log <target>..HEAD --oneline`.
2. Read the linked work item (`#<id>` from the branch or commits) with `ado-work-items`.
3. Write for a reviewer who hasn't seen the story: lead with the why.
4. Testing section: only list tests that were actually run, with results. If you don't know, ask.
5. Output the title and description as Markdown for the user to paste into Azure Repos. Don't create or update the PR yourself.

## Format

```markdown
Title: #<id> <imperative summary, max ~70 chars>

## Why
<the problem or story in 1-3 sentences> (#<id>)

## What changed
- <change, grouped by component, in plain language>

## How it was tested
- [x] Unit tests: <what> — <n> passed
- [x] Manual: <scenario and result>
- [ ] Not tested: <what and why>

## Acceptance criteria
| Criterion | Covered by |
|---|---|

## Risks and review focus
- <where reviewers should look hardest and why>

## Deployment notes
- Config: <new settings per environment, or "none">
- Database: <migration name, or "none">
- Order/dependencies: <…>

## AI assistance
<e.g. "Plan, implementation and unit tests drafted with GitHub Copilot (software-engineer agent); reviewed and tested by the author.">
```

## Rules
- No secrets, server names, personal data or client names in the description.
- Be honest about what wasn't tested.
