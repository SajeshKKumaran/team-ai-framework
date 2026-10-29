---
name: docs
description: Conventions for Markdown docs and Azure DevOps Wiki pages
applyTo: "docs/**/*.md,wiki/**/*.md"
---

<!-- TEAM-CUSTOMIZE: point applyTo at the folders that are published as your Azure DevOps Wiki. -->


# Docs and Azure DevOps Wiki pages

- Write for the reader who wasn't in the meeting: start with the purpose in one or two sentences, then the details.
- Mermaid diagrams on wiki pages use the Azure DevOps block syntax:

  ```
  ::: mermaid
  flowchart LR
    A --> B
  :::
  ```

- Add `[[_TOC_]]` at the top of long wiki pages.
- Wiki page titles come from file names: use `Title-With-Hyphens.md`. Control page order with a `.order` file in the folder.
- Link work items as `#<id>`.
- Keep architecture decisions in ADRs (see the `write-adr` skill) and link to them instead of repeating the reasoning.
- Don't paste secrets, server credentials, connection strings or personal data into docs.
