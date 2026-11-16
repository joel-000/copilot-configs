---
name: pr-readiness
description: Use when assessing whether a change is ready for review or preparing a reviewer-facing pull request package.
---

# PR Readiness

Assess the current `git status`, including untracked files, and the current
diff against the approved slice and acceptance criteria.
Reuse current gate verdicts under
`../../instructions/agent-topology.instructions.md`; request re-review only
when the delta is material to that gate.

Do not stage, commit, push, open, update, or merge a pull request. Commit
creation belongs to `git-commit`.

## Readiness checks

- Confirm scope, acceptance criteria, implementation, tests, applicable
  validation and documentation evidence, and quality/security gate evidence.
- Identify required fixes, risks, unavailable checks, and explicit waivers.
- Require documentation evidence only when documentation is applicable or
  affected. Never report **ready** while acceptance, applicable validation,
  applicable documentation evidence, or applicable gate evidence is missing.

## Output

Return two clearly separate parts: a **PR draft** and a **readiness
assessment**. State the readiness verdict explicitly.

### PR draft

- **Title:** Prefix the actual ticket key when one exists; never invent a key.
  Use the ticket name only when it accurately describes the change. Otherwise,
  follow the key with a concise change summary. Without a ticket, use a concise,
  specific summary.
- **Description:** Use these headings:
  - **What:** Describe the change and its scope.
  - **Why:** Explain the problem or motivation.
  - **How:** Summarize the approach.
  - **Testing:** List tests and checks with their results. Include documentation
    evidence only when documentation is applicable or affected.
  - **Anything Else:** Add relevant context not covered above; omit this section
    when there is nothing useful to add.

### Readiness assessment

Keep the readiness verdict, changed files, risks, required fixes, reviewer
checklist, gate verdicts, waivers, and blockers outside the PR draft.
