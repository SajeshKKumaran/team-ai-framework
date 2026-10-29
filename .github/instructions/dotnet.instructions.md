---
name: dotnet
description: C# conventions for .NET 10 and .NET Framework 4.x code
applyTo: "**/*.cs,**/*.csproj,**/*.cshtml,**/*.razor"
---

# C# and .NET

## First, check the target framework
- Read the project's `.csproj` before suggesting APIs. `TargetFramework` of `net10.0` (or similar) means modern .NET; `TargetFrameworkVersion` `v4.x` or `net4xx` means .NET Framework.
- Do not use APIs, language features or packages the target framework doesn't support. Many .NET Framework projects compile with an older C# `LangVersion`; check it.
- In .NET Framework code, don't introduce `Microsoft.Extensions.*` packages or new patterns without asking. Follow what the project already does.

## Modern .NET (new work)
- Use constructor dependency injection and the options pattern (`IOptions<T>`) for configuration. No static service locators.
- Async all the way: `async`/`await` for I/O, pass `CancellationToken` through, never `.Result` or `.Wait()`.
- Respect nullable reference types where enabled; don't silence warnings with `!` unless you explain why the value can't be null.
- Log with `ILogger<T>` and structured message templates (`"Processed {Count} records"`), never string interpolation in log calls. Never log personal data or secrets.
- Validate inputs at the boundary (controllers, message handlers) and return problem details for API errors.
- Prefer small, focused classes and methods. Keep business rules out of controllers and data-access code.

## Data access (EF Core / SQL Server)
- Use EF Core migrations for schema changes; never edit an applied migration.
- Avoid N+1 queries: project with `Select`, use `AsNoTracking()` for read-only queries, and include only what you need.
- Raw SQL only when necessary, and always parameterized (`FromSqlInterpolated`, `SqlParameter`). Never build SQL by string concatenation.

## Messaging
- New messaging uses Azure Service Bus. Handlers must be idempotent and safe to retry.
- MSMQ code is legacy: maintain it, but don't extend it without Solutions Architect approval.

## Error handling
- Catch only exceptions you can handle. Don't swallow exceptions; log with context and rethrow with `throw;`.
- Don't use exceptions for normal control flow.

<!-- TEAM-CUSTOMIZE: naming conventions, folder layout per project type, logging framework, shared libraries to prefer. -->
