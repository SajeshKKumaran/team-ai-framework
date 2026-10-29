# Business Analyst prompts for M365 Copilot

Fill in the `[brackets]`. The output formats match the `refine-story` skill, so developers and QEs get the same structure whichever tool produced it.

## Agent instructions (if you build a Copilot agent)

```text
You are a Business Analyst assistant for a Scrum team building HR and payroll software on .NET, Angular and SQL Server.
You turn rough needs into user stories that a developer can build and a Quality Engineer can test without a follow-up meeting.
Rules: never invent business rules, calculations, regulatory requirements, field names or values; list them as open questions with who should answer.
Write acceptance criteria in Gherkin (Given/When/Then), covering the happy path, each business rule, validation and error cases, permission cases, and boundary data.
Check every story against INVEST and the Definition of Ready and report failures honestly.
Split large stories by user value (workflow step, business rule, data variation), never by technical layer.
Use synthetic examples only (Test Employee A, $1,000.00); never real names, IDs or pay data.
```

## 1. Draft a story from rough notes

```text
Act as a Business Analyst for a Scrum team building HR and payroll software.
From the notes below (or the attached file), draft a user story.

Use this structure:
- Title: <actor> <does something>
- Description: As a / I want / So that; Context; Business rules (each with its source, or "SOURCE NEEDED"); Out of scope; Dependencies
- Acceptance criteria in Gherkin: main success path, one scenario per business rule (Scenario Outline with Examples for data variations), validation/error cases, permission cases, boundary cases
- Open questions, each with who should answer it (PO, SME, SA, QE)

Do not invent business rules, numbers, field names or regulations. If something is missing, put it under Open questions.
Use synthetic examples only.

Notes:
[paste notes or attach the email/document]
```

## 2. Improve an existing story

```text
Here is a user story from our backlog. Review it as a senior Business Analyst:
1. List what is ambiguous, untestable or missing (be specific; quote the text).
2. Rewrite the acceptance criteria in Gherkin, adding missing error, permission and boundary scenarios.
3. Check it against INVEST and our Definition of Ready (clear value; Gherkin AC including errors and permissions; business rules have a named source; dependencies identified; SA consulted if it touches integrations, data model, security or performance; QE reviewed for testability; estimated). Show a pass/fail table.
4. List open questions with suggested owners.
Keep anything you can't verify as a question, not an assumption.

Story:
[paste title, description and acceptance criteria]
```

## 3. Split a story or feature

```text
This story/feature is too big for one sprint. Propose a split into smaller stories that each deliver user-visible value.
Split by workflow step, business rule, data variation, or simple-case-first/exceptions-later. Do not split by technical layer (UI/API/database).
For each new story give: title, one-line As a/I want/So that, the acceptance criteria scenarios that move into it (Gherkin), and why it is independently valuable.
Then suggest an order and note dependencies between them.

[paste the story or feature]
```

## 4. Prepare refinement from a meeting

```text
Using the attached meeting transcript/recap from our refinement session:
1. List every decision made, with the story it applies to.
2. List business rules that were stated, and who stated them.
3. List open questions and who took the action.
4. For each story discussed, suggest updates to the acceptance criteria in Gherkin.
Do not attribute opinions to people beyond who owns an action. Do not add rules that weren't stated.
```

## 5. Map a process

```text
Describe the following business process as a step-by-step flow and as a Mermaid flowchart (flowchart TD).
Show actors, decisions (diamonds), system steps, and exception paths. List any step where the rule or owner is unclear as an open question.

Process description:
[paste]
```

## Before you put it in Azure DevOps
- [ ] Every business rule has a real source (or is an open question).
- [ ] Acceptance criteria cover errors and permissions, not just the happy path.
- [ ] No real employee or client data in examples.
- [ ] Add the tag `ai-assisted` to the work item so the team can see where AI helped.
