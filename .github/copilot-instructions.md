# Team AI instructions

<!--
  Always-on context. Copilot reads this file on every chat in this repo (VS Code, Visual Studio, Copilot CLI).
  Keep it short and specific: every line costs context on every request.
  Language- and framework-specific rules live in .github/instructions/*.instructions.md.
  Search the repo for "TEAM-CUSTOMIZE" to find every placeholder to fill in.
-->

## About this product

<!-- TEAM-CUSTOMIZE: 3-5 lines. What the system does, who uses it, the business rules that must never break. -->
- Product: _<name and one-line purpose>_
- Users: _<who uses it>_
- Rules that must never break: _<e.g., payroll calculations are auditable and reproducible>_

## Tech stack

- Back end: C# on .NET 10 (new work) and .NET Framework 4.x (legacy). ASP.NET Core on Kestrel, IIS-hosted apps, Windows services.
- Front end: Angular. Check `package.json` for the version before suggesting APIs.
- Legacy modules: PHP 8.
- Data: SQL Server 2022 with EF Core.
- Messaging: Azure Service Bus. MSMQ is legacy; do not add new MSMQ usage without Solutions Architect approval.
- Hosting: on-premises Windows servers.
- ALM: Azure DevOps Server (on-prem): Boards (Agile process), Repos, YAML pipelines, Wiki.
- Gates: SonarQube quality gate, Black Duck open-source license review.

## Repository map

<!-- TEAM-CUSTOMIZE: list the top-level folders and what lives in each. Agents use this to find things. -->
- `src/` _<…>_
- `tests/` _<…>_

## How to work in this repo

1. Understand before changing. Read the relevant code and the work item. For anything bigger than a small, local fix, propose a short plan and wait for approval before editing.
2. Keep changes small and scoped to the work item. Do not refactor or reformat unrelated code.
3. Follow the patterns already used in the surrounding code over generic best practice. If the codebase has two competing patterns, ask which one to follow.
4. Every behavior change comes with tests. Run the build and the relevant tests before saying you are done, and report the actual results, including failures.
5. Ask before adding any NuGet, npm or Composer package. Every new dependency goes through Black Duck license review.
6. Never put secrets, connection strings, tokens or real employee or client data in code, tests, logs, commits or chat output. Use configuration and synthetic data.
7. Do not change pipelines, deployment configuration or database schema unless the task asks for it. Call it out if you think it is needed.
8. Do not suppress warnings, disable SonarQube rules, skip tests or weaken assertions to make something pass. Fix the cause or explain why you can't.
9. When you are not sure, say so and ask. Do not invent APIs, configuration keys, table or column names, or business rules.
10. Explain what you changed and why in plain language, so the person reviewing can learn from it, not just approve it.

## Definition of Done

<!-- TEAM-CUSTOMIZE: keep in sync with the team's working agreement. -->
- Acceptance criteria met and covered by tests.
- Unit tests added or updated; all tests pass locally and in the pipeline.
- SonarQube quality gate passes with no new critical or major issues.
- No new dependency without Black Duck approval.
- PR linked to its work item, described with the `pr-description` skill, and approved by a human reviewer.
- Wiki or ADRs updated when behavior or architecture changes.

## Work items, branches and commits

- Read stories, acceptance criteria and bugs with the `ado-work-items` skill (scripts in `.github/skills/ado-work-items/scripts/`). Changes to Azure DevOps are always previewed first and applied only after the user approves.
- Save drafts (story splits, test case files, plans) under `.ai/drafts/`, which is git-ignored.
- Reference the work item in commit messages and PR titles with `#<id>` so Azure Boards links them.
- Branch names: `<type>/<id>-<short-description>`, for example `feature/1234-export-paystub-pdf`. <!-- TEAM-CUSTOMIZE -->

## Output conventions

- Diagrams in Mermaid. Pages for the Azure DevOps Wiki use `::: mermaid` blocks, not fenced code blocks.
- Architecture decisions use the ADR format from the `write-adr` skill.
- Be concise. Show exact file paths, commands and results.
