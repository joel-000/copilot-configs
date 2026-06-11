---
name: tdd-red-green
description: "Use when practicing TDD with pytest and Hypothesis, test-first development, red-green-refactor, or when you want the agent to write an adversarial failing test first and then the minimum defensive code needed to make it pass."
argument-hint: "Describe the behavior, bug fix, or feature to implement with TDD"
---

# TDD Red-Green Skill

Use this skill to implement a change with **pytest** and **Hypothesis** by following a strict test-first loop:

1. **Red**: prefer adding exactly one new focused, adversarial test that expresses the next behavior and tries to break the implementation. Only modify an existing test when the behavior being specified is truly the same behavior and a new test would be redundant.
2. Run the smallest relevant test scope and confirm it fails for the expected reason.
3. **Green**: change production code as little as possible to make that test pass, using defensive logic that handles invalid, boundary, and surprising inputs explicitly. Do not change tests during green.
4. Re-run the same narrow test scope until it passes.
5. **Refactor** only if the code or test clearly needs cleanup, and keep the test green.

## Operating Rules

- Prefer one small TDD cycle at a time over batching multiple behaviors together.
- Start by identifying the existing pytest layout, fixtures, markers, and commands already used in the repository.
- Write tests in pytest style and prefer pytest-native assertions, fixtures, and parametrization.
- Reuse existing test helpers, fixtures, and patterns before adding new ones.
- Prefer adding new tests over expanding old tests to carry more behavior; grow the suite outward so coverage increases across unit, integration, and higher-level app behavior where practical.
- Keep simple tests simple. If an existing test originally verified one narrow behavior, preserve that focus unless it absolutely must change to stay correct.
- Prefer fixtures for setup and dependency wiring instead of inline setup duplication.
- Use `@pytest.mark.parametrize` when the same behavior should hold across a small, explicit matrix of examples.
- Use Hypothesis strategies and `@given(...)` to probe edge cases, weird inputs, boundary values, and invariants.
- Keep Hypothesis tests purposeful: target behavior that benefits from broad input exploration rather than using property-based testing mechanically everywhere.
- When practical, refactor tests for efficiency by extracting fixtures, consolidating repeated setup, and using parametrization, but do that without changing what each existing test fundamentally proves.
- Make the failure meaningful: the first failing test should fail because the behavior is missing or wrong, not because of unrelated setup issues.
- Write the narrowest possible test that proves the requested behavior while still being adversarial in the red step.
- Only mock true external endpoints or boundaries such as network calls, third-party APIs, or external services.
- Prefer real code paths, real collaborators, and real data transformations whenever the code can run locally and deterministically.
- Implement the minimum production change needed for green; avoid speculative refactors or extra features during the green step.
- Do not edit, weaken, delete, or broaden tests in the green step; once red is established, green is production-code-only.
- In the green step, prefer defensive code over optimistic code: validate assumptions, handle edge cases explicitly, and fail clearly when inputs are invalid.
- If the baseline is already failing, stop and explain that TDD progress is blocked until the relevant baseline is understood.
- If the requested change is too large for one cycle, break it into the next smallest observable behavior and complete the first slice.

## Procedure

1. Read the user request and restate it as the next observable behavior.
2. Inspect the repo to find the relevant source file, pytest test file, fixtures, and existing command for targeted test execution.
3. Prefer adding one new focused failing pytest test, using fixtures and parametrization where appropriate, instead of broadening an existing simple test.
4. When the behavior has meaningful edge cases or invariants, add or adapt a Hypothesis test to explore them.
5. Run only the smallest relevant test target.
6. Confirm the test fails for the intended reason.
7. Update production code with the smallest possible defensive change, without modifying the failing test.
8. Re-run the same targeted test until it passes.
9. If needed, do a tiny refactor and keep the same test target green.
10. Report the behavior added, the pytest or Hypothesis test introduced, and the minimum defensive code change that made it pass.

## Response Style

- Be explicit about which step is happening: red, green, or refactor.
- Treat **red** as adversarial: prefer a new test that probes failure modes, malformed inputs, and edge conditions.
- Treat **green** as defensive: add the smallest robust protection that satisfies the existing test without changing it.
- Keep edits small and behavior-focused.
- Prefer targeted pytest runs while iterating; use broader test commands only when needed by the repository workflow.
