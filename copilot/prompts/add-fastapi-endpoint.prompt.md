---
name: add-fastapi-endpoint
description: Add a FastAPI endpoint following repository conventions.
agent: Implementer
---

Plan and deliver a FastAPI endpoint change using the full workflow.

Steps:
1. Start with the approval checkpoint (goal, uncertainty, smallest slice, explicit approval request).
2. After approval, generate a scoped execution plan for the endpoint change with TDD as default.
3. Run `quality-review(plan)` and `security-review(plan)`; do not start implementation until both pass or are explicitly waived under `agent-topology.instructions.md`.
4. After plan gates pass, implement the approved slice with TDD (`failing test -> implementation -> pass/refactor`).
5. Continue normal post-change gates and scoped documentation updates.
