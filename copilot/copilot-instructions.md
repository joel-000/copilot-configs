<!-- copilot-config-pack: joel-000/copilot-configs -->

# Repository Instructions

## Commit attribution

Omit AI attribution from every commit: no `Co-authored-by: Copilot App` or other AI co-author trailers and no AI-generated signatures, in any workflow, unless the user explicitly requests attribution for that commit. Do not change Git author identity or signing settings.

## Universal approval boundary

Before deeper planning or implementation, identify the goal, largest uncertainty and smallest useful slice, then obtain explicit user approval. No skill-selection result may bypass this no-edit boundary. Gate, re-review and waiver mechanics are in `agent-topology.instructions.md`.

## Maintainability

This repository has multiple maintainers; code must be understandable without the conversation that produced it. Simple, readable and maintainable is the default for plans, code, tests, scripts, documentation and infrastructure. Every abstraction, helper, layer, option or file is a cost to every future reader: the author justifies complexity, simplicity needs no defence. Judge every design decision against PEP 20:

```text
The Zen of Python, by Tim Peters

Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently.
Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Although that way may not be obvious at first unless you're Dutch.
Now is better than never.
Although never is often better than *right* now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
```

Prioritise, in order:

1. Correctness against the acceptance criteria.
2. Readability for a developer unfamiliar with the change.
3. The smallest proportionate change.
4. Consistency with nearby code and repository conventions.

Add a helper or abstraction only for a stated requirement or an established repository pattern. Leave existing code untouched unless the task requires it; no refactoring or shared helpers in it without approval. Reuse existing repositories, examples and scripts, and state where configuration and secrets come from rather than assuming. No unrelated cleanup or speculative hardening.

## Review findings

Change code for a finding only when it identifies a reachable, material in-scope risk that existing controls do not address, using the smallest repository-consistent fix. Challenge speculative, unsupported, duplicative or disproportionately complex findings; defer valid out-of-scope ones. The Implementer owns disposition and picks the simplest remediation.

## Tests

Test observable behaviour, not implementation details, unreachable states or hypothetical requirements. Prefer a few readable tests over exhaustive or duplicative coverage, following repository conventions. Use shared fixtures, builders, helpers or parametrisation only when they reduce repetition without obscuring behaviour.

Emulators and mocks must not add behaviour the real service lacks (name translation, injected defaults, compatibility shims); pass configuration through unchanged so tests expose real defects. When fixing a bug, write the failing tests first and confirm they fail for the intended reason before changing production code.

## Comments and documentation

Comment only non-obvious constraints, decisions or behaviour; do not narrate straightforward code or preserve task-conversation context. Update documentation only when the change affects documented behaviour, interfaces, configuration or operating procedures.

## Debugging deployed failures

For repeated CI or deployed-environment failures, gather evidence first (actual URLs, outputs, logs; a temporary diagnostic job is acceptable), state the cause, then propose the fix. Do not guess-fix.

## Scope

Plan, options or analysis requests involve no code changes. List out-of-scope findings as follow-ups instead of fixing them. Do not reference scratch notes or planning documents in code, merge request descriptions or tickets.

## Validation

Agents that modify repository files run focused tests first, then the relevant broader tests and static checks. The Implementer simplifies every plan before presenting it, and before final readiness removes unrelated changes and unnecessary helpers, abstractions and control flow.
