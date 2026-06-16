---
goal: Human approval gate before agent execution planning
version: 1.0
date_created: 2026-06-16
last_updated: 2026-06-16
owner: Copilot Config Pack
status: 'Planned'
tags: [process, planning, agents, ux]
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

Add a two-layer planning workflow to the config pack so humans get a short plain-English checkpoint before deeper work starts, while downstream agents still receive a verbose multi-step execution plan they can follow.

## 1. Requirements & Constraints

- **REQ-001**: The first planning response shown to the user must be a short plain-English summary of the request as understood.
- **REQ-002**: The first planning response must surface uncertainty or assumptions clearly enough for the user to correct misunderstandings early.
- **REQ-003**: The first planning response must propose the smallest useful next slice of work instead of a full end-to-end implementation effort.
- **REQ-004**: The workflow must include an explicit approval or correction boundary before broad code analysis, detailed execution planning, or coding continues.
- **REQ-005**: After approval, the system must still support detailed agent-to-agent multi-step plans with enough specificity for one or more agents to execute.
- **REQ-006**: The execution plan agent must constrain its output to the approved slice rather than expanding back to the full ambiguous request.
- **CON-001**: `shared/.github/` remains the source of truth for installed configuration content.
- **CON-002**: Changes must follow the repository's custom agent and prompt conventions.
- **CON-003**: The detailed implementation plan template in `shared/.github/agents/implementation-plan.agent.md` should be preserved rather than simplified into a human-facing format.
- **CON-004**: The approval step should be explicit in the UI and should not auto-submit follow-on work without user review.
- **GUD-001**: Reuse the clarify-and-await-approval pattern already present in `shared/.github/skills/documentation-writer/SKILL.md`.
- **PAT-001**: Use agent handoffs with `send: false` to create a visible review point between the human-facing summary and downstream execution.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Turn the existing planning agent into a concise human-facing gatekeeper that stops for confirmation before deeper work begins.

| Task     | Description | Completed | Date |
| -------- | ----------- | --------- | ---- |
| TASK-001 | Rewrite `shared/.github/agents/plan.agent.md` so its primary directive is to produce a succinct human-facing checkpoint before detailed planning or coding. |  |  |
| TASK-002 | Define a fixed first-response shape in `plan.agent.md` that includes: user goal as understood, biggest uncertainty or assumption, smallest proposed next slice, and an approval/correction request. |  |  |
| TASK-003 | Add explicit guard rails in `plan.agent.md` that forbid long code analysis dumps or comprehensive plans before approval unless the user directly asks for that level of detail. |  |  |
| TASK-004 | Add handoffs in `plan.agent.md` for `Generate Execution Plan` and `Start Approved Slice`, both with `send: false` so the user can review the next action before it runs. |  |  |

### Implementation Phase 2

- GOAL-002: Preserve a detailed AI-to-AI implementation planner, but scope it to approved work and position it as an internal specialist.

| Task     | Description | Completed | Date |
| -------- | ----------- | --------- | ---- |
| TASK-005 | Update `shared/.github/agents/implementation-plan.agent.md` frontmatter to make it an internal specialist, starting with `user-invocable: false` unless testing shows direct visibility is still required. |  |  |
| TASK-006 | Add or revise opening guidance in `implementation-plan.agent.md` so it assumes a human checkpoint has already happened and that its audience is downstream agents, not the end user. |  |  |
| TASK-007 | Add scope discipline to `implementation-plan.agent.md` so it produces a full multi-step plan only for the approved slice and does not silently broaden back to the original ambiguous request. |  |  |

### Implementation Phase 3

- GOAL-003: Add an execution agent that follows the approved slice and reintroduces a human checkpoint if the work expands.

| Task     | Description | Completed | Date |
| -------- | ----------- | --------- | ---- |
| TASK-008 | Create `shared/.github/agents/implementer.agent.md` as a general implementation agent that executes only the approved slice of work. |  |  |
| TASK-009 | In `implementer.agent.md`, require the agent to stop and resummarize in plain English if it discovers the approved slice is too broad, ambiguous, or has expanded materially. |  |  |
| TASK-010 | Ensure the implementer follows existing repo conventions for validation, scoped changes, and complete execution of the approved slice. |  |  |

