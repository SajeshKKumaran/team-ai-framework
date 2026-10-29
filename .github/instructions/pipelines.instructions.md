---
name: pipelines
description: Azure DevOps Server YAML pipeline conventions
applyTo: "**/azure-pipelines*.yml,**/pipelines/**/*.yml,**/pipelines/**/*.yaml"
---

# Azure DevOps YAML pipelines

- These run on Azure DevOps Server (on-prem) with self-hosted Windows agents. Check which tasks and task versions exist on the server before suggesting them; not every Marketplace task is installed.
- Reuse the shared templates the team already has (`template:` references) instead of copying steps. <!-- TEAM-CUSTOMIZE: location of shared templates -->
- Secrets come from variable groups or secure files, never inline values. Don't echo secret variables.
- Keep the SonarQube analysis and Black Duck scan steps; never remove or bypass them.
- Pin task major versions (for example `DotNetCoreCLI@2`).
- Pipeline changes need a human reviewer from the team that owns the pipeline. <!-- TEAM-CUSTOMIZE -->
