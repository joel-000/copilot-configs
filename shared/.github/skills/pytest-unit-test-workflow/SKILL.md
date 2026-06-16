---
name: pytest-unit-test-workflow
description: Use when adding, fixing or reviewing pytest tests for Python, FastAPI or AWS-integrated code.
---

# Pytest Unit Test Workflow

1. Identify the public behaviour being tested.
2. Locate existing tests and fixtures.
3. Reuse existing fixture style.
4. Avoid real AWS, databases and network calls.
5. Add focused tests for:
   - success path
   - validation errors
   - expected exceptions
   - boundary cases
6. Run the narrowest pytest command first.
7. If failures occur, fix the implementation or test based on behaviour, not snapshots of internals.