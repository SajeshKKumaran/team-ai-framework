# AI-assisted sprint workflow

[[_TOC_]]

How the framework fits into each part of the Scrum cycle: who does what, which agent and skill help, and where a person must decide.

## The flow at a glance

::: mermaid
flowchart TD
  A["1. Discovery<br/>PdM: write-feature-brief"] --> B["2. Refinement<br/>BA: refine-story<br/>SA: design-review<br/>QE: test-design"]
  B --> C{"Definition of Ready?"}
  C -- no --> B
  C -- yes --> D["3. Sprint planning<br/>PM: sprint-planning-prep<br/>SE: plan-implementation"]
  D --> E["4. Build<br/>SE: implement in small steps<br/>write-unit-tests"]
  E --> F["5. Review<br/>SE: self-review, pr-description<br/>code-reviewer agent + human review<br/>QE: regression-risk"]
  F --> G["6. Test<br/>QE: run linked test cases<br/>bug-report"]
  G --> H["7. Sprint review<br/>PdM/PM: release-notes, sprint-report"]
  H --> I["8. Retrospective<br/>PM: retro-synthesis"]
  I -.-> A
:::

## Stage by stage

### 1. Discovery and backlog shaping
| | |
|---|---|
| **Who** | Product Manager (with stakeholders) |
| **AI help** | `product-manager` agent, `write-feature-brief` skill (or the PdM M365 pack) |
| **Output** | Feature brief: problem, evidence vs. assumptions, measurable outcomes, scope, risks |
| **Human decision** | Whether the feature goes on the roadmap, and its priority |

### 2. Refinement (shift-left starts here)
| | |
|---|---|
| **Who** | Business Analyst, Solutions Architect, Quality Engineer, with developers |
| **AI help** | BA: `refine-story` for stories and Gherkin acceptance criteria. SA: `design-review` for risky stories, `write-adr` for decisions. QE: `test-design` to create test cases from the acceptance criteria **now**, and to flag untestable criteria. |
| **Output** | Ready stories with Gherkin AC, open questions answered, test cases linked to each story in Azure DevOps (tag `ai-assisted`) |
| **Human decision** | The team agrees each story meets the Definition of Ready and estimates it |

Tip: run `test-design` on a story *before* the refinement meeting; ambiguous acceptance criteria surface as concrete questions instead of mid-sprint surprises.

### 3. Sprint planning
| | |
|---|---|
| **Who** | Whole team; PM prepares |
| **AI help** | PM: `sprint-planning-prep` (carry-over, readiness gaps, risks, draft sprint goal). SE: `plan-implementation` per story to break it into tasks (created in Azure DevOps after preview and approval). |
| **Output** | Sprint goal, committed stories, tasks with estimates |
| **Human decision** | The commitment and the sprint goal |

### 4. Build
| | |
|---|---|
| **Who** | Software Engineers (QE in parallel) |
| **AI help** | `software-engineer` agent: approved plan → implement one step at a time → build and test after each step → `write-unit-tests` mapped to acceptance criteria. `explain-legacy-code` before touching unfamiliar areas. QE scaffolds automation for test cases tagged `automate-*`. |
| **Output** | Small, tested commits referencing `#<id>` |
| **Human decision** | Approving the plan; reviewing every change before committing |

### 5. Review
| | |
|---|---|
| **Who** | Author, peer reviewer, QE |
| **AI help** | Author: `self-review`, then `pr-description`. Reviewer: `code-reviewer` agent to prepare (read-only). QE: `regression-risk` on the PR to decide what to retest. |
| **Output** | PR with a clear description, AC coverage table and AI-assistance note; a retest list |
| **Human decision** | PR approval is always a person. SonarQube and Black Duck gates still apply. |

### 6. Test
| | |
|---|---|
| **Who** | Quality Engineer, with developers |
| **AI help** | Test cases already exist and are linked to the story (from stage 2); run them from a requirement-based suite in Test Plans. `bug-report` turns observations into reproducible, masked bug reports. |
| **Output** | Test results recorded by people; bugs linked to the story |
| **Human decision** | Pass/fail and closing bugs |

### 7. Sprint review
| | |
|---|---|
| **Who** | Product Manager, Project Manager, team |
| **AI help** | `release-notes` from completed items; `sprint-report` (stakeholder format) |
| **Output** | Release notes, stakeholder update |

### 8. Retrospective
| | |
|---|---|
| **Who** | Whole team; PM facilitates |
| **AI help** | `retro-synthesis` to group notes into themes and up to three owned actions; review last retro's actions |
| **Standing retro question during rollout** | *"Where did AI help this sprint, where did it get in the way, and what should we change in the framework?"* |

## Daily habits

- **Before stand-up:** the PM (or anyone) runs `Get-SprintItems.ps1` and reads the "Needs attention" list: blocked items, stale items, missing estimates.
- **Before starting a story:** read the story with the agent and run `plan-implementation`.
- **Before opening a PR:** `self-review` and `pr-description`.
- **When a story enters refinement:** `test-design`.

## Hand-off artifacts and where they live

| Artifact | Produced by | Lives in | Consumed by |
|---|---|---|---|
| Feature brief | PdM | Feature work item description (or wiki page) | BA, SA |
| Story + Gherkin AC | BA | User Story work item | SE, QE, SA |
| Design review / ADR | SA | Story discussion / `docs/adr/` | SE |
| Test cases | QE | Test Case work items linked with "Tests" | QE, SE |
| Implementation plan and tasks | SE | Task work items under the story | SE, PM |
| PR description | SE | Azure Repos PR | Reviewer, QE |
| Retest list | QE | PR comment or story discussion | QE |
| Bug | QE | Bug work item linked to the story | SE |
| Sprint report, release notes, retro actions | PM, PdM | Wiki / email / Teams | Team, stakeholders |
