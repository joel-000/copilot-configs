![Project Banner](banner.png)

# Copilot Configuration Pack

Reusable GitHub Copilot configuration files that can be copied into new repositories as a starting point for prompts, instructions, agents, and skills.

## What this repository contains

The source of truth lives under `shared/.github/` and mirrors the destination layout used in target repositories.

| Path | Purpose |
| --- | --- |
| `shared/.github/agents/` | Custom agents for planning, implementation, review, testing, security, Terraform, and terminal help |
| `shared/.github/instructions/` | Reusable instruction files scoped by file type or workflow |
| `shared/.github/prompts/` | Prompt entry points wired to specific agents |
| `shared/.github/skills/` | Reusable skills for common workflows |
| `scripts/install.sh` | Installer that copies the pack into a repository |
| `scripts/validate.py` | Validation script for frontmatter, references, and layout |

## Repository layout

```text
shared/
└── .github/
	├── agents/
	├── instructions/
	├── prompts/
	└── skills/
```

## Install

By default, the installer performs a safe merge and does not delete existing files in the target repository.

```bash
./scripts/install.sh /path/to/repository
```

You can also target a `.github` directory directly:

```bash
./scripts/install.sh /path/to/repository/.github
```

If you want the target tree to exactly mirror this pack, use prune mode explicitly:

```bash
./scripts/install.sh --prune /path/to/repository
```

Show help:

```bash
./scripts/install.sh --help
```

## Validate this pack

Run the built-in validator before copying changes into other repositories:

```bash
python scripts/validate.py
```

The validator currently checks:

- expected `shared/.github/` subdirectories exist
- required frontmatter keys exist on agents, instructions, prompts, and skills
- prompt `agent` references resolve to real agent names
- duplicate agent names are not introduced

## Maintenance guidance

- Keep `shared/.github/` as the canonical source tree.
- Prefer additive installs by default; only use `--prune` when you intend to remove unmanaged target files.
- When adding a new prompt, validate that its `agent` value exactly matches an agent `name`.
- When adding a new configuration artifact, include complete frontmatter so the validator can enforce consistency.

## Recommended workflow for updates

```bash
python scripts/validate.py
./scripts/install.sh /tmp/copilot-config-smoke-test
```

Review the copied `.github/` tree in the smoke-test directory before distributing the update more broadly.
