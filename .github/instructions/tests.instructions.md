---
name: tests
description: How to write and change automated tests
applyTo: "**/*Tests/**,**/*.Tests/**,**/*Test.cs,**/*Tests.cs,**/*.spec.ts,**/tests/**,**/*Test.php"
---

# Automated tests

## Frameworks
<!-- TEAM-CUSTOMIZE: replace with what the team actually uses. -->
- .NET: _<xUnit | NUnit | MSTest>_ with _<Moq | NSubstitute>_ and _<FluentAssertions | Shouldly | built-in asserts>_.
- Angular: _<Jasmine/Karma | Jest>_ for unit tests; _<Playwright | Cypress | none>_ for end-to-end.
- PHP: _<PHPUnit version>_.

Use the framework, helpers, builders and fixtures already in the test project. Don't introduce a new test library without asking.

## Writing tests
- Name tests for the behavior: `MethodOrScenario_Condition_ExpectedResult`, or the project's existing convention.
- One behavior per test, arranged as Arrange / Act / Assert.
- Cover the acceptance criteria first, then edge cases: boundaries, empty and null input, invalid input, error paths, and concurrency or retry where it applies.
- Assert on outcomes, not implementation details. Mock only what crosses a boundary (database, network, clock, file system, message bus).
- Tests must be deterministic: no real time (inject a clock), no random data without a fixed seed, no dependence on test order or machine state.
- Use synthetic test data. Never copy real employee or client records into tests or fixtures.

## Changing tests
- Never delete, skip or weaken a failing test to make a build pass. If a test is wrong, say why and propose the fix.
- When fixing a bug, first write a test that fails because of the bug, then fix the code.

## Running tests
<!-- TEAM-CUSTOMIZE: exact commands. -->
- .NET: `dotnet test <solution-or-project>` (or Visual Studio Test Explorer for .NET Framework projects).
- Angular: `npm test -- --watch=false`.
- Report the real command output (passed, failed, skipped) in your response.
