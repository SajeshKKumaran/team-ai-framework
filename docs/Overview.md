# AI-assisted delivery framework: overview

[[_TOC_]]

## Purpose

This framework is the team standard for using AI across the whole Scrum lifecycle, not just for writing code. It gives every role (Product Manager, Project Manager, Business Analyst, Solutions Architect, Quality Engineer and Software Engineers) an AI partner that knows our stack, our process and our rules, and that produces artifacts in the same shape regardless of who or what created them.

It is a **template**. Each team forks it and adapts it to how they work.

## Principles

1. **People own decisions and outcomes; AI drafts.** Everything AI produces is reviewed by the person who uses it. Nobody ships, sends or approves something they haven't read.
2. **Plan before code, small steps, verify each step.** The biggest quality gains come from making the AI show its plan first and keeping changes small enough to review.
3. **Shared context lives in the repo.** Our stack, standards, Definition of Done and guardrails are written down once in `.github/`, so every agent and every person gets the same rules.
4. **Same artifacts, any tool.** Stories, test cases, plans and reports follow the same templates whether they come from VS Code, the Copilot CLI or M365 Copilot. This is what makes hand-offs between roles work.
5. **Shift testing left.** Test cases are designed from acceptance criteria during refinement, not after development.
6. **Preview before writing to shared systems.** Nothing is created or changed in Azure DevOps without a preview and an explicit yes.
7. **Start small, learn, adapt.** We adopt a few workflows at a time and change the framework based on what we learn in retros.

## How the roles connect

Each role's output becomes the next role's input. The AI is most useful when those hand-off artifacts are clear and structured.

::: mermaid
flowchart LR
  PdM["Product Manager<br/>feature brief"] --> BA["Business Analyst<br/>stories + Gherkin AC"]
  BA --> SA["Solutions Architect<br/>design review / ADR"]
  BA --> QE1["Quality Engineer<br/>test cases from AC"]
  SA --> SE["Software Engineers<br/>plan, code, unit tests"]
  QE1 --> SE
  SE --> REV["Self-review + code review<br/>PR description"]
  REV --> QE2["Quality Engineer<br/>regression risk, test run, bugs"]
  QE2 --> PM["Project Manager<br/>sprint report, release notes, retro"]
  PM -.-> PdM
:::

## What's in the box

| Layer | Where | What it does | Used by |
|---|---|---|---|
| Team instructions | `.github/copilot-instructions.md` | Always-on context: product, stack, working rules, Definition of Done | Every Copilot chat in the repo |
| Path instructions | `.github/instructions/*.instructions.md` | Rules for C#/.NET, Angular, PHP, SQL, tests, docs, pipelines; applied automatically by file type | Every Copilot chat that touches those files |
| Role agents | `.github/agents/*.agent.md` | One agent per role with its responsibilities, skills and limits; plus a read-only code reviewer | Selected in the agent picker (VS Code) or with `/agent` (CLI) |
| Workflow skills | `.github/skills/<name>/SKILL.md` | Repeatable workflows with templates (refine a story, design tests, plan a change…). Loaded automatically when relevant, or run as a `/` slash command | All roles |
| Azure DevOps skill | `.github/skills/ado-work-items/` | Reads work items, sprints and queries; creates and updates them only after preview and approval | All roles |
| M365 prompt packs | `m365-copilot/` | Same workflows and formats for roles without VS Code yet | PM, Product Manager, BA |
| Docs | `docs/` | This wiki: how to install, use, extend and roll out the framework | Everyone |
| Tooling | `scripts/`, `pipelines/` | Install into a repo, validate the framework files | Framework steward |

### Skills by role

| Role | Agent | Skills |
|---|---|---|
| Product Manager | `product-manager` | `write-feature-brief`, `release-notes` |
| Project Manager | `project-manager` | `sprint-planning-prep`, `sprint-report`, `retro-synthesis` |
| Business Analyst | `business-analyst` | `refine-story`, `c4-diagram` |
| Solutions Architect | `solutions-architect` | `design-review`, `write-adr`, `c4-diagram`, `explain-legacy-code` |
| Software Engineer | `software-engineer` | `plan-implementation`, `explain-legacy-code`, `write-unit-tests`, `self-review`, `pr-description`, `regression-risk` |
| Quality Engineer | `quality-engineer` | `test-design`, `regression-risk`, `bug-report`, `write-unit-tests` |
| Reviewer (anyone) | `code-reviewer` | `self-review` checklist |
| Everyone | — | `ado-work-items` |

## Where it runs

| Surface | Instructions | Agents | Skills | Notes |
|---|---|---|---|---|
| VS Code (GitHub Copilot) | Yes | Yes | Yes (also as `/` commands) | Primary surface |
| GitHub Copilot CLI | Yes | Yes (`/agent`) | Yes | Good for the Azure DevOps scripts and for non-coding roles |
| Visual Studio 2026 | Yes | Check your version | Yes | Many .NET Framework solutions live here |
| M365 Copilot | No (uses prompt packs) | Optional (tenant agent builder) | No | Bridge for PM, Product Manager and BA until they have Copilot seats |

We deliberately use **skills** rather than VS Code prompt files for workflows: skills work in VS Code, the Copilot CLI and Visual Studio, while prompt files only run in one VS Code mode.

## Next

- [Getting started](Getting-Started.md)
- [Sprint workflow](Sprint-Workflow.md)
- [Role playbooks](Role-Playbooks.md)
