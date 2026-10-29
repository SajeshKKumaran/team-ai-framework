# Role playbooks

[[_TOC_]]

One page per role: your agent, your skills, a typical week, and what to watch out for.

## Product Manager

**Agent:** `product-manager` · **Skills:** `write-feature-brief`, `release-notes`, `ado-work-items` · **Until you have a Copilot seat:** [PdM prompt pack](../m365-copilot/product-manager.md)

| When | Use it for |
|---|---|
| New request or idea arrives | Feature brief that separates evidence from assumptions and defines measurable outcomes |
| Feedback piles up | Theme analysis of tickets and feedback exports |
| Roadmap discussions | Side-by-side comparison of candidates with explicit trade-offs |
| End of sprint/release | Release notes in user language; stakeholder update |

**Watch out for:** invented numbers and confident-sounding market claims. Every figure in a brief must trace to a source you can name.

## Project Manager

**Agent:** `project-manager` · **Skills:** `sprint-planning-prep`, `sprint-report`, `retro-synthesis`, `ado-work-items` · **Until you have a Copilot seat:** [PM prompt pack](../m365-copilot/project-manager.md)

| When | Use it for |
|---|---|
| Daily, before stand-up | Sprint snapshot "needs attention" list (blocked, stale, unestimated) |
| 1-2 days before planning | Readiness check, carry-over, risks, draft sprint goal |
| Mid-sprint and end of sprint | Team and stakeholder status reports from live data |
| After the retro | Themes, last retro's actions, up to three owned actions |
| After any meeting | Decisions, actions and open questions from the recap |

**Watch out for:** reports that read as judgments of people. Keep the focus on work and process; the agent is instructed to, but you're the final check.

## Business Analyst

**Agent:** `business-analyst` · **Skills:** `refine-story`, `c4-diagram`, `ado-work-items` · **Until you have a Copilot seat:** [BA prompt pack](../m365-copilot/business-analyst.md)

| When | Use it for |
|---|---|
| Turning a feature into stories | Story splits by user value, each with Gherkin acceptance criteria |
| Before refinement | Gap and ambiguity check; open questions with owners; INVEST and Definition of Ready check |
| Complex rules | Scenario Outlines with example tables; decision tables; Mermaid process flows |
| After refinement | Updating stories in Azure DevOps (preview, approve, apply) |

**Watch out for:** plausible-sounding business rules. The AI must never be the source of a payroll, eligibility or compliance rule; those come from people and documents.

## Solutions Architect

**Agent:** `solutions-architect` · **Skills:** `design-review`, `write-adr`, `c4-diagram`, `explain-legacy-code`, `ado-work-items`

| When | Use it for |
|---|---|
| Risky stories in refinement | Design review against principles and NFRs, grounded in the actual code |
| A decision is needed | Options with honest trade-offs, then an ADR |
| Documentation | C4 context/container diagrams from the codebase, ready for the wiki |
| Modernization | Legacy area analysis: .NET Framework → .NET 10 blockers, MSMQ → Service Bus |
| Standards | When an ADR changes how code is written, update the instructions files so every agent follows it |

**Your extra responsibility:** you are the natural owner of `.github/copilot-instructions.md` and the `.instructions.md` files. Treat them like code: reviewed, versioned, and kept short.

## Quality Engineer

**Agent:** `quality-engineer` · **Skills:** `test-design`, `regression-risk`, `bug-report`, `write-unit-tests`, `ado-work-items`

| When | Use it for |
|---|---|
| Story enters refinement | Test cases from acceptance criteria, created in Azure DevOps and linked to the story, plus testability questions for the BA |
| PR opened | Regression risk and a prioritized retest list |
| Defect found | Reproducible, masked bug report; duplicate check |
| Automation | Scaffolding API/UI tests for cases tagged `automate-api`/`automate-ui` |
| Unit-test gaps | Helping developers cover acceptance criteria at the unit level |

**See also:** [Testing with AI](Testing-With-AI.md) for the full approach to removing the testing bottleneck.

## Software Engineers

**Agents:** `software-engineer`, `code-reviewer` · **Skills:** `plan-implementation`, `explain-legacy-code`, `write-unit-tests`, `self-review`, `pr-description`, `regression-risk`, `ado-work-items`

| When | Use it for |
|---|---|
| Starting a story | Read the story, then a plan you approve before any code changes |
| Unfamiliar or legacy code | Plain-language explanation with risks and a safe way in |
| Implementing | One small step at a time, build and test after each |
| Tests | Unit tests mapped to acceptance criteria; characterization tests before refactoring legacy code |
| Before a PR | Self-review against the team checklist; PR description with AC coverage |
| Reviewing a colleague's PR | `code-reviewer` agent to prepare; you write the review |

**New to AI-assisted development?** Start with the [developer onboarding path](Developer-Onboarding.md).

**Watch out for:** large, sweeping diffs; invented APIs and config keys; tests that pass because they assert nothing. Read every line before you commit it.
