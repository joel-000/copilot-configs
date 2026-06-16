---
name: terraform-plan-review
description: Use when reviewing Terraform changes, terraform plan output or AWS infrastructure risk.
---

# Terraform Plan Review Workflow

1. Identify resources added, changed and destroyed.
2. Flag destructive actions first.
3. Flag resource replacements separately from in-place updates.
4. Check IAM permissions for least privilege.
5. Check public exposure:
   - S3 public access
   - security groups
   - load balancers
   - public subnets
6. Check state/resource address stability.
7. Return:
   - blockers
   - risks
   - safe changes
   - required follow-up commands