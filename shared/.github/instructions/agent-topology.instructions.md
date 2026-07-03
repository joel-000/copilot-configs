---
description: 'Enforce the simplified agent topology: Implementer plus independent QA and Security gates.'
applyTo: '**/*.{agent.md,prompt.md,instructions.md}'
---

# Agent Topology Policy

Use this topology for workflow design and prompt routing.

## Allowed Agents

1. `Implementer`
2. `Quality Review Test Agent`
3. `Security Review Agent`

## Routing Rules

- Default all implementation, planning, and PR-prep flows to `Implementer`.
- Keep QA and Security as independent review gates only.
- Do not introduce specialist orchestration agents for planning, context building, documentation, platform delivery, or PR review.

## Gate Requirements

- Require `Quality Review Test Agent` and `Security Review Agent` review before implementation when a detailed plan exists.
- Require both review gates for implementation deltas before final readiness.
- If a gate is waived, record waiver owner, accepted risk, scope, and timestamp/expiry.
