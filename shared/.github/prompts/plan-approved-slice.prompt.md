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
6. After approval, route deeper execution through `context-builder` before `Implementation Plan Generation Mode`.
7. Keep every downstream handoff compact: pass the slice, snapshot, delta, and blockers instead of replaying full prior prose.

## Scope & Preconditions

- Stop after the concise checkpoint unless the user explicitly asks for more detail.
- Do not produce a full implementation plan before approval.
- Do not start coding before approval.

## Plan Readiness Gate

- Before a detailed execution plan is treated as ready for implementation, require both Quality Review and Security Review outcomes on that plan.
- Build and reuse a compact `Context Snapshot` before detailed execution planning so downstream agents do not repeatedly re-scan the repository.
- If either review is blocked, return blockers and required corrections instead of reporting the plan as ready.
- Any waiver must include waiver owner, accepted risk, scoped coverage, and waiver timestamp/expiry.
- Keep plans execution-first: prioritize concrete code-change steps and testing, with TDD as the default implementation model.
- Prefer terse stage outputs unless the work is blocked or high risk.

## Output Expectations

- Keep the first response brief and easy to scan.
- Make the approval boundary explicit.
- Stay inside the approved slice after the user confirms it.
