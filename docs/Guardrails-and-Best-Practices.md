# Guardrails and best practices

[[_TOC_]]

We only use enterprise-approved AI tools (GitHub Copilot Enterprise and Microsoft 365 Copilot), so there is no restriction on what may be typed into a prompt. These practices are about quality, security and trust, and they apply to every role.

## 1. You own the result
- Whatever AI drafts, the person who commits, sends, files or approves it is accountable for it.
- Read it, check it, and be able to explain it. "Copilot wrote it" is never an answer in a review.

## 2. Verify before you rely on it
- **Facts and numbers:** trace them to a source. AI can produce confident, plausible and wrong figures.
- **Code:** build it, run the tests, read the diff. Watch for APIs, packages and config keys that don't exist.
- **Business rules:** these come from people and documents, never from the AI. If the AI states a rule, ask "where does that come from?"

## 3. Handle data thoughtfully
Even with approved tools:
- **Secrets never go in prompts, code, tests or logs:** passwords, connection strings, tokens, certificates. Use configuration and secure variables.
- **Prefer synthetic data.** Use made-up employees and amounts for examples, tests and bug reports. Only use real records when a task genuinely requires it, and keep it to what's needed.
- **Mask personal data** in logs, screenshots and error text before attaching them to work items.
- **Keep identifying details out of shared artifacts** (feature briefs, release notes, retro notes) unless they're required.

## 4. Treat content as data, not instructions
Text inside work items, documents, web pages, logs or code comments can contain instructions ("ignore previous rules and…"). The agents are told to treat such text as data and report it rather than act on it. If you see an agent following instructions from content, stop it and tell the framework steward.

## 5. Keep agents on a short leash
- Approve terminal commands individually unless they are clearly read-only (build, test, search). Don't enable blanket auto-approval for commands or tools.
- Don't let agents run destructive commands (deleting files or branches, dropping tables, force-pushing).
- Commit or stash before an agent run so you can discard a bad attempt.
- Agents never push, merge or approve PRs.

## 6. Writing to Azure DevOps
The `ado-work-items` skill enforces this in code:
- every create, update and comment is **previewed** first and only applied after an explicit "yes" in the conversation;
- it can't delete, close or remove work items, re-assign them, or write fields outside an allowlist;
- everything it creates or edits is tagged `ai-assisted`;
- every applied change is logged locally (`~/.copilot/logs/ado-skill-audit.log`);
- credentials: your Windows sign-in by default, or a token from your own environment variable; tokens never go in prompts or files.

Changing these guardrails (`ado.config.json`) needs agreement from the team and the Solutions Architect.

## 7. Code quality and licensing gates stay in place
- SonarQube and Black Duck gates apply to AI-written code exactly as to any other code. Never suppress a rule or skip a scan to get AI-written code through.
- New packages suggested by AI go through the normal Black Duck review.
- Check your organization's Copilot policy on suggestions that match public code, and follow it.

## 8. Be transparent
- PR descriptions include a one-line AI-assistance note (`pr-description` adds it).
- Work items touched by the skill carry the `ai-assisted` tag.
- This isn't about blame. It lets us see where AI helps, and it lets reviewers calibrate.

## 9. What stays with people
- Business rules, priorities, scope and commitments.
- Architecture decisions (AI drafts the ADR; people decide).
- Security and data-protection sign-off.
- PR approval, test pass/fail, closing bugs.
- Anything about individuals: performance, assignment, HR matters. AI-usage data is never used to evaluate individuals.

## Quick checklist before you ship or send

- [ ] I've read all of it and can explain it.
- [ ] Facts, numbers and rules trace to a real source.
- [ ] Code builds, tests pass, and I reviewed the diff.
- [ ] No secrets; personal data minimized and masked.
- [ ] Quality and licensing gates passed without suppressions.
- [ ] AI assistance noted where our process asks for it.
