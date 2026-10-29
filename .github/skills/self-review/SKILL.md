---
name: self-review
description: Review your own branch before opening a pull request - diff against the target branch, check acceptance-criteria coverage, tests, security, data protection, performance and team standards using the team review checklist - and list fixes. Use before every PR; also used by the code-reviewer agent.
argument-hint: "[target branch, default main]"
---

# Self-review before a PR

## Steps
1. Collect the change set:
   - `git diff <target>...HEAD --stat` and `git diff <target>...HEAD`
   - `git log <target>..HEAD --oneline`
2. Identify the work item (`#<id>` in branch or commits) and read its acceptance criteria with `ado-work-items`.
3. Run the build and tests (commands in `tests.instructions.md`) and capture the real results.
4. Go through [the review checklist](references/review-checklist.md). Look at the surrounding code before deciding something is a problem.
5. Report findings, then offer to fix them one at a time. Fixing is a separate step the engineer approves.

## Output

```markdown
# Self-review: <branch> -> <target>

**Build:** pass/fail   **Tests:** <passed>/<total> (<failures>)

## Acceptance criteria coverage
| Criterion | Implemented | Tested | Where |

## Must fix
- `file:line` — issue — why — suggested fix

## Should fix
## Nice to have
## Checked and fine
- <short list, so the engineer knows what was covered>
```
