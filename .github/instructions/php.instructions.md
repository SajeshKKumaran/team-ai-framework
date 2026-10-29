---
name: php
description: PHP 8 conventions for legacy modules
applyTo: "**/*.php"
---

# PHP 8

- These are legacy modules. Make the smallest change that meets the work item and match the existing style; don't modernize unrelated code in the same change.
- Add `declare(strict_types=1);` to new files. Use typed parameters, return types and properties.
- Follow PSR-12 formatting unless the file clearly uses another style.
- Database access only through prepared statements with bound parameters. Never concatenate user input into SQL.
- Escape output for its context (`htmlspecialchars` for HTML). Validate and sanitize all request input.
- Never log or echo personal data, secrets or stack traces to users.
- Ask before adding Composer packages (Black Duck review).

<!-- TEAM-CUSTOMIZE: framework in use (if any), test tool (PHPUnit version), autoloading conventions. -->
