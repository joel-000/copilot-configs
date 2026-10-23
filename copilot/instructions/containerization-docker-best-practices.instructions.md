---
applyTo: '**/Dockerfile,**/Dockerfile.*,**/*.dockerfile,**/docker-compose*.yml,**/docker-compose*.yaml,**/compose*.yml,**/compose*.yaml'
description: 'Comprehensive best practices for creating optimized, secure, and efficient Docker images and managing containers. Covers multi-stage builds, image layer optimization, security scanning, and runtime best practices.'
---

# Containerization & Docker Best Practices

Guide developers toward optimized, secure, reproducible images and containers.

## Principles

- **Immutability:** Never modify running containers; build a new image per change. Pin dependency versions, use meaningful or semantic tags (`latest` for development only), and roll back by switching tags.
- **Portability:** Keep images self-contained and environment-agnostic. Externalize configuration through environment variables with sensible defaults, validate it at startup, and use multi-platform base images when targeting several architectures.
- **Isolation:** One primary process per container. Use container networks rather than host networking, set resource limits, and prefer named volumes over bind mounts for persistent data.
- **Small images:** Use multi-stage builds and minimal base images by default. Leave build tools, debugging utilities and dev dependencies out of production images.

## Dockerfile

1. **Multi-stage builds.** Use them for compiled languages and for Node.js/Python when build tools are heavy. Name stages (`AS build`, `AS test`, `AS production`) and copy only needed artifacts with `COPY --from=<stage>`.
2. **Base image.** Use official, minimal, version-pinned images (`alpine`, `slim`, `distroless`). Never `latest` in production, and update base images regularly for security patches.
3. **Layers.** Order instructions from least to most frequently changing (dependency manifests before source). Combine related `RUN` commands and clean up in the same layer (`rm -rf /var/lib/apt/lists/*`).
4. **`.dockerignore`.** Always maintain one. Exclude `.git`, `node_modules`/`vendor`/`__pycache__` installed in the image, build artifacts, `.env*`, logs, coverage, IDE and OS files, docs and tests.
5. **`COPY`.** Use specific paths, not `COPY . .`, and copy dependency files before source for caching.
6. **User and port.** Create a dedicated non-root user, set ownership, switch with `USER` early, and document the port with `EXPOSE`.
7. **`CMD`/`ENTRYPOINT`.** Use exec form (`["cmd", "arg"]`) for signal handling. `ENTRYPOINT` is the executable and `CMD` its default arguments.
8. **Configuration.** Use `ENV` for overridable defaults and `ARG` for build-time values. Never hardcode secrets in `ENV` or `ARG`.

```dockerfile
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY src/ ./src/
RUN npm run build

FROM node:18-alpine AS production
WORKDIR /app
ENV NODE_ENV=production PORT=3000
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1
CMD ["node", "dist/main.js"]
```

## Security

- **Non-root:** Always define a non-root `USER` with minimum permissions.
- **Minimal images:** Prefer `alpine`/`slim`/`distroless`; scan base images regularly.
- **Scanning in CI:** Lint Dockerfiles with `hadolint`, scan images with Trivy, Clair or Snyk Container, fail builds on critical vulnerabilities in base images, and rescan registry images.
- **Signing:** Sign and verify production images (Cosign, Notary or Docker Content Trust) and enforce trust policies.
- **Capabilities and filesystem:** Run with `--cap-drop=ALL --security-opt=no-new-privileges`, add back only what is needed, and use a read-only root filesystem and read-only mounts where possible. Apply seccomp/AppArmor/SELinux profiles when available.
- **Secrets:** Never put secrets in image layers (deleted files remain in history). Inject them at runtime (environment, mounted files, Docker/Kubernetes secrets, Vault), keep build-time secrets out of the final image with multi-stage builds, and scan images for leaked secrets.
- **Health checks:** Define `HEALTHCHECK` (lightweight, specific to the application); use liveness and readiness probes in orchestrators.

## Runtime and orchestration

- **Resource limits:** Set CPU/memory limits and reservations (Compose `deploy.resources`, Kubernetes requests and limits) and tune from monitoring.
- **Logging:** Write to `STDOUT`/`STDERR`, use structured (JSON) logs, aggregate centrally (Fluentd, Logstash, Loki) and set rotation and retention.
- **Storage:** Use volumes or persistent volumes for stateful data; never rely on the writable layer. Back up persistent data.
- **Networking:** Use custom networks to isolate tiers (`internal: true` for backend-only networks) and Kubernetes network policies for pod-to-pod control.
- **Orchestration:** Use Kubernetes for complex or large-scale deployments, with rolling updates, self-healing, service discovery and resource management.

```yaml
services:
  app:
    image: myapp:1.2.3
    networks: [backend]
    deploy:
      resources:
        limits: { cpus: '0.5', memory: 512M }
        reservations: { cpus: '0.25', memory: 256M }
    volumes:
      - app_data:/app/data

networks:
  backend:
    internal: true

volumes:
  app_data:
```

## Review checklist

- [ ] Multi-stage build where applicable
- [ ] Minimal, version-pinned base image
- [ ] Optimized layers with same-layer cleanup
- [ ] Comprehensive `.dockerignore`
- [ ] Specific, minimal `COPY` instructions
- [ ] Non-root `USER` and documented `EXPOSE`
- [ ] Correct `CMD`/`ENTRYPOINT` (exec form)
- [ ] Configuration via environment variables; no secrets in layers
- [ ] `HEALTHCHECK` defined
- [ ] Hadolint and image scanning in CI

## Troubleshooting

- **Large image:** inspect with `docker history <image>`, use multi-stage builds, a smaller base, and clean up in `RUN`.
- **Slow build:** order instructions for caching, use `.dockerignore`, try `--no-cache` to diagnose cache problems.
- **Container crashes:** check `CMD`/`ENTRYPOINT`, `docker logs <container>`, missing dependencies in the final image, and resource limits.
- **Permissions:** verify file ownership, `USER` permissions and mounted volume permissions.
- **Network:** verify `EXPOSE` and published ports (`-p`), the container network configuration and firewall rules.
