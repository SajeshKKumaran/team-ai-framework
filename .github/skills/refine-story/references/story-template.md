# Story template

<!-- TEAM-CUSTOMIZE: align with your team's Definition of Ready and split threshold. -->

## Title
`<Actor> <does something> <so value is visible>` — short, starts with the user, not the system.
Example: "Employee downloads a paystub as a PDF"

## Description

**As a** <specific role>
**I want** <capability>
**So that** <business value or outcome>

**Context:** why now, what happens today, link to the feature brief or parent.

**Business rules:**
1. <rule, with its source: policy doc, SME name, regulation>

**Out of scope:** what this story deliberately does not cover.

**Dependencies:** other stories, teams, systems, data.

**Notes for design/test:** integration points, NFRs (performance, security, audit), test data needs.

## Acceptance criteria (Gherkin)

```gherkin
Scenario: <main success path>
  Given <starting state>
  And <more context>
  When <action>
  Then <observable outcome>

Scenario Outline: <rule with data variations>
  Given <state with <parameter>>
  When <action>
  Then <outcome with <result>>
  Examples:
    | parameter | result |
    | ...       | ...    |

Scenario: <error or validation case>
  Given ...
  When ...
  Then <the user sees ...> and <nothing is saved>

Scenario: <permission case>
  Given a user without <permission>
  When ...
  Then ...
```

## Quality checks

**INVEST**

| Check | Question | Pass? |
|---|---|---|
| Independent | Can it be built and released without another unfinished story? | |
| Negotiable | Does it describe the need, not a fixed solution? | |
| Valuable | Would a user or the business notice when it ships? | |
| Estimable | Does the team know enough to size it? | |
| Small | Fits comfortably in one sprint? | |
| Testable | Is every scenario observable and unambiguous? | |

**Definition of Ready**
- [ ] Clear user, need and value
- [ ] Acceptance criteria in Gherkin, including error and permission cases
- [ ] Business rules have a named source
- [ ] Dependencies identified and not blocking
- [ ] Solutions Architect consulted if it touches integrations, data model, security or performance
- [ ] Quality Engineer has reviewed the scenarios for testability
- [ ] Estimated by the team
