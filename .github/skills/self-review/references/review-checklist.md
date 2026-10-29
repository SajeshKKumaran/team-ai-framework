# Team review checklist

<!-- TEAM-CUSTOMIZE: add the things your reviewers keep catching. Remove what your analyzers already enforce. -->

## Correctness
- [ ] Every acceptance criterion is implemented, including error and permission scenarios.
- [ ] Edge cases: null/empty input, boundaries, time zones and date cut-offs, rounding of money, duplicates, concurrency.
- [ ] Error handling: exceptions are not swallowed; failures leave data consistent; user-facing errors are helpful and leak nothing.
- [ ] No leftover debug code, commented-out code, TODOs without a work item.

## Tests
- [ ] New or changed behavior has tests at the right level.
- [ ] Bug fixes include a test that failed before the fix.
- [ ] No tests skipped, deleted or weakened to pass.
- [ ] Tests are deterministic (no real time, randomness without seed, order dependence).

## Security and data protection
- [ ] Authorization checked on every new endpoint, page, handler or query.
- [ ] Inputs validated; SQL parameterized; output encoded.
- [ ] No secrets, connection strings or tokens in code, config committed to the repo, logs or tests.
- [ ] Personal and pay data not logged, not in URLs, not in exception messages; masked where displayed partially.

## Performance and reliability
- [ ] No N+1 queries or unbounded result sets; paging where lists can grow.
- [ ] Async used correctly (no `.Result`/`.Wait()`); cancellation passed through.
- [ ] Message handlers idempotent; retries safe; timeouts set on outbound calls.

## Design and standards
- [ ] Follows the repository instructions and existing patterns; no second way of doing the same thing.
- [ ] Changes are within the work item's scope.
- [ ] Target framework respected (.NET Framework vs .NET 10 APIs).
- [ ] No new package without Black Duck approval; no changes to pipelines or schema unless planned.
- [ ] Names say what things are; methods do one thing.

## Delivery
- [ ] Builds without new warnings; SonarQube issues addressed.
- [ ] Config changes documented for each environment.
- [ ] Database migrations reversible or with a rollback note.
- [ ] Docs, wiki or ADR updated if behavior or architecture changed.
- [ ] PR description written (`pr-description` skill) and linked to `#<id>`.
