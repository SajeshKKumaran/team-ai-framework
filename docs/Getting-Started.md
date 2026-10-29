# Getting started

[[_TOC_]]

## 1. Prerequisites

| What | Who | Notes |
|---|---|---|
| GitHub Copilot Enterprise seat | Everyone using agents and skills | PM, Product Manager and BA use the [M365 prompt packs](../m365-copilot/README.md) until their seats arrive |
| VS Code (current release) with GitHub Copilot and Copilot Chat | Everyone with a seat | Keep it updated; agent and skill support moves fast |
| GitHub Copilot CLI | Optional; recommended for SA, QE and non-coding roles | Install per [GitHub's docs](https://docs.github.com/copilot/how-tos/set-up/install-copilot-cli) (for example `winget install GitHub.Copilot` or `npm install -g @github/copilot`) |
| Windows PowerShell 5.1 or PowerShell 7 | Everyone using the Azure DevOps skill | Already on Windows machines |
| Access to the Azure DevOps project | Everyone | The skill uses your Windows sign-in |

### PowerShell scripts on Windows

The install, validation and Azure DevOps scripts are plain PowerShell.
- If you got the framework as a downloaded zip, unblock the files once: `Get-ChildItem -Recurse | Unblock-File` in the framework folder. (Cloning from Azure Repos doesn't need this.)
- If PowerShell says running scripts is disabled, use `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` if company policy allows it. If your organization requires signed scripts, ask IT to sign them with the company code-signing certificate before rollout. <!-- TEAM-CUSTOMIZE: your company's rule -->

## 2. Choose how to install

### Option A: into a product repository (developers, QE, SA)

This is the main path. Instructions, agents and skills live in the product repo, so everyone working on that code gets the same behavior in every tool.

```powershell
# from your clone of the team's fork of this framework
./scripts/Install-Framework.ps1 -TargetRepo C:\src\payroll-portal
```

The script copies `.github/` (instructions, agents, skills) into the repo, adds `.ai/drafts/` to `.gitignore`, and never overwrites an existing `copilot-instructions.md` without `-Force` (it writes a `.framework.md` copy for you to merge instead).

Then, in the product repo:

1. Search for `TEAM-CUSTOMIZE` and fill in each placeholder (product description, repo map, test frameworks, branch naming…).
2. Fill in `.github/skills/ado-work-items/ado.config.json` (collection URL, project, team).
3. Commit on a branch and open a PR so the team reviews the rules the AI will follow.

### Option B: the framework repo as your workspace (PM, Product Manager, BA once they have seats)

Clone the team's fork and open it in VS Code, or run `copilot` in that folder. Everything works without a product repo: the role agents, the planning and reporting skills, and the Azure DevOps skill. Drafts go to `.ai/drafts/` and are not committed.

### Option C: personal install for the Copilot CLI

```powershell
./scripts/Install-Framework.ps1 -User
```

Copies agents to `~/.copilot/agents` and skills to `~/.copilot/skills`, so the CLI has them in any folder. Be aware that a **user-level agent overrides a repository agent with the same name**; if your product repo customizes an agent, remove the personal copy.

## 3. Check it works

**VS Code**
1. Open the repo and the Chat view.
2. Open the agent picker: you should see `software-engineer`, `quality-engineer` and the other role agents.
3. Type `/` in the chat box: the skills appear as commands (for example `/plan-implementation`).
4. Ask: *"Summarize the team rules you are following in this repo."* The answer should reflect `copilot-instructions.md`, and the response's references should list it.

**Copilot CLI**
1. Run `copilot` in the repo folder.
2. Type `/agent` to see the role agents.
3. Ask: *"Which skills do you have available?"*

**Azure DevOps skill**

```powershell
cd .github/skills/ado-work-items
./scripts/Find-WorkItems.ps1 -AssignedTo '@Me' -Top 5
```

You should see a table of your work items. If not, see Troubleshooting in the skill's `SKILL.md`.

**Framework files**

```powershell
./scripts/Test-Framework.ps1
```

Checks that every skill and agent is well-formed and lists remaining `TEAM-CUSTOMIZE` placeholders.

## 4. Your first 30 minutes

| Role | Try this |
|---|---|
| Software Engineer | Pick the `software-engineer` agent and ask: *"/plan-implementation 1234"* for a small story or bug. Read the plan; don't implement yet. |
| Quality Engineer | Pick `quality-engineer`: *"/test-design 1234"* for a story in refinement. |
| Solutions Architect | *"/explain-legacy-code <a folder you know well>"* and judge its accuracy. |
| Business Analyst | *"/refine-story 1234"* or the first prompt in the [BA pack](../m365-copilot/business-analyst.md). |
| Project Manager | *"/sprint-report team"* or the first prompt in the [PM pack](../m365-copilot/project-manager.md). |
| Product Manager | *"/write-feature-brief"* with notes from a recent request, or the first prompt in the [PdM pack](../m365-copilot/product-manager.md). |

Then read your section in the [role playbooks](Role-Playbooks.md). Developers new to AI-assisted work should go through the [developer onboarding path](Developer-Onboarding.md).

## Good to know

- VS Code can run chats in different agent "harnesses". Instructions, agents and skills work in both the Local and Copilot harnesses; agent **handoff buttons** only exist in the Local harness, so our agents describe hand-offs in text instead.
- Skills load automatically when your request matches their description. You can also run one explicitly with `/skill-name`.
- If Copilot ignores the instructions, check the response's references, and make sure the repo (not a parent folder) is the workspace root.
