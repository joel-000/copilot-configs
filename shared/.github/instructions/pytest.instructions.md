---
description: "Pytest conventions for focused, isolated, behavior-oriented tests"
applyTo: "**/test_*.py,**/*_test.py,**/tests/**/*.py"
---

# Pytest instructions

- Use pytest idioms, not unittest-style classes unless the project already does.
- Reuse fixtures from conftest.py.
- Test public behaviour.
- Mock external services at clear boundaries.
- Do not call real AWS, databases or external HTTP services in unit tests.
- Include negative, validation and edge cases where relevant.