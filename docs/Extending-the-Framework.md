# Extending and forking the framework

[[_TOC_]]

## Forking model

```
team-ai-framework (upstream, owned by the framework steward)
   ├── fork: Team A   (customized, pulls upstream updates)
   ├── fork: Team B
   └── ...
            └── installed into each product repo's .github/
```

1. **Fork** this repository for your team in Azure Repos.
2. **Customize** in your fork: every place meant for team changes is marked `TEAM-CUSTOMIZE`. Keep your edits inside those blocks where you can; it makes upstream updates easier to merge.
3. **Install** into your product repos with `scripts/Install-Framework.ps1 -TargetRepo <path>`.
4. **Pull upstream updates** periodically:
   ```powershell
   git remote add upstream <url-of-upstream-framework-repo>   # once
   git fetch upstream
   git merge upstream/main    # resolve conflicts, keeping your TEAM-CUSTOMIZE content
   ```
   Check `CHANGELOG.md` first; breaking changes are called out.
5. **Contribute back** anything other teams would benefit from (a new skill, a better checklist) with a PR to upstream explaining the problem it solves.

## What can change where

| Change | Core (upstream) | Team fork | Product repo |
|---|---|---|---|
| Principles, guardrails, ADO skill scripts | ✔ | Only with steward + SA agreement | ✘ |
| Agent responsibilities and skills list | ✔ | ✔ | Rarely |
| Templates (story, ADR, test case, checklist) | ✔ | ✔ | ✘ |
| Stack and product details in instructions | Placeholders only | Team defaults | ✔ |
| `ado.config.json` (project, team) | Placeholders only | ✔ | ✔ |

## Choosing the right customization

| You want to… | Use | Why |
|---|---|---|
| Set a rule that applies to every request in a repo | `.github/copilot-instructions.md` | Always loaded; keep it short |
| Set rules for one language, folder or file type | `.github/instructions/<name>.instructions.md` with `applyTo` | Loaded only when matching files are involved |
| Package a repeatable workflow (with templates or scripts) | A skill in `.github/skills/<name>/` | Loaded on demand; works in VS Code, the CLI and Visual Studio; runs as `/name` |
| Give a role a persona, priorities and limited tools | An agent in `.github/agents/<name>.agent.md` | Selected explicitly; least-privilege tools |
| Reusable prompt for one VS Code chat mode only | Avoid prompt files; write a skill instead | Prompt files only run in VS Code's Local harness |

## Adding a skill

1. Create `.github/skills/<skill-name>/SKILL.md`. The folder name must equal the `name` in the frontmatter (lowercase, hyphens).
2. Frontmatter:
   ```yaml
   ---
   name: estimate-story
   description: <what it does>. Use when <the situations that should trigger it>.
   argument-hint: "[work item id]"
   ---
   ```
   The **description decides when the agent loads the skill**. Name the triggers users actually say.
3. Body: purpose, inputs, numbered steps, output template, rules. Keep it under 500 lines; move long material into `references/` and link to it.
4. Scripts go in `scripts/` inside the skill, written for Windows PowerShell 5.1 (and PowerShell 7). Anything that writes to a shared system must preview by default and require an explicit `-Apply`.
5. Add it to the agents that should use it (the "Skills to use" section) and to `docs/Overview.md`.
6. Run `./scripts/Test-Framework.ps1`, then try it on two or three real tasks before sharing.

## Adding or changing an agent

- File: `.github/agents/<name>.agent.md`; `name` matches the file name.
- Use only portable frontmatter (`name`, `description`, `tools`) so the agent works in VS Code and the Copilot CLI.
- Tools: give the least it needs. Common aliases: `read`, `search`, `edit`, `execute`, `web`, `todo`, `agent`. A reviewer agent gets no `edit`.
- Body: role, how to work, skills to use, hand-offs, guardrails.
- **VS Code handoff buttons (optional).** If your team works in VS Code's Local harness, you can add guided hand-offs between agents. They're ignored elsewhere, and the editor flags them as unsupported in the Copilot harness.
  ```yaml
  handoffs:
    - label: Design test cases
      agent: quality-engineer
      prompt: Design test cases for the story we just refined.
      send: false
  ```

## Changing the Azure DevOps guardrails

Edit `ado.config.json`: `creatableTypes`, `writableFields`, `blockedStates`, `maxItemsPerWrite`. Don't remove the preview/`-Apply` pattern or add delete capability. Changes need agreement from the team and the Solutions Architect, and belong in the CHANGELOG.

## Publishing the docs as a wiki

In Azure DevOps: **Wiki → Publish code as wiki**, choose this repository and the `docs` folder. Page order comes from `docs/.order`. Links to files outside `docs/` (prompt packs, skills) work when browsing in Azure Repos; in the wiki, either publish the repository root instead or replace those links with full Azure Repos URLs.

## Versioning

- `VERSION` holds the framework version (semantic versioning). Bump minor for new skills or agents, major for changes that break existing forks (renamed skills, changed file formats, changed guardrail behavior).
- Record every change in `CHANGELOG.md`.
- A validation pipeline (`pipelines/validate-framework.yml`) runs `Test-Framework.ps1` on pull requests.

## Ownership

<!-- TEAM-CUSTOMIZE -->
- **Framework steward:** _<name>_ (owns upstream, reviews contributions, runs the monthly update).
- **Instructions owner:** the Solutions Architect (keeps `copilot-instructions.md` and `.instructions.md` files accurate).
- **Role champions:** one person per role who collects feedback and proposes changes.
