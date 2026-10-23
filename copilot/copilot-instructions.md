<!-- copilot-config-pack: joel-000/copilot-configs -->

# Repository Instructions

## Commit attribution

Omit AI attribution from every commit: no `Co-authored-by: Copilot App` or other AI co-author trailers and no AI-generated signatures, in any workflow, unless the user explicitly requests attribution for that commit. Do not change Git author identity or signing settings.

## Universal approval boundary

Before deeper planning or implementation, identify the goal, largest uncertainty and smallest useful slice, then obtain explicit user approval. No skill-selection result may bypass this no-edit boundary. Gate, re-review and waiver mechanics are in `agent-topology.instructions.md`.

## Maintainability

This repository has multiple maintainers; code must be understandable without the conversation that produced it. Prioritise, in order:

1. Correctness against the acceptance criteria.
2. Readability for a developer unfamiliar with the change.
3. Consistency with nearby code and repository conventions.
4. Maintainability and ease of future modification.
5. The smallest proportionate change.

Complexity needs demonstrated justification. Prefer direct, explicit implementations over abstractions, indirection or configuration for hypothetical requirements. Introduce a helper or abstraction only when it removes clear repetition or follows an established repository pattern. Do not do unrelated refactoring, cleanup or speculative hardening.

## Review findings

Change code for a finding only when it identifies a reachable, material risk within the current scope that existing controls do not address, and use the smallest repository-consistent fix. Challenge findings that are speculative, rely on unsupported assumptions, duplicate existing controls or need disproportionate complexity; defer valid out-of-scope findings that do not block safe completion. Reviewers define the problem or outcome; the Implementer owns disposition and chooses the simplest maintainable remediation.

## Tests

Test observable behaviour, not implementation details, unreachable states or hypothetical requirements. Follow repository conventions and prefer a few readable tests over exhaustive or duplicative coverage. Use shared fixtures, builders, helpers or parametrisation only when they reduce repetition without obscuring behaviour.

Emulators and mocks must not add behaviour the real service lacks (name translation, injected defaults, compatibility shims); pass configuration through unchanged so tests expose real defects. When fixing a bug, write the failing tests first and confirm they fail for the intended reason before changing production code.

## Comments and documentation

Comment only non-obvious constraints, decisions or behaviour; do not narrate straightforward code or preserve task-conversation context. Update documentation only when the change affects documented behaviour, interfaces, configuration or operating procedures.

## Debugging deployed failures

For repeated CI or deployed-environment failures, gather evidence first (actual URLs, outputs, logs; a temporary diagnostic job is acceptable), state the cause, then propose the fix. Do not guess-fix.

## Scope

Plan, options or analysis requests involve no code changes. List out-of-scope findings as follow-ups instead of fixing them. Do not reference scratch notes or planning documents in code, merge request descriptions or tickets.

## Validation

Agents that modify repository files run focused tests first, then the relevant broader tests and static checks. Before final readiness, the Implementer removes unrelated changes and simplifies unnecessary helpers, abstractions and control flow.
