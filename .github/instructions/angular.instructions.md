---
name: angular
description: Angular and TypeScript conventions
applyTo: "**/*.ts,**/*.html,**/*.scss,**/angular.json"
---

# Angular and TypeScript

- Check `package.json` for the Angular version first, and use the idioms that version supports (for example standalone components and signals only where the version and the existing code use them). Match the surrounding code.
- Use strict TypeScript typing. No `any` unless there's no reasonable alternative, and explain it when you use it.
- Components stay thin: presentation and user interaction only. Put HTTP calls, state and business rules in services.
- Unsubscribe from observables (`takeUntilDestroyed`, `async` pipe, or the pattern the project already uses). No nested subscriptions.
- Use the project's existing HTTP interceptors for auth and error handling. Don't call APIs with hard-coded URLs; use environment configuration.
- Accessibility: semantic HTML, labels on form controls, keyboard navigation, sufficient color contrast.
- Never put secrets, tokens or personal data in front-end code, local storage or console logs.
- Tests: component and service tests next to the source as `*.spec.ts`, using the project's existing test runner and helpers.

<!-- TEAM-CUSTOMIZE: state management library, UI component library, folder structure, lint rules. -->
