---
name: review-terraform-plan
description: Review Terraform changes or plan output for AWS risk.
agent: Platform Infrastructure Agent
---

Review the Terraform change or plan output.

Return:
- Destructive changes
- Resource replacements
- IAM risk
- Public exposure risk
- State/resource address risk
- Missing fmt/validate/plan steps
- Final go/no-go judgement