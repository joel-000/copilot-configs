# AGENTS.md

## Big picture
- This repository is a **Copilot configuration pack**, not an application. The real payload is `copilot/`, which can be linked globally or copied into other repositories.
- Treat `copilot/` as the **source of truth**. Root files like `README.md` explain the pack; they are not what gets installed.
- The enforced pack layout is `copilot/{agents,instructions,skills}` plus `copilot/copilot-instructions.md`.
- All managed artifacts must remain compatible with both VS Code and PyCharm. Prefer shared Copilot frontmatter and Markdown conventions; do not rely on IDE-specific metadata, UI actions, or tool declarations.

## Architecture and data flow
- `scripts/repo_install.sh` copies `copilot/` into a target repository’s `.github/` directory using `rsync`.
- Default repo install mode is **safe merge**. `--prune` adds `rsync --delete` for exact mirroring, which can remove unmanaged target files.
- `scripts/global_install.sh` creates user-level symlinks for `instructions`, `agents`, `skills`, and `copilot-instructions.md` under `~/.copilot/` for VS Code and PyCharm.
- `scripts/validate.py` is the main integrity check. It validates:
  - required subdirectories exist
  - required frontmatter keys exist
  - agent handoff `agent` references resolve to a real agent `name` or agent file ID
  - duplicate agent names are not introduced
  - local `.github/` files are validated for their own frontmatter and references only (no root-vs-source mirror comparison)
- Cross-file references are string-based. Agent handoffs may target either an
  agent display `name:` or the agent filename without `.agent.md`.

## Frontmatter and file-shape conventions
- Every managed artifact starts with YAML frontmatter at the top of the file.
- Required keys by artifact type:
  - agents: `name`, `description`
  - instructions: `description`, `applyTo`
  - skills: `name`, `description`
- Keep scalar frontmatter simple and conventional. `scripts/validate.py`
  extracts fields like `name:` and handoff `agent:` values with regex, so
  unusual YAML formatting is riskier here than in parser-backed systems.
- File discovery is naming-based:
  - `copilot/agents/*.agent.md`
  - `copilot/instructions/*.instructions.md`
  - `copilot/skills/*/SKILL.md`

## Editing patterns to follow
- Make changes under `copilot/`, then validate. Do not edit an installed `.github/` or `~/.copilot/` copy and backport later.
- Do **not** add checks, tests, or workflow steps that enforce automatic synchronization between root `.github/` and `copilot/`.
- Match the existing style: short, task-focused markdown with compact rules or numbered steps. Good examples:
  - `copilot/agents/python-engineer.agent.md`
  - `copilot/skills/fastapi-endpoint-workflow/SKILL.md`
- When adding an agent, ensure `name:` is globally unique across all `copilot/agents/*.agent.md` files.
- Keep skills directory-based (`skills/<name>/SKILL.md`); agents and
  instructions are flat files in their own folders.

## Developer workflow
- Validate before and after edits:
  ```bash
  python scripts/validate.py
  ```
- Smoke-test installation after structural changes:
  ```bash
  bash scripts/repo_install.sh /tmp/copilot-config-smoke-test
  ```
- For exact-mirror behavior during a smoke test:
  ```bash
  bash scripts/repo_install.sh --prune /tmp/copilot-config-smoke-test
  ```
- Check installer usage:
  ```bash
  bash scripts/repo_install.sh --help
  bash scripts/global_install.sh --help
  ```

- Repository installation is safe-merge by default and does not remove
  already-copied `.github/prompts` files. Remove the five known legacy prompt
  files explicitly, or inspect the destination before using the repository's
  confirmed `--prune` flow.

## Project-specific gotchas
- `scripts/repo_install.sh` depends on `rsync` being available.
- In this workspace, installer scripts are **not executable**, so invoke them as `bash scripts/<script>.sh ...` unless file permissions are changed.
- There is no broader test suite or package manifest here; `scripts/validate.py` is the authoritative automated check.
- `scripts/validate.py` currently uses tab indentation internally; avoid unrelated reformatting if you modify it.