### Implementation Phase 4

- GOAL-004: Add a discoverable workflow entry point and verify the resulting config behaves as intended.

| Task     | Description | Completed | Date |
| -------- | ----------- | --------- | ---- |
| TASK-011 | Add `shared/.github/prompts/plan-approved-slice.prompt.md` to steer users into the human-summary-first workflow instead of directly invoking the machine-oriented planner. |  |  |
| TASK-012 | Verify all agent names, handoff references, and prompt `agent` references resolve correctly under `scripts/validate.py`. |  |  |
| TASK-013 | Smoke-test installation with `bash scripts/install.sh /tmp/copilot-config-smoke-test` and confirm the new files land under `.github/` as expected. |  |  |
| TASK-014 | Manually verify the user experience in VS Code: concise human checkpoint first, visible handoff pause, detailed execution plan available after approval, and implementation constrained to the approved slice. |  |  |

## 3. Alternatives

- **ALT-001**: Solve the problem only with a new `.instructions.md` file. Rejected because instructions alone are weaker for controlling workflow sequencing and approval checkpoints than agents and handoffs.
- **ALT-002**: Simplify `implementation-plan.agent.md` into a human-readable planner. Rejected because verbose structured plans are useful when the audience is another agent.
- **ALT-003**: Leave both planning agents directly user-facing and rely on naming alone. Rejected because it increases the chance that users enter the machine-oriented planner without the human checkpoint.

## 4. Dependencies

- **DEP-001**: `shared/.github/agents/plan.agent.md` must support VS Code handoffs correctly.
- **DEP-002**: `shared/.github/agents/implementation-plan.agent.md` must remain a valid custom agent definition after frontmatter changes.
- **DEP-003**: `shared/.github/prompts/plan-approved-slice.prompt.md` must reference a real agent name.
- **DEP-004**: `scripts/validate.py` must continue to pass with the added agent and prompt files.

## 5. Files

- **FILE-001**: `shared/.github/agents/plan.agent.md` — human-facing planning gatekeeper with approval checkpoint and handoffs.
- **FILE-002**: `shared/.github/agents/implementation-plan.agent.md` — machine-oriented execution planner constrained to approved scope.
- **FILE-003**: `shared/.github/agents/implementer.agent.md` — scoped implementation agent for approved slices.
- **FILE-004**: `shared/.github/prompts/plan-approved-slice.prompt.md` — optional entry point that steers users into the approval-first workflow.

## 6. Testing

- **TEST-001**: Run `python scripts/validate.py` and confirm the pack validates successfully.
- **TEST-002**: Run `bash scripts/install.sh /tmp/copilot-config-smoke-test` and confirm the new artifacts install into `.github/` correctly.
- **TEST-003**: In VS Code, verify that the planning agent's first response is brief, plain English, and asks for approval or correction before deeper work.
- **TEST-004**: In VS Code, verify the handoff to the implementation-plan agent does not auto-send and allows user review first.
- **TEST-005**: In VS Code, verify the implementation-plan agent can still emit a detailed multi-step plan suitable for downstream agent execution.
- **TEST-006**: In VS Code, verify the implementer stops and re-summarizes if scope expands beyond the approved slice.

## 7. Risks & Assumptions

- **RISK-001**: Setting `user-invocable: false` on `implementation-plan.agent.md` may hide a workflow some users still want direct access to.
- **RISK-002**: Handoff support depends on the user's VS Code version and may not behave the same in other environments.
- **RISK-003**: If the human-facing checkpoint is too terse, important constraints may be omitted; if too long, it recreates the original problem.
- **ASSUMPTION-001**: Users want the approval checkpoint to be visible and manual rather than automatic.
- **ASSUMPTION-002**: The repo's maintainers prefer a workflow split across specialized agents instead of one highly stateful planner/implementer agent.
- **ASSUMPTION-003**: Existing install targets consume the shared config pack in environments where custom agents and prompt files are meaningful.

## 8. Related Specifications / Further Reading

- `../shared/.github/agents/plan.agent.md`
- `../shared/.github/agents/implementation-plan.agent.md`
- `../shared/.github/skills/documentation-writer/SKILL.md`
- `../.github/instructions/agents.instructions.md`
