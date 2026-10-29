# Developer onboarding: working with AI

[[_TOC_]]

For engineers who are new to AI-assisted development. Plan on about two weeks of normal sprint work, with a few short exercises built in.

## The mental model

Think of Copilot as a very fast pair programmer who has read the team's rules in `.github/` and can search the whole repo in seconds, but who **can't read your mind, doesn't know the business, and is sometimes confidently wrong**. You stay the engineer of record: you decide the approach, you review every line, and you answer for what gets committed.

## Which mode for which job

| Mode | Use it for | Example |
|---|---|---|
| Inline suggestions | Finishing the line or block you're typing | Completing a LINQ query, a test arrange block |
| Ask | Questions; no files change | "How does PayPeriodService decide the cut-off date?" |
| Plan | A step-by-step plan for a change before any edits | "Plan how to add PDF export for paystubs" |
| Agent (with a role agent selected) | Multi-file changes that also run commands such as build and test | "Implement step 1 of the approved plan, then run the tests" |

Start with Ask and Plan. Use Agent once you're comfortable reviewing its diffs.

## The core loop

1. **Context.** Point the agent at the work item (`#1234`) and the relevant files. Say what "done" means.
2. **Plan.** `/plan-implementation 1234`. Read it critically. Push back on anything you'd do differently.
3. **One small step.** Ask for one step of the plan, not the whole story.
4. **Verify.** Build and run the tests (the agent can run them; read the actual output).
5. **Review the diff.** Read every changed line. Ask "why did you change this?" about anything unexpected.
6. **Commit** once you understand and agree with the change. Commit often; git is your undo button.

Repeat steps 3-6. Before the PR: `/self-review`, then `/pr-description`.

## Prompting habits that work

- **Be specific about the goal, the place and the constraints.** "Add validation to `TimesheetController.Submit` so hours per day can't exceed 24; return a 400 with the existing problem-details format; add unit tests" beats "add validation".
- **Point at examples.** "Follow the pattern in `EmployeeQueryHandler`." Reference files with `#file` or by path.
- **Ask it to ask.** "Before you start, list anything that's unclear."
- **Say what not to do.** "Don't change the public interface." "Don't add packages."
- **Keep conversations focused.** Start a new chat for a new task; long chats drift and get slower.
- **When it goes in circles, stop.** Restate the problem with more context, or do that bit yourself. Arguing with it rarely helps.

## Reviewing AI-written code

Check especially for:

- **Invented things:** methods, config keys, NuGet packages, table or column names that don't exist.
- **Scope creep:** reformatting, renames or "improvements" outside the task.
- **Wrong framework:** .NET 10 APIs in a .NET Framework 4.x project, or vice versa.
- **Shallow tests:** tests that assert nothing meaningful, mock the thing under test, or were changed to pass.
- **Security and data:** missing authorization checks, unparameterized SQL, personal data in logs.
- **Silent behavior changes** in legacy code: rounding, null handling, date boundaries.

If you can't explain a line to a reviewer, don't commit it.

## Two-week learning path

Do these on real work where possible. Each takes 30-60 minutes. Share one learning in stand-up or the retro.

| Day | Exercise | What good looks like |
|---|---|---|
| 1 | Install and verify ([Getting started](Getting-Started.md)). Ask the agent to summarize the team rules. | The summary matches `copilot-instructions.md`. |
| 2 | `/explain-legacy-code` on an area **you already know**. | You can spot what it got right, what it missed and what it got wrong. That calibrates your trust. |
| 3 | `/write-unit-tests` for an existing, untested class. | Tests follow the project's framework and naming; they run; at least one edge case you hadn't thought of. |
| 4 | `/plan-implementation` for a small bug or task. Don't implement. | A plan with real file paths, tests mapped to the acceptance criteria, and at least one question back to you. |
| 5 | Implement that plan in Agent mode, one step at a time. | Small diffs, green tests after each step, nothing you can't explain. |
| 6-8 | A full story: plan → implement → tests → `/self-review` → `/pr-description`. | The PR description has an AC coverage table and an honest "not tested" section. |
| 9 | Use the `code-reviewer` agent to prepare for reviewing a colleague's PR. | You agree with some findings, reject some, and find something it missed. |
| 10 | Pair with a teammate for an hour on their story, swapping who drives the agent. | You each pick up one habit from the other. |

## Common pitfalls

- **Accepting a big diff because it compiles.** Ask for smaller steps instead.
- **Letting the agent run for a long time unattended.** Check in after each step; stop it if it wanders.
- **Not committing before an agent run.** Commit or stash first so you can throw away a bad attempt.
- **Pasting secrets or real data to "give it context".** Use config names and synthetic examples.
- **Over-trusting explanations of legacy code.** Verify the important claims by reading the code or running it.
- **Giving up after one bad answer.** Usually the fix is more context or a smaller ask.

## FAQ

**Does the AI follow our coding standards automatically?** It reads `.github/copilot-instructions.md` and the matching `.instructions.md` files on every request. If it keeps missing a rule, the rule may be unclear or missing; tell the Solutions Architect so the instructions get fixed for everyone.

**Can I use it on .NET Framework projects in Visual Studio?** Yes. Visual Studio reads the same instructions and skills. Make sure the agent knows the target framework.

**Should I mention AI in my PR?** Yes, the `pr-description` skill adds a one-line AI-assistance note. It's not a confession; it helps reviewers and helps us learn what works.
