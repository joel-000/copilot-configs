---
name: pytest-unit-test-workflow
description: Use for test-only additions, fixes, or reviews of pytest tests for Python, FastAPI, or AWS-integrated code; use tdd-red-green when production behavior also changes.
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
7. If failures occur, fix the test or fixture when the test is wrong. If the
   behaviour must change in production code, stop and hand off to
   `tdd-red-green`.
