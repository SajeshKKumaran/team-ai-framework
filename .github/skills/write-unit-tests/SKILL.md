---
name: write-unit-tests
description: Write or extend unit tests for C# (.NET 10 and .NET Framework), Angular/TypeScript or PHP code, mapped to acceptance criteria and edge cases, following the project's existing test framework and conventions, then run them and report real results. Use when adding tests for new or changed code, closing coverage gaps, or writing characterization tests before refactoring legacy code.
argument-hint: "[file, class, method, or work item id]"
---

# Write unit tests

## Steps
1. **Learn the local conventions first.** Open the nearest existing test project or `*.spec.ts` files. Note the framework, mocking library, assertion style, naming pattern, builders/fixtures and folder layout. Follow them exactly; don't introduce a new library.
2. **Decide what to test.** From the work item's acceptance criteria (read with `ado-work-items`) and the code under test, list the behaviors:
   - each acceptance criterion / business rule,
   - boundaries (0, 1, max, just over max; dates at period ends; rounding of money),
   - invalid and missing input,
   - error paths (dependency throws, returns nothing, times out),
   - permissions, if the unit enforces them.
   Show this list to the user before writing more than a handful of tests.
3. **Write the tests.** Arrange / Act / Assert, one behavior per test, descriptive names. Mock only boundaries (database, HTTP, clock, file system, message bus). Use synthetic data and fixed dates (inject a clock).
4. **Characterization tests for legacy code:** when the current behavior is unclear, write tests that pin down what the code does today (even if it looks wrong), mark suspicious behavior with a comment and tell the user. Don't change production code in the same step.
5. **Run them** with the project's command (see `tests.instructions.md`), and report the actual output. If a test fails, determine whether the test or the code is wrong and say which; never weaken the assertion to make it pass.
6. **Summarize coverage:** which behaviors are now covered and which are still not (and why, e.g. needs integration test).

## Hard-to-test code
If the code can't be tested without a real database, static calls or `DateTime.Now`, propose the smallest seam (an interface, an injected clock, extracting a pure method) and ask before changing production code.

## Rules
- No real employee, client or pay data in tests.
- No tests that only assert a mock was called, unless the call *is* the behavior (e.g. a message was published).
- No sleeps or real time in tests; no dependence on test order.
