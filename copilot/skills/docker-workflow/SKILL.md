---
name: docker-workflow
description: Use when improving Dockerfiles, Compose files, image size, build reliability, runtime configuration, or container security.
---

# Docker Workflow

1. Inspect Dockerfiles, Compose files, ignore files, build scripts, runtime
   conventions, and existing repository checks before proposing changes.
2. State the goal, largest uncertainty, smallest useful slice, and wait for
   explicit approval before deeper planning or edits.
3. For a material plan, follow the review gates in
   `copilot/instructions/agent-topology.instructions.md`.
4. Make the smallest change that addresses the approved slice. Apply the
   Docker standards in
   `copilot/instructions/containerization-docker-best-practices.instructions.md`
   and platform-security guidance in
   `copilot/instructions/security-and-owasp-platform.instructions.md`.
5. Run the smallest available relevant build, configuration, lint, or runtime
   checks, and report unavailable checks as not run.
6. Run applicable quality and security gates, using topology policy for
   re-review and waivers.

Return the approved slice, files changed, checks and results, security or
runtime risks, gate verdicts, and follow-ups. Do not duplicate the linked
instruction checklists.
