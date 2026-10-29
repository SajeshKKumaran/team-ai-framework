---
name: design-review
description: Review a story, design note, proposed approach or pull request against the team's architecture principles and non-functional requirements (security, data protection, performance, reliability, observability, maintainability, operability). Use before development starts on risky stories, or when a PR changes integrations, data models or cross-cutting code.
argument-hint: "[work item id, file, branch or description]"
---

# Design review

## Inputs
- A work item (read it and its linked items with `ado-work-items`), a design note, a diagram, or a branch/PR (`git diff <target>...HEAD`).
- The relevant code: always search the repository for the components involved before judging the design.
- Existing ADRs in the repo.

## Review checklist

Mark each area **OK**, **Concern** or **Not applicable**, with evidence (file paths, line numbers, quotes from the story).

| Area | What to check |
|---|---|
| Fit | Consistent with existing ADRs and the patterns already in the codebase? Does it add a second way of doing something we already do? |
| Boundaries | Clear ownership of data and logic; no business rules leaking into controllers, UI or SQL; no new tight coupling between modules. |
| Integration | Contracts versioned; Service Bus messages idempotent and retry-safe; timeouts, retries and failure handling defined; no new MSMQ. |
| Data | Schema changes via migrations; backward compatibility during deployment; data volumes and indexes considered; retention. |
| Security | Authentication and authorization on every entry point; input validation; secrets in configuration, not code; least privilege for service accounts. |
| Data protection | Personal and pay data minimized, masked in logs, not exposed in URLs or errors; access audited where required. |
| Performance | Expected load; N+1 queries; paging for lists; caching and its invalidation; long-running work moved off the request path. |
| Reliability | Behavior when a dependency is down; partial failures; transactions; idempotency. |
| Observability | Structured logs with correlation IDs; metrics or health checks for new components; actionable errors. |
| Operability | Works on on-prem Windows hosting (IIS/Kestrel services); configuration per environment; deployment and rollback steps; pipeline impact. |
| Maintainability | Testable design; reasonable size; follows the instructions files. |
| Dependencies | New packages need Black Duck review; prefer what the platform or team already uses. |
| Testability | Can each acceptance criterion be tested at the right level (unit, integration, end-to-end)? |

## Output

```markdown
# Design review: <subject>

**Summary:** <2-3 sentences: what is proposed and the overall assessment>
**Recommendation:** Proceed | Proceed with changes | Rework before development

## Concerns (most important first)
1. **<Area>: <issue>.** Evidence: <…>. Risk: <…>. Suggested change: <…>.

## Checklist
| Area | Result | Notes |

## Questions for the author
## Decisions worth an ADR
```

## Rules
- Ground findings in the actual code or text. Say clearly when something is an assumption.
- Separate must-fix risks from preferences.
- Do not edit code during a review.
