---
name: improve-docker-setup
description: Improve Dockerfiles and Compose config for security, image size, and modern build practices.
agent: Platform Infrastructure Agent
---

Improve this repository's container setup.

Focus on:
1. Dockerfile best practices and modern BuildKit features where useful.
2. Multi-stage builds to reduce runtime image size.
3. Secure-by-default configuration (non-root runtime, minimal base image, least exposure).
4. Docker secrets over plain environment variables for sensitive values.
5. Docker Compose usage when multiple services or local dependencies are involved.

Return:
- Key changes made
- Security and image-size impact
- Any secret wiring required for local/CI usage
