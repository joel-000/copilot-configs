---
description: "Pytest conventions for focused, isolated, behavior-oriented tests"
applyTo: "**/test_*.py,**/*_test.py,**/tests/**/*.py"
---

# Pytest instructions

- Use pytest idioms, not unittest-style classes unless the project already does.
- Reuse fixtures from conftest.py.
- Isolate state shared between tests, including process-global state, and restore it in fixture teardown or cleanup. Fix test-state leakage in test setup or cleanup; change production behaviour only when the test reveals a real production defect.
- Test public behaviour.
- For asynchronous or background work under test, wait for an observable completion signal with a bounded timeout rather than a fixed sleep.
- Mock external services at clear boundaries.
- Keep unit tests isolated from real AWS, databases and external HTTP services.
- Preserve integration tests that intentionally use documented local services or emulators. Classify tests by their actual dependencies, and do not bypass their fixtures or replace their service path with mocks just to obtain a passing run.
- Include negative, validation and edge cases where relevant.
