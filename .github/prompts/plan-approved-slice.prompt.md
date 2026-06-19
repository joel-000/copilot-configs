---
name: plan-approved-slice
description: 'Start with a concise approval checkpoint before deeper planning or coding.'
agent: 'Plan Mode - Strategic Planning & Architecture'
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

## Scope & Preconditions

- Stop after the concise checkpoint unless the user explicitly asks for more detail.
- Do not produce a full implementation plan before approval.
- Do not start coding before approval.

## Plan Readiness Gate

- Before a detailed execution plan is treated as ready for implementation, require both Quality Review and Security Review outcomes on that plan.
- If either review is blocked, return blockers and required corrections instead of reporting the plan as ready.
- Any waiver must name the owner and accepted risk.
- Keep plans execution-first: prioritize concrete code-change steps and testing, with TDD as the default implementation model.

## Output Expectations

- Keep the first response brief and easy to scan.
- Make the approval boundary explicit.
- Stay inside the approved slice after the user confirms it.
