---
description: 'Route planning requests through planning agents and require quality/security plan review before reporting.'
applyTo: '**'
---

# Planning Agent Orchestration Rules

Use these rules whenever the user asks for planning, a plan step, architecture approach, roadmap, implementation strategy, or design breakdown.

## Mandatory Routing

1. Always delegate planning requests to `Plan Mode - Strategic Planning & Architecture` first.
2. If the user approves a slice and asks for a detailed plan, delegate to `Implementation Plan Generation Mode`.
3. Do not generate final planning output directly in the primary agent when the planning agents are available.

## Mandatory Plan Review Gates

Before reporting a detailed plan as ready:

1. Run `Quality Review Agent` on the plan.
2. Run `Security Review Agent` on the plan.
3. Report both verdicts with blockers (or explicit waivers with owner and accepted risk).

If either gate is blocked, do not present the plan as approved for implementation.
