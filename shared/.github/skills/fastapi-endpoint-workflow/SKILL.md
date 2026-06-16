---
name: fastapi-endpoint-workflow
description: Use when creating or modifying FastAPI routes, request models, response models or endpoint tests.
---

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