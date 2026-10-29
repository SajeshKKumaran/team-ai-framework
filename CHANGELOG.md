# Changelog

All notable changes to the framework. Versions follow semantic versioning: minor for new skills or agents, major for changes that break existing forks.

## [0.1.0] - 2026-10-28

First version for the pilot.

### Added
- Team instructions (`copilot-instructions.md`) and path instructions for .NET, Angular, PHP, SQL, tests, docs and pipelines.
- Role agents: product-manager, project-manager, business-analyst, solutions-architect, software-engineer, quality-engineer, code-reviewer.
- Workflow skills: refine-story, write-feature-brief, sprint-planning-prep, sprint-report, retro-synthesis, release-notes, write-adr, design-review, c4-diagram, plan-implementation, explain-legacy-code, write-unit-tests, self-review, pr-description, test-design, regression-risk, bug-report.
- `ado-work-items` skill for Azure DevOps Server with enforced guardrails: preview-by-default writes, type and field allowlists, blocked states, batch limits, `ai-assisted` tagging, local audit log, Windows auth by default.
- M365 Copilot prompt packs for Product Manager, Project Manager and Business Analyst.
- Docs: overview, getting started, sprint workflow, role playbooks, testing with AI, developer onboarding, guardrails, extending, rollout.
- `Install-Framework.ps1`, `Test-Framework.ps1` and a validation pipeline.
