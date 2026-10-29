---
name: explain-legacy-code
description: Explain unfamiliar or legacy code (.NET Framework, Web Forms, WCF, MSMQ, stored procedures, PHP) in plain language - what it does, how data flows, the business rules buried in it, the risky spots, and how to change it safely. Use when onboarding to an area, before modifying legacy code, or before planning a migration.
argument-hint: "[file, folder, class, method or feature name]"
---

# Explain legacy code

## Steps
1. Find the code. Start from what the user names and follow the calls in both directions: who calls it (entry points: pages, controllers, services, scheduled jobs, queue listeners) and what it calls (database, queues, files, other services).
2. Read before explaining. Quote file paths and line ranges for every claim.
3. Explain at three levels, top-down:
   - **Purpose:** one paragraph, in business terms.
   - **Flow:** the main path as numbered steps, plus a Mermaid sequence diagram if more than three components are involved.
   - **Details that matter:** business rules (conditions, calculations, magic numbers, hard-coded IDs), side effects (writes, messages, emails, files), configuration it depends on, error handling, and threading or transactions.
4. List **risks for change**: missing tests, shared state, static dependencies, implicit contracts (column names, queue message formats, file layouts), code that other systems may depend on.
5. Suggest **how to change it safely**: characterization tests to write first, seams for dependency injection, the smallest safe step.
6. If the user is planning a migration (.NET Framework -> .NET 10, MSMQ -> Service Bus), add a section on blockers: APIs not available on modern .NET (System.Web, WCF server, AppDomains, Remoting), third-party libraries without modern versions, and configuration (`web.config`/`app.config`) that must move.

## Rules
- Distinguish what the code **does** from what it was probably **meant** to do. Report suspected bugs separately; don't silently "fix" them in the explanation.
- Say "I couldn't find where X is called" rather than guessing.
- Don't modify code in this skill.
