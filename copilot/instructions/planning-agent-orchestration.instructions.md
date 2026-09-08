---
description: 'Route planning requests through Implementer and require quality/security plan review before implementation.'
applyTo: '**/*.prompt.md'
---

# Planning Agent Orchestration Rules

Use these rules only for planning requests, architecture discussions, roadmaps, implementation strategy, and plan breakdowns.

## Routing

1. Delegate planning requests to `Implementer`.
2. Treat planning as analysis only until the user explicitly approves a concrete slice.
3. Keep planning and implementation context in the same agent session.

## Workflow

`implementer(plan) -> quality-review(plan) -> security-review(plan) -> implementer(changes) -> quality-review(changes) -> security-review(changes) -> implementer(final)`

## Required Gates

- Do not treat a detailed plan as implementation-ready until both plan reviews pass or are explicitly waived.
- Keep plans execution-first and TDD-first.
- Keep context gathering minimal and scoped to the approved slice.

## Scope Guard

- Keep this orchestration lightweight. Avoid loading this policy for unrelated source or infrastructure edits.
