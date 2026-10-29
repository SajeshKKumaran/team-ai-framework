# Project Manager prompts for M365 Copilot

Fill in the `[brackets]`. Attach a CSV export of the sprint query from Azure DevOps (see the [README](README.md)). Output formats match the `sprint-planning-prep`, `sprint-report` and `retro-synthesis` skills.

## Agent instructions (if you build a Copilot agent)

```text
You are a delivery assistant for a Scrum team. You keep delivery visible and ceremonies short.
Work from the data provided and say which data you used. Separate facts, interpretation and asks.
Flag data-quality problems (stories without acceptance criteria or estimates, tasks without remaining work, items not updated for days).
Describe problems in terms of work and process, never individuals. No blame.
Never present forecasts as commitments; show assumptions.
Write detailed updates for the team and short, jargon-free updates for stakeholders.
```

## 1. Sprint status (team)

```text
Attached is a CSV export of our current sprint from Azure DevOps (columns: ID, Work Item Type, Title, State, Assigned To, Story Points, Remaining Work, Tags, Changed Date).
Sprint goal: [goal]. Sprint ends: [date]. Today: [date].

Write a team status report with:
- Goal status (On track / At risk / Off track) with a one-line reason
- Progress: stories done/total and points done/total
- In progress: table of ID, title, owner, remaining hours
- Blocked or at risk: items tagged Blocked or Active with no change for 3+ days, and what's needed
- Data hygiene: stories without estimates, tasks without remaining work
- Asks: specific, with owner
Use only the data in the file. If something can't be determined from it, say so.
```

## 2. Stakeholder update

```text
Turn this team status into a stakeholder update of 5-8 lines: goal status with reason, what was delivered in business terms (no IDs), top risk and mitigation, and any decision or help needed with a date. No jargon.

[paste team status]
```

## 3. Sprint planning prep

```text
Attached: (1) current sprint export, (2) top of the backlog export (with Acceptance Criteria and Story Points columns).
Team capacity notes: [absences, holidays].

Prepare for sprint planning:
- Carry-over: unfinished items from the current sprint with remaining work
- Candidate stories for next sprint: table with ID, title, points, Ready? and gaps (missing acceptance criteria, missing estimate, open dependency)
- Stories to fix before planning, with suggested owner (BA, PO, SA, QE)
- Risks and dependencies
- A draft sprint goal (one sentence, outcome-focused) based on the highest-priority ready stories
This is preparation for the team; don't present it as a commitment.
```

## 4. Retrospective synthesis

```text
Attached are our retrospective notes [and last retro's action items].
1. For each previous action: done, in progress or dropped.
2. Group the notes into 3-6 themes named as problems or strengths. Paraphrase; don't attribute comments to individuals.
3. For each problem theme, give 1-2 possible root causes, clearly marked as hypotheses for the team to confirm.
4. Propose at most 3 actions, each with an owner role, a due sprint, and how we'll know it worked.
5. List anything that needs escalation outside the team.
```

## 5. Meeting notes to actions

```text
From the attached meeting recap/transcript, list: decisions made, action items (owner, due date if stated), open questions, and risks raised. Keep it to what was actually said; don't add actions nobody agreed to.
```

## Before you share
- [ ] Numbers match the Azure DevOps export.
- [ ] No individual is blamed or singled out.
- [ ] Forecasts show their assumptions.
