---
name: test-design
description: Design test cases from a user story's acceptance criteria using risk-based test design techniques (equivalence partitioning, boundary values, decision tables, state transitions, negative and permission cases), flag untestable criteria, recommend what to automate, and produce a file that creates linked Azure DevOps Test Cases. Use during refinement or as soon as a story is ready, before development finishes.
argument-hint: "[story id]"
---

# Design test cases from acceptance criteria

The goal is to have test cases ready **before** the code is, so testing runs alongside development instead of after it.

## Steps
1. Read the story, its acceptance criteria, parent and discussion with `ado-work-items` (`Get-WorkItem.ps1 -Id <id> -IncludeDiscussion`). Check for existing test cases linked to it ("Tested By" links) so you don't duplicate them.
2. **Testability check.** For each criterion, note if it's ambiguous, untestable or missing a rule (e.g. "fast", "correct amount", "appropriate users"). Report these to the user as questions for the Business Analyst. Don't guess the rule.
3. **Assess risk** for the story: money/pay calculations, permissions, data integrity, integrations, high usage, recently buggy area. Higher risk means more cases and more depth.
4. **Derive test conditions** with the techniques in [references/test-techniques.md](references/test-techniques.md). Typically:
   - one case per scenario's happy path,
   - equivalence classes and boundaries for every input and threshold,
   - a decision table when two or more rules combine,
   - state transitions when the item has a status lifecycle,
   - negative, permission and error-handling cases,
   - regression cases for nearby behavior that the change could break.
5. **Write test cases.** Each has a clear title (`<Feature> - <condition>`), preconditions including the synthetic test data needed, numbered steps with one action each, and an expected result on every step that checks something. Priority 1 = must pass to release.
6. **Recommend the test level and automation** for each case: unit (developer), API/integration, UI end-to-end, or manual/exploratory. Automate stable, high-value, regression-prone cases; keep exploratory charters for the rest.
7. **Present** the cases as a Markdown table, plus a coverage matrix (criterion → cases), and the open questions.
8. **On request, create them in Azure DevOps:** write the JSON file below to `.ai/drafts/<storyId>-testcases.json` and run `New-TestCases.ps1 -InputFile <file>` (preview, user approval, then `-Apply`). Afterwards offer to add a comment on the story listing the new test case IDs.

## JSON for New-TestCases.ps1

```json
{
  "storyId": 1234,
  "testCases": [
    {
      "title": "Paystub PDF - employee with one processed period",
      "priority": 1,
      "tags": ["smoke", "automate-ui"],
      "preconditions": "Synthetic employee 'Test Employee A' with one processed pay period.",
      "steps": [
        { "action": "Sign in as Test Employee A", "expected": "" },
        { "action": "Open Pay > Paystubs", "expected": "The processed period is listed" },
        { "action": "Select Download PDF for that period", "expected": "A PDF downloads and shows gross pay, deductions and net pay matching the period" }
      ]
    }
  ]
}
```

Tags convention: `smoke`, `regression`, and one of `automate-unit`, `automate-api`, `automate-ui`, `manual`. <!-- TEAM-CUSTOMIZE -->

## Rules
- Test data is synthetic. Describe it ("an employee with two jobs in different states"); never copy real records.
- One behavior per test case; keep steps short and unambiguous so anyone on the team can run them.
- Don't mark tests as passed; execution results are recorded by people in Test Plans.
