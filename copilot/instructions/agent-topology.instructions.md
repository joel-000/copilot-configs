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
- A clear user instruction in the current chat is sufficient to waive a gate or accept or override an identified finding. Treat the user as the waiver owner. Summarise the affected gate or finding, accepted risk and scope from the conversation without inventing waiver terms. Ask only when the waiver intent or a material detail is ambiguous. A request to continue is not a waiver unless it clearly communicates that intent. Record the waiver in the completion packet.

## Review Lifecycle

- The Quality Review Test Agent may modify test files only. The Security Review Agent must remain read-only.
- When the Quality Review Test Agent modifies tests, it must return `Changes made; re-review required` rather than passing or blocking the gate.
- After a quality-review test change, the Implementer must inspect and validate the change, then request a fresh quality review before treating the gate as passed.
- Test-only review changes do not require another security review unless they reveal or accompany a material change to behaviour, configuration, dependencies, permissions, exposure or security posture.
- Request re-review when changes since the latest verdict materially affect the concerns owned by that gate.
