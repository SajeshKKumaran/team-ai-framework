# Rollout and adoption

[[_TOC_]]

Goal: get the team using the framework in real sprint work as soon as possible, learn fast, and adjust. Success is measured by **adoption and usefulness to our own team**, not by output metrics.

## Week 0: set up (2-3 days)

| Step | Owner | Done when |
|---|---|---|
| Fork the framework; fill in `TEAM-CUSTOMIZE` placeholders | Solutions Architect | `Test-Framework.ps1` passes; placeholders that matter are filled |
| Configure `ado.config.json`; test the read scripts | Solutions Architect | `Find-WorkItems.ps1 -AssignedTo '@Me'` works for two people |
| Install into one product repo via PR | Solutions Architect | Team reviewed and merged the `.github/` changes |
| Share M365 prompt packs with PM, Product Manager, BA | Solutions Architect | Each has tried one prompt |
| 60-minute kickoff: principles, guardrails, live demo of one story end to end | Solutions Architect | Everyone has installed and run the checks in Getting started |
| Pick a framework steward and role champions | Team | Names written in `Extending-the-Framework.md` |

## Sprint 1: pilot three workflows

Keep it small so habits form. Use everything else optionally.

| Workflow | Who | Why first |
|---|---|---|
| `plan-implementation` → implement in small steps → `write-unit-tests` | Software Engineers | Builds the core habit and directly helps the testing bottleneck |
| `test-design` at refinement, with test cases created in Azure DevOps | QE + BA | Moves test design before development |
| `sprint-report` (or the PM prompt pack) | Project Manager | Quick, visible win; exercises the Azure DevOps skill or CSV flow |

During the sprint:
- **Stand-up:** optional 30 seconds, "one thing AI helped with, one thing it got wrong".
- **Pairing:** two or three 45-minute pairing sessions where a more confident person drives and a newer person watches, then swap.
- **Feedback:** keep a running list in a wiki page or Teams channel. <!-- TEAM-CUSTOMIZE: where -->

## Sprint 2: extend

- Add `self-review`, `pr-description` and `regression-risk` to the developer and QE flow.
- BA uses `refine-story` (or the BA pack) for all stories entering refinement.
- Review the guardrails and instructions based on Sprint 1 feedback; fix the top three annoyances.

## Sprint 3 and beyond

- SA: `design-review` for risky stories, `write-adr` for decisions, `c4-diagram` for the wiki.
- PM / Product Manager: `sprint-planning-prep`, `retro-synthesis`, `release-notes`.
- As Copilot seats arrive for PM, Product Manager and BA, move them from the M365 packs to the agents and skills (Option B in Getting started).
- Monthly: framework steward reviews feedback, updates the fork, and contributes improvements upstream.

## Adoption signals

Look at these every sprint, as a team. They describe how the process is going, not how individuals perform, and they're never used for performance evaluation.

| Signal | Source | Healthy direction |
|---|---|---|
| People actively using Copilot during the sprint | Copilot usage metrics (organization admin) | Everyone with a seat, most days |
| Work items created or edited with the skill | Query: tag `ai-assisted`, last 14 days | Rising, then stable |
| Stories with linked test cases before development started | Azure DevOps query (see Testing with AI) | Rising toward most stories |
| Acceptance-criteria questions found in refinement vs. mid-sprint | Retro discussion | More found early |
| Dev-done to test-done time | Sprint data | Falling |
| Team pulse (1-5): "AI saved me time this sprint", "I trust what it produces after review", "I know how to get help" | 3-question survey at the retro | Rising |

## Retro questions during rollout

1. Where did AI save you real time this sprint? Be specific.
2. Where did it waste time or produce something wrong? What would have prevented it?
3. Which instruction, skill or template should we change, add or delete?
4. Is anyone stuck or uncomfortable using it? What would help?

## Risks to watch

| Risk | Mitigation |
|---|---|
| Over-trust: unreviewed AI output gets merged or sent | Guardrails, self-review, human PR approval; talk about misses openly in retros |
| Under-use: people try once, get a bad answer, stop | Pairing, the onboarding path, sharing good prompts |
| Instructions go stale | SA owns them; update when an ADR or standard changes |
| Too much at once | Three workflows in sprint 1; add gradually |
| Tool features change quickly | Steward checks release notes monthly; `Test-Framework.ps1` catches format problems |
