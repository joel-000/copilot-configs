---
description: 'Route planning requests through planning agents and require quality/security plan review before reporting.'
applyTo: '**'
---

# Planning Agent Orchestration Rules

Use these rules only for planning requests, architecture discussions, roadmaps, implementation strategy, and plan breakdowns.

## Routing

1. Delegate planning requests to `Plan Mode - Strategic Planning & Architecture`.
2. After slice approval, route deeper repo discovery through `context-builder` before `Implementation Plan Generation Mode`.
3. Treat planning as analysis only until the user explicitly approves a concrete slice.

## Workflow

`plan -> context-builder -> implementation-plan -> quality-review(plan) -> security-review(plan) -> implementer -> ...`

## Required Gates

- Do not treat a detailed plan as implementation-ready until both plan reviews pass or are explicitly waived.
- Use the `Context Snapshot` as primary downstream repo context.
- Keep plans execution-first, TDD-first, and documentation-light until implementation is complete.
