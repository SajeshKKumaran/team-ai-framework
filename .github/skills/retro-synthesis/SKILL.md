---
name: retro-synthesis
description: Turn raw retrospective notes, sticky notes or a meeting transcript into grouped themes, root-cause hypotheses and a short list of owned, measurable actions, and check last retro's actions. Use after a retrospective or to prepare one.
argument-hint: "[paste notes or point to a file]"
---

# Retrospective synthesis

## Steps
1. Read the notes the user provides. If they include last sprint's action items, check each one: done, in progress, dropped (and why).
2. Group notes into 3-6 themes. Name each theme as a problem or strength, not a category ("Stories arrive in sprint without test cases", not "Testing").
3. For each problem theme, propose one or two root-cause **hypotheses**, labelled as hypotheses for the team to confirm.
4. Propose at most three actions. Each must be specific, have an owner role (the team assigns the person), a due date or sprint, and a way to tell if it worked.
5. Note anything the team can't fix alone (an escalation) separately.
6. If the sprint data helps (carry-over, blocked time), pull it with `Get-SprintItems.ps1 -Timeframe past` and cite it.

## Output

```markdown
# Retro: <sprint>

## Last retro's actions
| Action | Status | Note |

## Themes
### <Theme> (<n> notes)
- What we heard: <short paraphrase>
- Possible causes (to confirm): …

## Went well - keep doing
- …

## Proposed actions (pick up to 3)
| Action | Owner (role) | By | How we'll know it worked |

## Escalations
- …
```

## Rules
- Paraphrase. Don't attribute comments to named individuals, even if names appear in the notes.
- No blame. Describe systems and process, not people.
- Fewer, better actions. Three finished actions beat ten forgotten ones.
