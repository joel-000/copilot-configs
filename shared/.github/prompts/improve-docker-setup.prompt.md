---
name: improve-docker-setup
description: Improve Dockerfiles and Compose config for security, image size, and modern build practices.
agent: 'Plan Mode - Strategic Planning & Architecture'
---

Plan and deliver container setup improvements using the full workflow.

Focus during planning and implementation:
1. Dockerfile best practices and modern BuildKit features where useful.
2. Multi-stage builds to reduce runtime image size.
3. Secure-by-default configuration (non-root runtime, minimal base image, least exposure).
4. Docker secrets over plain environment variables for sensitive values.
5. Docker Compose usage when multiple services or local dependencies are involved.

Workflow requirements:
1. Start with approval checkpoint and explicit slice sign-off.
2. Generate a scoped execution plan with TDD-style validation defaults where supported.
3. Run `quality-review(plan)` and `security-review(plan)` before implementation; require both pass or explicit waivers (owner + accepted risk).
4. After plan gates pass, ask the user to switch to Platform Infrastructure Agent for approved implementation.
