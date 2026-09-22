---
name: fastapi-endpoint-workflow
description: Use when creating or modifying FastAPI routes, request models, response models, or endpoint tests.
---

## Prerequisites

- Identify the application entry point, router, schema, service, and test conventions before editing.
- Confirm the supported Python and FastAPI/Pydantic versions from the repository configuration.
- Check whether authentication, authorization, error handling, and dependency overrides already have shared helpers.

# FastAPI Endpoint Workflow

## Approval and planning

- State the goal, largest uncertainty, smallest useful slice, and wait for
  explicit approval before deeper planning or edits, following the
  Implementer policy.
- For a material change, provide a compact plan and use the review gates in
  `copilot/instructions/agent-topology.instructions.md`.
- Do not implement a material change until the required review gates pass or
  are explicitly waived.

## Workflow

1. Find existing router, schema, service, dependency, and test patterns.
2. Confirm supported Python/FastAPI/Pydantic versions and auth conventions.
3. Define request and response models using the repository's Pydantic style.
4. Keep route handlers thin and put business logic in service modules.
5. Prefer a red-green-refactor loop where practical.
6. Add tests for:
   - success response
   - validation failure
   - auth/permission failure where relevant
   - service-layer error mapping
7. Confirm status codes, response envelopes, and OpenAPI-visible response
   shape where relevant.
8. Update endpoint documentation when the public contract or usage changes.

## Validation

- Run the focused endpoint tests first.
- Run the repository's formatter, linter, and type checker when configured.
- Verify the generated OpenAPI schema or a schema-focused test when the public contract changes.
- Run the applicable quality and security gates after implementation; use the
  topology instruction for re-review and waiver semantics.

## Completion

Return a compact packet with the approved slice, files changed, tests and
checks run, OpenAPI/documentation impact, gate verdicts, risks, and follow-ups.

## Gotchas

- Preserve the repository's existing response envelope and exception-mapping conventions.
- Do not call external services or real AWS resources in unit tests; use existing fakes, mocks, or local emulators.
- Treat status codes, response models, and dependency requirements as part of the public API.
