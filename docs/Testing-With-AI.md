# Testing with AI: removing the bottleneck

[[_TOC_]]

## Why testing becomes the bottleneck

The usual pattern: test cases get written after development finishes, acceptance criteria turn out to be ambiguous only when someone tries to test them, regression testing is "everything, manually", and bug reports bounce back and forth because they can't be reproduced. AI doesn't fix that by running tests faster. It helps by moving test work **earlier** and making it **narrower and clearer**.

## The approach

::: mermaid
flowchart LR
  R["Refinement<br/>test-design from AC"] --> TC["Test cases in Azure DevOps<br/>linked to the story"]
  R --> Q["Ambiguous AC<br/>back to BA"]
  TC --> DEV["Development<br/>write-unit-tests maps AC to unit tests"]
  TC --> AUT["QE scaffolds automation<br/>for automate-* cases"]
  DEV --> PR["PR<br/>regression-risk: what to retest"]
  PR --> RUN["Run linked cases + retest list<br/>requirement-based suite"]
  RUN --> BUG["bug-report<br/>reproducible, masked"]
:::

### 1. Design tests during refinement, not after development
- The QE runs `test-design` on each story as it enters refinement.
- Ambiguous or untestable acceptance criteria come back as specific questions for the BA, before the sprint starts.
- Approved test cases are created in Azure DevOps with `New-TestCases.ps1`, linked to the story with a "Tests" link and tagged `ai-assisted`.
- In Test Plans, a requirement-based suite for the story shows those cases, so they are ready to run the moment the code is.

### 2. Developers own unit-level coverage of the acceptance criteria
- `write-unit-tests` maps each acceptance criterion and business rule to unit tests, plus boundaries and error paths.
- The Definition of Done requires it, and `self-review` checks it with an acceptance-criteria coverage table.
- Result: the QE spends less time finding defects a unit test would have caught and more time on integration, end-to-end and exploratory testing.

### 3. Retest what changed, not everything
- `regression-risk` reads the PR diff, finds callers and consumers of what changed, rates risk, and maps it to existing tests and test cases.
- Full manual regression is reserved for releases with high-risk changes; day-to-day, the retest list scopes the work.

### 4. Make every bug reproducible the first time
- `bug-report` produces numbered steps from a known state, expected vs. actual, environment, frequency, masked evidence and a severity rationale, and checks for duplicates.

### 5. Automate where it pays
- `test-design` tags each case with a suggested level: `automate-unit`, `automate-api`, `automate-ui` or `manual`.
- Push checks to the lowest level that can catch them; keep UI end-to-end tests for a few critical journeys.
- The QE can ask the `quality-engineer` agent to scaffold API or UI tests from a test case, following the project's existing test framework.

### 6. Synthetic test data, always
- Describe the data a test needs ("an employee with two jobs in different states and a mid-period rate change") and let the AI generate synthetic records or builders for it.
- Never copy production employee, payroll or client records into tests, fixtures or bug reports.

## Who does what

| Activity | BA | QE | SE | SA |
|---|---|---|---|---|
| Testable acceptance criteria | Writes (`refine-story`) | Reviews (`test-design`) | Reviews | Reviews NFRs |
| Test cases from AC | Answers questions | Owns (`test-design`) | Reads before coding | |
| Unit tests for AC | | Spots gaps | Owns (`write-unit-tests`) | |
| Regression scope per PR | | Owns (`regression-risk`) | Runs on own PRs | Consulted on shared components |
| Automation | | Owns UI/API suites | Owns unit/integration | Test architecture |
| Bug reports | | Owns (`bug-report`) | Adds root cause | |

## Signals that it's working

Track these per sprint during the rollout (they're about our process, not individuals):

- Share of sprint stories that had linked test cases **before** development started.
- Number of acceptance-criteria questions raised in refinement vs. discovered mid-sprint.
- Time from "development done" to "testing done" for stories.
- Bugs reopened as "can't reproduce".
- Later: defects found after release.

A query for stories in the current sprint without linked test cases is in the Azure DevOps skill's `references/wiql-examples.md`.
