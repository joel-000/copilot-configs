---
name: plan-approved-slice
description: 'Start with a concise approval checkpoint before deeper planning or coding.'
agent: Implementer
---

# Plan Approved Slice

## Mission

Start with the human-summary-first planning workflow.

## Workflow

1. Restate the goal in plain English.
2. Surface the biggest uncertainty or assumption.
3. Propose the smallest useful next slice.
4. Ask for approval or correction before deeper planning or coding.
5. Treat planning requests as non-approval until the user explicitly approves the slice.
6. After approval, build a compact in-session context packet for execution.
7. Keep downstream outputs compact: pass the slice, delta, and blockers instead of replaying full prior prose.

## Scope & Preconditions

- Stop after the concise checkpoint unless the user explicitly asks for more detail.
- Do not produce a full implementation plan before approval.
- Do not start coding before approval.

## Plan Readiness Gate

- Before a detailed execution plan is treated as ready for implementation, require both Quality Review and Security Review outcomes on that plan.
- Build and reuse a compact context snapshot before detailed execution planning so the same session does not repeatedly re-scan the repository.
- If either review is blocked, return blockers and required corrections instead of reporting the plan as ready.
- Follow the waiver policy in `agent-topology.instructions.md`. Do not request waiver details already established in the current conversation.
- Keep plans execution-first: prioritize concrete code-change steps and testing, with TDD as the default implementation model.
- Prefer terse stage outputs unless the work is blocked or high risk.

## Output Expectations

- Keep the first response brief and easy to scan.
- Make the approval boundary explicit.
- Stay inside the approved slice after the user confirms it.
