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
  destroy, flag replacement and destruction separately, call out irreversible
  data changes, and inspect replacement triggers and module-level changes.
- Check resource address/state stability, IAM scope, public exposure, and
  dependency effects.
- When Terraform is available and the repository context supports them, run and
  report `terraform fmt -check`, `terraform validate`, and `terraform plan`;
  otherwise report each as **not run** or **not available**.
- Require evidence for every finding: resource/address, plan evidence,
  severity, impact, and the smallest safe follow-up.
- Treat unavailable or missing Terraform commands, files, or state as **not
  run** or **not available**, never as passing.

## Output

Return blockers, risks, safe changes, evidence-backed findings, unavailable
checks, and required follow-up commands with a clear go/no-go recommendation.
