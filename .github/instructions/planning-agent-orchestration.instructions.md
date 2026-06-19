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
4. Treat a planning request as a request for analysis only, not implementation approval. Require explicit user approval of a concrete slice before coding starts.

## Mandatory Plan Review Gates

Before reporting a detailed plan as ready:

1. Run `Quality Review Agent` on the plan.
2. Run `Security Review Agent` on the plan.
3. Report both verdicts with blockers (or explicit waivers with owner and accepted risk).

If either gate is blocked, do not present the plan as approved for implementation.

## Execution and Testing Priority

1. Plans must prioritize code changes and validation over governance documentation.
2. Default implementation strategy is Test Driven Development (TDD): define failing tests first, then implement, then pass/refactor.
3. Keep documentation work scoped to directly impacted docs and schedule it after implementation and change-level quality/security review.
