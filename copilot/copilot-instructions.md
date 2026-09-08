# Repository Instructions

## Maintainability

This repository is maintained by multiple developers. Code must be understandable without access to the task conversation that produced it.

Prioritise, in order:

1. Correctness against the acceptance criteria.
2. Readability for a developer unfamiliar with the change.
3. Consistency with nearby code and repository conventions.
4. Maintainability and ease of future modification.
5. The smallest proportionate change.

Complexity is a maintenance cost and requires demonstrated justification.

Prefer direct, explicit implementations over abstractions, indirection or configuration for hypothetical future requirements.

Introduce a helper or abstraction only when it removes clear repetition or follows an established repository pattern.

Do not perform unrelated refactoring, cleanup or speculative hardening.

## Review Findings

A review finding warrants changes only when it identifies a reachable, material risk within the current scope that existing controls do not address.

Resolve accepted findings with the smallest repository-consistent change that achieves the required outcome.

Challenge findings that are speculative, depend on unsupported assumptions, duplicate existing controls or require disproportionate complexity.

Defer valid findings that fall outside the approved scope and do not block safe completion.

Reviewers define the problem or required outcome. The Implementer owns finding disposition and chooses the simplest maintainable remediation.

## Tests

Test observable behaviour rather than implementation details, unreachable states or hypothetical requirements.

Follow existing repository conventions. Prefer a small number of readable tests over exhaustive or duplicative coverage.

When modifying tests, use shared fixtures, builders, helpers or parametrisation only when they clearly reduce repetition without obscuring behaviour.

## Comments and Documentation

Write comments only for non-obvious constraints, decisions or behaviour. Do not narrate straightforward code or preserve task-conversation context.

Update documentation only when the change affects documented behaviour, interfaces, configuration or operating procedures.

## Validation

Agents that modify repository files must run focused tests first, followed by the relevant broader tests and static checks.

Before final readiness, the Implementer must remove unrelated changes and simplify unnecessary helpers, abstractions and control flow.
