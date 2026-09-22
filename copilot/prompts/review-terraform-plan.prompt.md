---
name: review-terraform-plan
description: Review Terraform changes or plan output for AWS risk.
agent: Implementer
---

# Review Terraform Plan

## Scope

Review the supplied Terraform diff or plan output. Do not modify infrastructure files.

## Workflow

1. Identify resources added, changed, replaced, and destroyed.
2. Prioritize destructive actions and irreversible data changes.
3. Check IAM permissions and public exposure for least-privilege and secure defaults.
4. Check state addresses, module changes, and replacement triggers.
5. Confirm whether formatting, validation, and plan commands were run.

## Output

Return:
- Destructive changes
- Resource replacements
- IAM risk
- Public exposure risk
- State/resource address risk
- Missing fmt/validate/plan steps
- Final go/no-go judgement

For each finding, include the affected resource, evidence from the diff or plan, severity, and the smallest safe follow-up.

## Validation

If command execution is available, run the narrowest relevant checks:

```bash
terraform fmt -check
terraform validate
terraform plan
```

Report commands that could not run and why. Do not treat an unavailable command as a passing check.
