---
name: c4-diagram
description: Draw C4 model diagrams (system context, container, component) or sequence diagrams in Mermaid from the codebase and conversation, ready for the Azure DevOps Wiki. Use when asked for an architecture diagram, a system context view, how components interact, or a picture of a flow.
argument-hint: "[context | container | component | sequence] [system or flow]"
---

# C4 and sequence diagrams in Mermaid

## Steps
1. Pick the level the user needs:
   - **Context:** the system, its users and the external systems it talks to.
   - **Container:** deployable/runnable units (web apps, APIs, Windows services, databases, queues) and how they communicate.
   - **Component:** the main parts inside one container.
   - **Sequence:** the order of calls for one scenario.
2. Build it from evidence. Search the repo for solution/project files, `appsettings*.json`/`web.config` connection names, HTTP clients, Service Bus/MSMQ queue names, and controllers. Ask about anything you can't see (external systems, users, hosting).
3. Draw with Mermaid **flowchart** syntax using C4 conventions (below). It renders on older Mermaid versions such as the one in Azure DevOps Server's wiki. Use Mermaid's native `C4Context` syntax only if the team confirms their wiki renders it. <!-- TEAM-CUSTOMIZE -->
4. Label every arrow with what flows and how (`"Submits timesheet [HTTPS/JSON]"`).
5. Add a short legend and a "Not shown / assumptions" list under the diagram.
6. For wiki pages, wrap the diagram in `::: mermaid` ... `:::`. For other Markdown, use a fenced `mermaid` block.

## Conventions (flowchart-based C4)

```
::: mermaid
flowchart LR
  user["<b>Employee</b><br/>[Person]<br/>Views pay and time data"]
  subgraph sys["Payroll Portal [Software System]"]
    web["<b>Web App</b><br/>[Container: Angular]<br/>UI for employees"]
    api["<b>Portal API</b><br/>[Container: ASP.NET Core, .NET 10]<br/>Business logic"]
    db[("<b>Portal DB</b><br/>[Container: SQL Server 2022]")]
    worker["<b>Pay Sync Service</b><br/>[Container: Windows service]"]
  end
  ext["<b>Payroll Engine</b><br/>[External System]"]
  bus{{"<b>Azure Service Bus</b><br/>[Queue: pay-events]"}}

  user -->|"Uses [HTTPS]"| web
  web -->|"Calls [HTTPS/JSON]"| api
  api -->|"Reads/writes [EF Core]"| db
  ext -->|"Publishes pay events"| bus
  bus -->|"Consumes"| worker
  worker -->|"Updates [EF Core]"| db

  classDef person fill:#08427b,color:#fff,stroke:#052e56
  classDef container fill:#1168bd,color:#fff,stroke:#0b4884
  classDef external fill:#999,color:#fff,stroke:#6b6b6b
  class user person
  class web,api,db,worker container
  class ext,bus external
:::
```

(The names above are placeholders showing the notation, not a description of any real system.)

## Rules
- Only draw what you found or were told. Put inferred elements in the assumptions list.
- One diagram, one level. Don't mix containers and classes on the same picture.
- Don't include server names, IP addresses, credentials or connection strings.
