---
description: "Baseline Python implementation guidance for readable, testable, typed code"
applyTo: "**/*.py"
---

# Python instructions

- Use modern Python typing.
- Prefer explicit, readable code over clever abstractions.
- Keep side effects at boundaries.
- Avoid global mutable state.
- Structure code so business logic can be unit tested without AWS or HTTP calls.
- Use existing logging conventions.
