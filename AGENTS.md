# AGENTS.md

## Big picture
- This repository is a **Copilot configuration pack**, not an application. The real payload is `copilot/`, which can be linked globally or copied into other repositories.
- Treat `copilot/` as the **source of truth**. Root files like `README.md` explain the pack; they are not what gets installed.
- The enforced pack layout is `copilot/{agents,instructions,prompts,skills}` plus `copilot/copilot-instructions.md`.

## Architecture and data flow
- `scripts/repo_install.sh` copies `copilot/` into a target repository’s `.github/` directory using `rsync`.
- Default repo install mode is **safe merge**. `--prune` adds `rsync --delete` for exact mirroring, which can remove unmanaged target files.
- `scripts/global_install.sh` creates user-level symlinks for `instructions`, `agents`, `prompts`, `skills`, and `copilot-instructions.md` under `~/.copilot/` for VS Code and PyCharm.
- `scripts/validate.py` is the main integrity check. It validates:
  - required subdirectories exist
  - required frontmatter keys exist
  - agent handoff `agent` references resolve to a real agent `name` or agent file ID
  - prompt `agent` references resolve to a real agent `name`
  - duplicate agent names are not introduced
  - local `.github/` files are validated for their own frontmatter and references only (no root-vs-source mirror comparison)
- Cross-file references are string-based. Example: `copilot/prompts/add-fastapi-endpoint.prompt.md` declares `agent: FastAPI API Agent`, which must exactly match an agent `name:` under `copilot/agents/`. Agent handoffs may target either that display `name:` or the agent filename without `.agent.md`, such as `implementation-plan`.

## Frontmatter and file-shape conventions
- Every managed artifact starts with YAML frontmatter at the top of the file.
- Required keys by artifact type:
  - agents: `name`, `description`
  - instructions: `description`, `applyTo`
  - prompts: `name`, `description`, `agent`
  - skills: `name`, `description`
- Keep scalar frontmatter simple and conventional. `scripts/validate.py` extracts fields like `name:`, prompt `agent:`, and handoff `agent:` values with regex, so unusual YAML formatting is riskier here than in parser-backed systems.
- File discovery is naming-based:
  - `copilot/agents/*.agent.md`
  - `copilot/instructions/*.instructions.md`
  - `copilot/prompts/*.prompt.md`
  - `copilot/skills/*/SKILL.md`

## Editing patterns to follow
- Make changes under `copilot/`, then validate. Do not edit an installed `.github/` or `~/.copilot/` copy and backport later.
- Do **not** add checks, tests, or workflow steps that enforce automatic synchronization between root `.github/` and `copilot/`.
- Match the existing style: short, task-focused markdown with compact rules or numbered steps. Good examples:
  - `copilot/agents/python-engineer.agent.md`
  - `copilot/skills/fastapi-endpoint-workflow/SKILL.md`
- When adding a prompt, point it at an existing agent name or add that agent first.
- When adding an agent, ensure `name:` is globally unique across all `copilot/agents/*.agent.md` files.
- Keep skills directory-based (`skills/<name>/SKILL.md`); agents, instructions, and prompts are flat files in their own folders.

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

## Project-specific gotchas
- `scripts/repo_install.sh` depends on `rsync` being available.
- In this workspace, installer scripts are **not executable**, so invoke them as `bash scripts/<script>.sh ...` unless file permissions are changed.
- There is no broader test suite or package manifest here; `scripts/validate.py` is the authoritative automated check.
- `scripts/validate.py` currently uses tab indentation internally; avoid unrelated reformatting if you modify it.
