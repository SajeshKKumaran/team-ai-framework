# Microsoft 365 Copilot prompt packs

For team members who don't have GitHub Copilot in VS Code or the CLI yet. The prompts here produce **the same artifacts, in the same formats**, as the matching skills in `.github/skills/`, so work done in M365 Copilot today flows straight into the developer and QE workflows. When these roles get Copilot Enterprise seats, they switch to the agents and skills without changing how the team works.

| Role | Prompt pack | Matching agent and skills (later) |
|---|---|---|
| Product Manager | [product-manager.md](product-manager.md) | `product-manager` agent; `write-feature-brief`, `release-notes` |
| Project Manager | [project-manager.md](project-manager.md) | `project-manager` agent; `sprint-planning-prep`, `sprint-report`, `retro-synthesis` |
| Business Analyst | [business-analyst.md](business-analyst.md) | `business-analyst` agent; `refine-story` |

## Getting Azure DevOps data into M365 Copilot

M365 Copilot can't reach our on-prem Azure DevOps Server directly. Bring the data to it:

1. In Azure DevOps Boards, run a query (or open the sprint backlog as a query).
2. Choose the columns you need (ID, Title, State, Assigned To, Story Points, Remaining Work, Tags, Iteration, and Acceptance Criteria or Description when relevant).
3. Use **Export to CSV** from the query results menu, save it to OneDrive or SharePoint, and attach it in Copilot Chat.

For a single story, copying the title, description and acceptance criteria into the prompt is fine.

## Working tips

- **Attach, don't paste walls of text.** Use the attach button, or type `/` in Copilot Chat to reference a file, email or meeting.
- **Meeting notes:** with transcription on in Teams, Copilot can summarize refinement, planning and retro meetings; then use the prompts here on the recap.
- **Save the prompts you use often** with Copilot's save-prompt option (Prompt Gallery) so you don't copy them from this page each time, and share them with the team.
- **Iterate.** The first answer is a draft. Follow up with "make the acceptance criteria cover the permission cases", "shorter, for executives", and so on.
- **Check before you share.** You own what you send. Verify numbers against the source and remove anything Copilot invented.
- **Keep sensitive details out where you can.** Prefer synthetic examples to real employee or client records, even though M365 Copilot is an approved tool.

If your tenant allows building Copilot agents (agent builder in M365 Copilot or Copilot Studio), each prompt pack can be turned into a role agent: paste the "Agent instructions" block at the top of the pack into the agent's instructions. <!-- TEAM-CUSTOMIZE: confirm what your tenant allows -->
