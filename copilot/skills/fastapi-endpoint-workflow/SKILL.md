---
name: fastapi-endpoint-workflow
description: Use when creating or modifying FastAPI routes, request models, response models or endpoint tests.
---

## Prerequisites

- Identify the application entry point, router, schema, service, and test conventions before editing.
- Confirm the supported Python and FastAPI/Pydantic versions from the repository configuration.
- Check whether authentication, authorization, error handling, and dependency overrides already have shared helpers.

# FastAPI Endpoint Workflow

1. Find existing router and schema patterns.
2. Confirm auth/dependency conventions.
3. Define request and response models using existing Pydantic style.
4. Keep route handlers thin.
5. Put business logic in service modules.
6. Add tests for:
   - success response
   - validation failure
   - auth/permission failure where relevant
   - service-layer error mapping
7. Confirm OpenAPI-visible response shape where relevant.

## Validation

- Run the focused endpoint tests first.
- Run the repository's formatter, linter, and type checker when configured.
- Verify the generated OpenAPI schema or a schema-focused test when the public contract changes.

## Gotchas

- Preserve the repository's existing response envelope and exception-mapping conventions.
- Do not call external services or real AWS resources in unit tests; use existing fakes, mocks, or local emulators.
- Treat status codes, response models, and dependency requirements as part of the public API.
