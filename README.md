# Team AI Framework

A forkable template for AI-assisted delivery in a Scrum team: GitHub Copilot role agents, workflow skills, team instructions and an Azure DevOps Server skill with guardrails, plus Microsoft 365 Copilot prompt packs for roles that don't use VS Code yet.

Built for a team of a Project Manager, Product Manager, Solutions Architect, Business Analyst, Quality Engineer and Software Engineers, working on .NET (Framework 4.x and .NET 10), Angular, PHP and SQL Server, with Azure DevOps Server on-prem.

## Quick start

```powershell
# 1. Fork this repo for your team, clone the fork, then install into a product repo
./scripts/Install-Framework.ps1 -TargetRepo C:\src\your-product

# 2. In the product repo: fill in every TEAM-CUSTOMIZE placeholder and
#    .github/skills/ado-work-items/ado.config.json

# 3. Validate
./scripts/Test-Framework.ps1 -Path C:\src\your-product
```

Then open the product repo in VS Code, pick an agent (for example `software-engineer`) and try `/plan-implementation <work item id>`.

Full instructions: [docs/Getting-Started.md](docs/Getting-Started.md).

## What's inside

```
.github/
  copilot-instructions.md        Always-on team context: product, stack, rules, Definition of Done
  instructions/                  Rules by file type: dotnet, angular, php, sql, tests, docs, pipelines
  agents/                        One agent per role + a read-only code reviewer
  skills/                        Workflow skills (run as /name or loaded automatically)
    ado-work-items/              Azure DevOps Server: read, and create/update after preview + approval
    refine-story/  write-feature-brief/  sprint-planning-prep/  sprint-report/  retro-synthesis/
    release-notes/  write-adr/  design-review/  c4-diagram/  plan-implementation/
    explain-legacy-code/  write-unit-tests/  self-review/  pr-description/
    test-design/  regression-risk/  bug-report/
m365-copilot/                    Prompt packs for PM, Product Manager, BA (same output formats)
docs/                            Wiki pages: overview, workflow, playbooks, testing, onboarding, guardrails, extending, rollout
scripts/                         Install-Framework.ps1, Test-Framework.ps1
pipelines/                       PR validation for the framework files
```

## Docs

| Page | For |
|---|---|
| [Overview](docs/Overview.md) | Everyone: principles and how the pieces fit |
| [Getting started](docs/Getting-Started.md) | Everyone: install and verify |
| [Sprint workflow](docs/Sprint-Workflow.md) | Everyone: which AI help at which stage |
| [Role playbooks](docs/Role-Playbooks.md) | Each role |
| [Testing with AI](docs/Testing-With-AI.md) | QE, BA, developers |
| [Developer onboarding](docs/Developer-Onboarding.md) | Developers new to AI-assisted work |
| [Guardrails and best practices](docs/Guardrails-and-Best-Practices.md) | Everyone |
| [Extending the framework](docs/Extending-the-Framework.md) | Framework steward, anyone forking |
| [Rollout and adoption](docs/Rollout-and-Adoption.md) | Team lead, PM |

Version: see [VERSION](VERSION) and [CHANGELOG.md](CHANGELOG.md).
