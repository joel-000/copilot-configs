---
description: "Pytest conventions for focused, isolated, behavior-oriented tests"
applyTo: "**/test_*.py,**/*_test.py,**/tests/**/*.py"
---

# Pytest instructions

- Use pytest idioms, not unittest-style classes unless the project already does.
- Reuse fixtures from conftest.py.
- Test public behaviour.
- Mock external services at clear boundaries.
- Keep unit tests isolated from real AWS, databases and external HTTP services.
- Preserve integration tests that intentionally use documented local services or emulators. Classify tests by their actual dependencies, and do not bypass their fixtures or replace their service path with mocks just to obtain a passing run.
- Include negative, validation and edge cases where relevant.
