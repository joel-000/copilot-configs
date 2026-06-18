---
name: prepare-pr
description: Prepare a PR summary and final review.
agent: PR Review Agent
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
- Final Quality Review gate (`quality-review(final)`) is pass or explicitly waived after the latest documentation edits
- Final Security Review gate (`security-review(final)`) is pass or explicitly waived after the latest documentation edits
- Freshness evidence confirms final quality/security decisions are newer than the latest content edits

If any required precondition is missing, do not mark the PR as ready.

If a waiver is used, include all of the following in the output:

- Waiver owner
- Accepted risk
- Waiver scope
- Waiver duration or waiver timestamp