---
description: 'OWASP-aligned platform and supply-chain security checks for infrastructure, CI workflows, container, and dependency manifest files.'
applyTo: '**/{Dockerfile,docker-compose.yml,docker-compose.yaml,compose.yml,compose.yaml,*.tf,*.tfvars,*.hcl,.github/workflows/*.yml,.github/workflows/*.yaml,package.json,package-lock.json,pnpm-lock.yaml,yarn.lock,requirements.txt,poetry.lock,Pipfile,Pipfile.lock,go.mod,go.sum,Cargo.toml,Cargo.lock,pom.xml,build.gradle,build.gradle.kts,gradle.properties,Gemfile,Gemfile.lock}'
---

# Security Standards (Platform and Supply Chain)

Apply these rules when editing infrastructure, CI/CD, and dependency manifests.

## Core Priorities

1. Prevent secret exposure.
2. Reduce runtime and build-time attack surface.
3. Keep dependency and artifact integrity verifiable.
4. Fail safely in CI/CD and deployment defaults.

## Secrets and Configuration

- Never commit plaintext credentials, API keys, private keys, or tokens.
- Keep `.env*`, key files, and cloud credentials out of version control.
- Use CI secret stores and masked variables; never echo sensitive env vars in logs.
- Avoid permissive defaults like `admin/admin`, `root/password`, or wildcard credentials.

## Dependency and Build Integrity

- Commit and maintain lockfiles; keep lockfiles in sync with manifests.
- Prefer pinned versions for production dependencies and base images.
- Run vulnerability scanning (`npm audit`, `pip-audit`, `cargo audit`, or stack-equivalent) for changed manifests.
- Treat new dependencies with postinstall scripts or unclear provenance as high-risk until reviewed.

## Container Security

- Use minimal, pinned base images.
- Run as non-root unless explicitly justified.
- Avoid exposing unnecessary ports and capabilities.
- Avoid copying secrets into images or baking credentials into build args.

## Terraform and IaC Safety

- Do not commit state files or local override files containing secrets.
- Use least-privilege IAM and explicit network boundaries.
- Require plan-first review for destructive or replacement changes.
- Prefer explicit encryption-at-rest and secure transport defaults.

## CI/CD Workflow Safety

- Restrict token permissions to minimum required scopes.
- Pin third-party actions by immutable commit SHA where possible.
- Guard production deployments with branch/environment protection and approvals.
- Ensure workflows fail closed: do not silently continue on security-critical failures.

## OWASP Mapping

- **A02 Security Misconfiguration**: unsafe defaults, missing hardening, broad permissions
- **A03 Supply Chain Failures**: unverified dependencies, weak provenance, unpinned inputs
- **A04 Cryptographic Failures**: secrets handling and insecure key management
- **A08 Data/Software Integrity Failures**: unsigned/unverified artifacts, weak pipeline trust
- **A09 Logging and Alerting Failures**: leaking secrets in logs or missing security event visibility
