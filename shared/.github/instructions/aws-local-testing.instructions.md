---
description: "Guidance for local AWS testing with Moto or MiniStack across Python, Terraform, and supporting scripts"
applyTo: "**/*.{py,tf,yml,yaml,sh,md}"
---

# AWS local testing path-specific instructions

Apply these instructions when editing Python AWS code, Terraform, Docker Compose, CI, shell scripts, or tests related to Moto, MiniStack, boto3, Lambda, S3, SQS, SNS, DynamoDB, Batch, EventBridge, API Gateway or IAM.

## Local AWS testing principles

- Keep application code environment-neutral.
- Use configuration to switch between local MiniStack and real AWS.
- Use Moto for fast in-process Python tests.
- Use MiniStack for endpoint-based integration tests.
- Prevent accidental calls to real AWS during local tests.

## Python rules

- Create boto3 clients/resources through the repository's AWS client factory.
- If no factory exists, create one in the existing infrastructure/config module.
- Read optional endpoint overrides from environment variables.
- Never hard-code `http://localhost:4566` in production modules.
- Never read production AWS profile names in tests.
- Use pytest fixtures and `monkeypatch` for test environment setup.

## Moto rules

- Use `from moto import mock_aws`.
- Start Moto before boto3 clients/resources are created.
- Set dummy AWS credentials.
- Create buckets, tables, queues and other resources explicitly in fixtures.
- Keep tests isolated and deterministic.

## MiniStack rules

- Use endpoint config such as `AWS_ENDPOINT_URL=http://localhost:4566`.
- Use dummy credentials.
- Prefer Docker Compose or test setup scripts for repeatable startup.
- Use Terraform/provider endpoint overrides only in local configuration.
- Ensure the same application code runs against real AWS when endpoint variables are absent.

## Terraform rules

- Do not fork infrastructure definitions unnecessarily for local mode.
- Keep local endpoint/provider overrides separate from production variables.
- Prefer variables, workspaces, backend config and CI env vars over duplicated `.tf` files.
- Ensure local names and ARNs mimic AWS shape where practical.

## Test markers

If adding pytest markers, prefer:

- `@pytest.mark.aws_moto`
- `@pytest.mark.aws_local`
- `@pytest.mark.ministack`
- `@pytest.mark.aws_live`

Live AWS tests must be explicitly marked and must not run by default.
