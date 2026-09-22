---
name: terraform-plan-review
description: Use when reviewing Terraform changes, Terraform plan output, or AWS infrastructure risk.
---

# Terraform Plan Review Workflow

## Review contract

- Stay read-only: never edit, apply, or approve infrastructure.
- Use `copilot/instructions/terraform.instructions.md` and
  `copilot/instructions/security-and-owasp-platform.instructions.md` for
  standards rather than copying their checklists.
- Classify every resource action as create, in-place update, replace, or
  destroy, and flag replacement and destruction separately.
- Check resource address/state stability, IAM scope, public exposure, and
  dependency effects.
- Require evidence for every finding: resource/address, plan evidence,
  severity, impact, and the smallest safe follow-up.
- Treat unavailable or missing Terraform commands, files, or state as **not
  run** or **not available**, never as passing.

## Output

Return blockers, risks, safe changes, evidence-backed findings, unavailable
checks, and required follow-up commands with a clear go/no-go recommendation.
