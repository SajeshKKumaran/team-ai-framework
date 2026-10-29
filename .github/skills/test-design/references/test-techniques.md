# Test design techniques (quick reference)

## Equivalence partitioning
Split each input into classes the system should treat the same; test one value per class, including invalid classes.
Example: hours worked per week → `< 0` (invalid), `0`, `1-40` (regular), `> 40` (overtime), non-numeric (invalid).

## Boundary value analysis
Test at, just below and just above each boundary. Most defects live here.
Example: overtime threshold 40 → 39.99, 40, 40.01. Date cut-offs: last day of period, first day of next, 23:59 vs 00:00, month and year end, leap day.

## Decision tables
When several conditions combine to decide an outcome, list every meaningful combination.

| Full-time | In probation | Has dependents | Eligible for plan B? |
|---|---|---|---|
| Y | N | Y | Y |
| Y | N | N | Y |
| Y | Y | – | N |
| N | – | – | N |

Each row is a test case. Missing or contradictory rows are questions for the BA.

## State transitions
For anything with a lifecycle (timesheet: Draft → Submitted → Approved/Rejected → Paid), test every valid transition and at least the important invalid ones (e.g. edit after Approved).

## Negative and error cases
Missing required fields, wrong formats, duplicates, values too long, concurrent edits, dependency down or slow, session expired.

## Permissions
For each role: can do / can't do / can see / can't see. Include the "another user's data" case (employee A must not see employee B's paystub).

## Data variations worth checking in HR/payroll domains
Multiple jobs or rates, mid-period changes (hire, termination, rate change), different states/locales and time zones, retroactive adjustments, zero and negative amounts, rounding of currency.

## Exploratory charters
For areas that are new, risky or hard to specify:
`Explore <area> with <resources/data> to discover <information/risk>.` Time-box (60-90 minutes) and note findings.

## Choosing the test level
| Level | Best for | Owner |
|---|---|---|
| Unit | Business rules, calculations, validation | Developer |
| API/integration | Contracts, data access, messaging, permissions | Developer + QE |
| UI end-to-end | A few critical user journeys | QE |
| Manual/exploratory | New, visual, or rapidly changing areas | QE |

Push each check to the lowest level that can catch it.
