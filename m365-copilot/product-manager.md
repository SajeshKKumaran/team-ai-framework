# Product Manager prompts for M365 Copilot

Fill in the `[brackets]`. Output formats match the `write-feature-brief` and `release-notes` skills.

## Agent instructions (if you build a Copilot agent)

```text
You are a Product Manager assistant for a Scrum team building HR and payroll software.
You help decide what to build and why, and explain it clearly. You never decide for the Product Manager.
Start from the problem, not the solution. Keep evidence (with its source) separate from assumptions (with how to test them).
Express goals as measurable outcomes. Make scope explicit (in, out, later).
Never invent customer quotes, metrics, market data or dates; say what is missing.
Summarize client and employee feedback without identifying details.
```

## 1. Feature brief from feedback or an idea

```text
Act as a product manager. Using the attached feedback/tickets/notes, write a one-page feature brief with these sections:
Problem (who is affected, what they do today, what it costs) · Evidence (each item with its source) · Assumptions to validate (each with how we'd test it) · Outcomes and success measures (table: outcome, measure, baseline, target, how measured) · Users and key scenarios · Scope (in / out / later) · Risks and dependencies · Open questions (with owner) · Next step.
Label anything not supported by the material as an assumption. Do not invent numbers or quotes. Remove names and identifying details of clients and employees.

[attach or paste material]
```

## 2. Find themes in feedback

```text
Analyze the attached customer feedback / support tickets.
Group them into themes. For each theme: how many items, a short paraphrased example (no names or identifiers), the underlying user problem, and the business impact if we can estimate it (say how).
Then rank the themes by impact and frequency and explain the ranking. Note anything that looks like a bug rather than a feature request.

[attach export]
```

## 3. Prioritization rationale

```text
Help me compare these candidate features for next quarter. For each, assess value (to whom, how much), effort (as given by the team, or "unknown"), risk, dependencies and time sensitivity.
Show a comparison table and two different defensible priority orders with the trade-off between them. Don't pick for me; show what each order optimizes for.

Candidates:
[list with any data you have]
```

## 4. Release notes

```text
From the attached list of completed work items (CSV export from Azure DevOps), draft release notes for [users | internal stakeholders].
Sections: New, Improved, Fixed, Known issues. Write each line from the user's point of view: what they can now do or what no longer goes wrong, in one or two sentences without jargon.
Leave out internal-only items (refactoring, tests, pipeline changes) and list them separately at the end under "Technical notes".
Only include items whose state is Resolved or Closed. List anything you couldn't describe confidently.
```

## 5. Stakeholder update

```text
Write a short stakeholder update (under 150 words) on [feature/initiative] using the attached sprint report and notes.
Include: where we are against the outcome, what shipped (in business terms), top risk and what we're doing about it, and any decision or help needed (by whom, by when). Plain language, no internal jargon.
```

## Before you share
- [ ] Every number traces to a source you can name.
- [ ] Assumptions are labelled as assumptions.
- [ ] No client or employee identifying details.
