<!-- copilot-config-pack: joel-000/copilot-configs -->

# Repository Instructions

## Approval, commits and branch protection

- Before deeper planning or implementation, identify the goal, largest uncertainty and smallest useful slice, then obtain explicit user approval. No skill-selection result may bypass this no-edit boundary. Gate, re-review and waiver mechanics are in `agent-topology.instructions.md`.
- Implementation approval does not authorise commits, pushes or PR creation; these require explicit user authorisation. Runtime helpers inherit the approved task's permissions and restrictions without repeated approval.
- Omit AI attribution from every commit, in any workflow (no `Co-authored-by: Copilot App` or other AI co-author trailers, no AI-generated signatures), unless the user explicitly requests it for that commit. Do not change Git author identity or signing settings.
- Treat a child coding session's source branch and pre-existing uncommitted work as protected, regardless of branch name. Establish the starting Git state and keep task changes separate. Do not alter the source branch or stage, commit, discard or stash pre-existing changes without explicit user permission; ask the user if ownership is unclear.

## Maintainability

Multiple maintainers must understand the work without the conversation that produced it. Simple, readable and maintainable is the default for plans, code, tests, scripts, documentation and infrastructure. Every abstraction, helper, layer, option or file costs every future reader: the author justifies complexity; simplicity needs no defence. Judge every design decision against PEP 20 (The Zen of Python), especially: explicit over implicit; simple over complex, complex over complicated; flat over nested; readability counts; practicality beats purity; errors never pass silently unless explicitly silenced; refuse to guess; one obvious way; hard to explain means a bad idea.

Prioritise, in order:

1. Correctness against the acceptance criteria.
2. Readability for a developer unfamiliar with the change.
3. The smallest proportionate change.
4. Consistency with nearby code and repository conventions.

- Add a helper or abstraction only for a stated requirement or an established repository pattern. Leave existing code untouched unless the task requires it; no refactoring or shared helpers in it without approval. No unrelated cleanup or speculative hardening.
- Reuse existing repositories, examples and scripts; state where configuration and secrets come from rather than assuming.
- Keep each component to its own concern. A producer (test run, build step or service) emits consumer-agnostic output in a standard, documented format, such as a tool's default; each consumer relies only on that output, adapts to it and owns consumer-specific settings, such as report paths and project keys. Do not reshape a producer solely for one consumer; if the consumer genuinely cannot adapt, keep the producer-side coupling in one place and document why there.
- Simplify every plan before presenting it. Before final readiness, remove unrelated changes and unnecessary helpers, abstractions and control flow.

## Review findings

Change code for a finding only when it identifies a reachable, material in-scope risk that existing controls do not address, using the smallest repository-consistent fix. Challenge speculative, unsupported, duplicative or disproportionately complex findings; defer valid out-of-scope ones. The implementing agent owns disposition and picks the simplest remediation.

## Tests

- Test observable behaviour, not implementation details, unreachable states or hypothetical requirements. Prefer a few readable tests over exhaustive or duplicative coverage, following repository conventions; use shared fixtures, builders, helpers or parametrisation only when they reduce repetition without obscuring behaviour.
- Emulators and mocks must not add behaviour the real service lacks (name translation, injected defaults, compatibility shims); pass configuration through unchanged so tests expose real defects.
- When fixing a bug, write the failing tests first and confirm they fail for the intended reason before changing production code.

## Comments and documentation

Add comments and docstrings when they clarify purpose, non-obvious behaviour, constraints or usage, following surrounding conventions; do not restate obvious code or narrate changes. Python docstrings follow the established project style, otherwise Google style. Update documentation only when the change affects documented behaviour, interfaces, configuration or operating procedures.

## Debugging and validation

- Run project commands from the repository or its worktree, not a session-state directory; keep environments, dependencies and build outputs in repository-supported locations.
- Before changing code or setup, inspect the relevant documentation, test configuration, fixtures and Compose files. Record the working directory, exact command, relevant non-secret configuration and tool versions, and expected versus actual result.
- Reproduce with the narrowest relevant command and diagnose the failing layer. Preserve the documented test path, environments and shared services; do not replace or remove them to make a command pass.
- Before attributing a test failure to a change, run the same check on the pre-change baseline under comparable configuration and dependencies and compare the results; if no baseline is available, report regression status as unverified.
- After a fix, rerun the failing command and relevant broader checks.
- After modifying repository files, run focused tests, then relevant broader tests and static checks. Report diagnostic overrides explicitly, distinguish focused from full-suite results, and state which applicable validation stages (such as coverage generation, coverage import, analysis and quality gates) were performed, with each stage's observed outcome.
- For repeated deployed failures, gather concrete evidence (actual URLs, outputs and logs; a temporary diagnostic job is acceptable), state the cause, then propose the fix. Do not guess-fix.

## Scope

- Plan, options or analysis requests involve no code changes.
- Do not silently expand scope. When an adjacent issue is not required for the requested outcome, ask whether to include it, briefly explaining whether it predates this work, what code or behaviour it affects, any wider impact or risk, and the consequence of deferring it. Validation failures are evidence to report, not automatic permission to expand scope.
- List out-of-scope findings as follow-ups instead of fixing them.
- Do not reference scratch notes or planning documents in code, merge request descriptions or tickets.

For internal agent-to-agent status messages, review verdicts, and handoffs, lead with the current outcome and put any blocker, caveat, condition, or permission limit beside it. Use concise, grammatical English, keeping the evidence, uncertainty, and context needed to act; do not compress restrictions or approvals. Preserve verbatim user requests and other quoted text, paths, commands, and errors exactly. This does not change the requirements for complete standalone kickoff prompts or user-facing messages.
