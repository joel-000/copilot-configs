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
| `scripts/repo_install.sh` | Installer that copies the pack into a repository |
| `scripts/pycharm_install.sh` | Installer that links the pack into user-level PyCharm Copilot directories |
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

## Install into a repository

By default, the repository installer performs a safe merge and does not delete existing files in the target repository.

```bash
bash scripts/repo_install.sh /path/to/repository
```

You can also target a `.github` directory directly:

```bash
bash scripts/repo_install.sh /path/to/repository/.github
```

If you want the target tree to exactly mirror this pack, use prune mode explicitly:

```bash
bash scripts/repo_install.sh --prune /path/to/repository
```

Show help:

```bash
bash scripts/repo_install.sh --help
```

## Install globally for PyCharm

Create user-level symlinks so all PyCharm projects immediately use this repository's current shared config.

```bash
bash scripts/pycharm_install.sh
```

You can override the base path and force replacement of conflicting paths:

```bash
bash scripts/pycharm_install.sh --copilot-home /custom/copilot/home --force
```

This links:

- `~/.copilot/instructions` -> `shared/.github/instructions`
- `~/.copilot/agents` -> `shared/.github/agents`
- `~/.copilot/prompts` -> `shared/.github/prompts`
- `~/.copilot/skills` -> `shared/.github/skills`

Show help:

```bash
bash scripts/pycharm_install.sh --help
```

## Validate this pack

Run the built-in validator before copying changes into other repositories:

```bash
python scripts/validate.py
```

The validator currently checks:

- expected `shared/.github/` subdirectories exist
- required frontmatter keys exist on agents, instructions, prompts, and skills
- agent handoff `agent` references resolve to real agent names or agent file IDs
- prompt `agent` references resolve to real agent names
- duplicate agent names are not introduced
- symlink artifacts are rejected under `shared/.github/`
- repository-level `.github/` agents, instructions, and prompts also keep valid frontmatter and internal references
- overlapping root `.github/agents/` and `.github/prompts/` files stay in sync with their `shared/.github/` source counterparts

## Maintenance guidance

- Keep `shared/.github/` as the canonical source tree.
- Treat overlapping files under root `.github/agents/` and `.github/prompts/` as local mirrors of `shared/.github/`; update the shared copy first and keep them identical.
- Prefer additive installs by default; only use `--prune` when you intend to remove unmanaged target files.
- When adding or changing an agent handoff, validate that its `agent` value matches an agent `name` or agent filename without `.agent.md`.
- When adding a new prompt, validate that its `agent` value exactly matches an agent `name`.
- When adding a new configuration artifact, include complete frontmatter so the validator can enforce consistency.

## Recommended workflow for updates

```bash
python scripts/validate.py
bash scripts/repo_install.sh /tmp/copilot-config-smoke-test
```

Review the copied `.github/` tree in the smoke-test directory before distributing the update more broadly.

## Multi-agent demo runbook

### Safe workflow order

1. Start with plan-approved-slice prompt.
2. Confirm approved slice before implementation.
3. Run `python scripts/validate.py`.
4. Run `bash scripts/repo_install.sh <smoke-test-dir>` without `--prune`.
5. Review installed `.github` tree before broader rollout.

### Acceptance criteria

- [ ] **Pass:** Prompt explicitly uses a plan-approved slice. **Fail:** Prompt is broad or unscoped.
- [ ] **Pass:** Implementation confirms the approved slice before edits. **Fail:** Work starts without scope confirmation.
- [ ] **Pass:** `python scripts/validate.py` exits successfully. **Fail:** Validator reports any error.
- [ ] **Pass:** `bash scripts/repo_install.sh <smoke-test-dir>` runs without `--prune` and completes successfully. **Fail:** Install fails or uses prune mode.
- [ ] **Pass:** Smoke-test `.github` tree is reviewed before wider rollout. **Fail:** No review checkpoint is recorded.

### Rollback note

If changes are not yet committed, use `git restore --staged --worktree README.md` to discard both staged and unstaged edits. If already committed, use `git revert <commit>` to create a safe rollback commit.
