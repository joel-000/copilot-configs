---
name: prepare-pr
description: Prepare a PR summary and final review.
agent: Implementer
---

Review the current change and prepare:

- PR title
- PR summary
- Test evidence
- Risk notes
- Reviewer checklist
- Anything that should be fixed before opening the PR

Before final readiness, verify:

- Initial Quality Review gate (`quality-review(changes)`) is pass or explicitly waived
- Initial Security Review gate (`security-review(changes)`) is pass or explicitly waived
- Documentation completion is complete or explicitly waived
- The latest Quality Review and Security Review verdicts are reused when no subsequent change materially affects the reviewed surface
- Re-review is requested only when subsequent changes materially affect behaviour, tests, configuration, dependencies, permissions, exposure or security posture

If any required precondition is missing, do not mark the PR as ready.

Follow the waiver policy in `agent-topology.instructions.md`. Do not request waiver details already established in the current conversation.

If a waiver is used, include:

### Waiver

`Waived by explicit user instruction`, followed by the waived gate or affected finding, accepted risk and scope summarised from the current conversation.
