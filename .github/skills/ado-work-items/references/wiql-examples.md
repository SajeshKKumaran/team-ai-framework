# WIQL examples

Use with `./scripts/Find-WorkItems.ps1 -Wiql "<query>"`. Only `SELECT` queries are allowed. Always keep `[System.TeamProject] = @project`. Queries that use `@CurrentIteration` are sent in the team's context automatically.

Reference: [WIQL syntax](https://learn.microsoft.com/azure/devops/boards/queries/wiql-syntax).

## Backlog and refinement

New stories without acceptance criteria (`IS EMPTY` needs Azure DevOps Server 2020 or later):

```sql
SELECT [System.Id] FROM WorkItems
WHERE [System.TeamProject] = @project
  AND [System.WorkItemType] = 'User Story'
  AND [System.State] = 'New'
  AND [Microsoft.VSTS.Common.AcceptanceCriteria] IS EMPTY
ORDER BY [Microsoft.VSTS.Common.StackRank]
```

Unestimated stories:

```sql
SELECT [System.Id] FROM WorkItems
WHERE [System.TeamProject] = @project
  AND [System.WorkItemType] = 'User Story'
  AND [System.State] IN ('New', 'Active')
  AND [Microsoft.VSTS.Scheduling.StoryPoints] = ''
```

## Sprint and delivery

Items changed in the last 7 days in the current sprint:

```sql
SELECT [System.Id] FROM WorkItems
WHERE [System.TeamProject] = @project
  AND [System.IterationPath] = @CurrentIteration
  AND [System.ChangedDate] >= @Today - 7
```

Stories resolved or closed in the current sprint (for release notes):

```sql
SELECT [System.Id] FROM WorkItems
WHERE [System.TeamProject] = @project
  AND [System.IterationPath] = @CurrentIteration
  AND [System.WorkItemType] IN ('User Story', 'Bug')
  AND [System.State] IN ('Resolved', 'Closed')
```

## Quality

Open bugs by severity:

```sql
SELECT [System.Id] FROM WorkItems
WHERE [System.TeamProject] = @project
  AND [System.WorkItemType] = 'Bug'
  AND [System.State] <> 'Closed'
ORDER BY [Microsoft.VSTS.Common.Severity], [Microsoft.VSTS.Common.Priority]
```

Bugs created in the last 30 days that carry the regression tag:

```sql
SELECT [System.Id] FROM WorkItems
WHERE [System.TeamProject] = @project
  AND [System.WorkItemType] = 'Bug'
  AND [System.CreatedDate] >= @Today - 30
  AND [System.Tags] CONTAINS 'regression'
```

Stories with no linked test cases (link query; returns links, the script lists the targets):

```sql
SELECT [System.Id] FROM WorkItemLinks
WHERE ([Source].[System.TeamProject] = @project AND [Source].[System.WorkItemType] = 'User Story' AND [Source].[System.IterationPath] = @CurrentIteration)
  AND ([System.Links.LinkType] = 'Microsoft.VSTS.Common.TestedBy-Forward')
  AND ([Target].[System.WorkItemType] = 'Test Case')
MODE (DoesNotContain)
```

## AI adoption

Everything the skill has created or edited:

```sql
SELECT [System.Id] FROM WorkItems
WHERE [System.TeamProject] = @project
  AND [System.Tags] CONTAINS 'ai-assisted'
  AND [System.ChangedDate] >= @Today - 14
```

<!-- TEAM-CUSTOMIZE: field names differ by process. Agile uses StoryPoints and StackRank; Scrum uses Effort and BacklogPriority. -->
