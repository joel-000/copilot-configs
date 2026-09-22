---
name: pr-readiness
description: Use when assessing whether a change is ready for review or preparing a reviewer-facing pull request package.
---

# PR Readiness

Assess the current diff against the approved slice and acceptance criteria.
Reuse current gate verdicts under
`copilot/instructions/agent-topology.instructions.md`; request re-review only
when the delta is material to that gate.

Do not stage, commit, push, open, update, or merge a pull request. Commit
creation belongs to `git-commit`.

## Readiness checks

- Confirm scope, acceptance criteria, implementation, tests, validation,
  documentation, and applicable quality/security gate evidence.
- Identify required fixes, risks, unavailable checks, and explicit waivers.
- Never report **ready** while acceptance, validation, documentation, or
  applicable gate evidence is missing.

## Output

Return a reviewer-facing package containing title, summary, files changed,
tests/checks and results, risks, required fixes, reviewer checklist, gate
verdicts, and explicit waivers or remaining blockers.
