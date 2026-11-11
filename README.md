![Project Banner](banner.png)

# Copilot Configuration Pack

Reusable GitHub Copilot configuration files that can be copied into new repositories as a starting point for instructions, agents, and skills.

## What this repository contains

The source of truth lives under `copilot/`. Its contents map directly to `~/.copilot/` and can also be copied into a repository's `.github/` directory.

| Path | Purpose |
| --- | --- |
| `copilot/agents/` | Implementer and independent quality, security, and readability review agents |
| `copilot/instructions/` | Reusable instruction files scoped by file type or workflow |
| `copilot/skills/` | Reusable skills for common workflows |
| `copilot/copilot-instructions.md` | Global Copilot instructions |
| `scripts/repo_install.sh` | Installer that copies the pack into a repository |
| `scripts/global_install.sh` | Installer that links the pack into the global user-level Copilot directory used by VS Code and PyCharm |
| `scripts/validate.py` | Validation script for frontmatter, references, and layout |

## Repository layout

```text
copilot/
├── agents/
├── instructions/
├── skills/
└── copilot-instructions.md
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

## Install globally

Create user-level symlinks so VS Code and PyCharm can use this repository's current Copilot config. The pack uses shared frontmatter and Markdown conventions; IDE-specific features are not required.

```bash
bash scripts/global_install.sh
```

You can override the base path and force replacement of conflicting paths:

```bash
bash scripts/global_install.sh --copilot-home /custom/copilot/home --force
```

This links:

- `~/.copilot/instructions` -> `copilot/instructions`
- `~/.copilot/agents` -> `copilot/agents`
- `~/.copilot/skills` -> `copilot/skills`
- `~/.copilot/copilot-instructions.md` -> `copilot/copilot-instructions.md`

Show help:

```bash
bash scripts/global_install.sh --help
```

## Validate this pack

Run the built-in validator before copying changes into other repositories:

```bash
python scripts/validate.py
```

The validator currently checks:

- expected `copilot/` subdirectories exist
- required frontmatter keys exist on agents, instructions, and skills
- agent handoff `agent` references resolve to real agent names or agent file IDs
- duplicate agent names are not introduced
- symlink artifacts are rejected under `copilot/`
- repository-level `.github/` agents and instructions also keep valid frontmatter and internal references

## Maintenance guidance

- Keep `copilot/` as the canonical source tree.
- Do not rely on automatic synchronization between root `.github/` and `copilot/`; root-level files are optional local artifacts.
- Prefer additive installs by default; only use `--prune` when you intend to remove unmanaged target files.
- When adding or changing an agent handoff, validate that its `agent` value matches an agent `name` or agent filename without `.agent.md`.
- When adding a new configuration artifact, include complete frontmatter so the validator can enforce consistency.
- Repository installs are safe-merge by default. During upgrade they remove
  pack-owned copies of the five legacy `.github/prompts/*.prompt.md` files plus
  `.github/instructions/prompt.instructions.md`, while preserving unrelated
  target files. Use `--prune --confirm-prune` only when you intend exact
  mirroring of the destination.

## Recommended workflow for updates

```bash
python scripts/validate.py
bash scripts/repo_install.sh /tmp/copilot-config-smoke-test
```

Review the copied `.github/` tree in the smoke-test directory before distributing the update more broadly.

## Multi-agent demo runbook

### Safe workflow order

1. Start with the Implementer approval checkpoint.
2. Confirm the approved slice before deeper planning or implementation.
3. If a detailed plan exists, obtain quality, security, and readability reviews before implementation; small tasks do not require a detailed plan.
4. Pass compact handoff packets (approved slice, plan or delta, and gate results) between stages.
5. Run `python scripts/validate.py`.
6. Run `bash scripts/repo_install.sh <smoke-test-dir>` without `--prune`.
7. Review the implementation delta with all three gates before final readiness; re-review only when a later change materially affects a gate's concerns.
8. Review the installed `.github` tree before broader rollout.

### Acceptance criteria

- [ ] **Pass:** Implementation stays within the approved slice. **Fail:** Work is broad or unscoped.
- [ ] **Pass:** Detailed plans receive all three reviews before implementation. **Fail:** Implementation starts with a required gate blocked or outstanding.
- [ ] **Pass:** Handoffs stay compact and delta-based. **Fail:** Later stages restate full prior outputs without need.
- [ ] **Pass:** All three implementation gates pass or are explicitly waived before final readiness. **Fail:** A required gate is outstanding.
- [ ] **Pass:** `python scripts/validate.py` exits successfully. **Fail:** Validator reports any error.
- [ ] **Pass:** `bash scripts/repo_install.sh <smoke-test-dir>` runs without `--prune` and completes successfully. **Fail:** Install fails or uses prune mode.
- [ ] **Pass:** Smoke-test `.github` tree is reviewed before wider rollout. **Fail:** No review checkpoint is recorded.

### Rollback note

If changes are not yet committed, use `git restore --staged --worktree README.md` to discard both staged and unstaged edits. If already committed, use `git revert <commit>` to create a safe rollback commit.
