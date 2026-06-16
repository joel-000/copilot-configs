# AGENTS.md

## Big picture
- This repository is a **Copilot configuration pack**, not an application. The real payload is `shared/.github/`, which is copied into other repositories.
- Treat `shared/.github/` as the **source of truth**. Root files like `README.md` explain the pack; they are not what gets installed.
- The enforced pack layout is `shared/.github/{agents,instructions,prompts,skills}`. `scripts/validate.py` assumes exactly these categories.

## Architecture and data flow
- `scripts/install.sh` copies `shared/.github/` into a target repository’s `.github/` directory using `rsync`.
- Default install mode is **safe merge**. `--prune` adds `rsync --delete` for exact mirroring, which can remove unmanaged target files.
- `scripts/validate.py` is the main integrity check. It validates:
  - required subdirectories exist
  - required frontmatter keys exist
  - prompt `agent` references resolve to a real agent `name`
  - duplicate agent names are not introduced
- Cross-file references are string-based. Example: `shared/.github/prompts/add-fastapi-endpoint.prompt.md` declares `agent: FastAPI API Agent`, which must exactly match an agent `name:` under `shared/.github/agents/`.

## Frontmatter and file-shape conventions
- Every managed artifact starts with YAML frontmatter at the top of the file.
- Required keys by artifact type:
  - agents: `name`, `description`, `tools`
  - instructions: `description`, `applyTo`
  - prompts: `name`, `description`, `agent`
  - skills: `name`, `description`
- Keep scalar frontmatter simple and conventional. `scripts/validate.py` extracts fields like `name:` and `agent:` with regex, so unusual YAML formatting is riskier here than in parser-backed systems.
- File discovery is naming-based:
  - `shared/.github/agents/*.agent.md`
  - `shared/.github/instructions/*.instructions.md`
  - `shared/.github/prompts/*.prompt.md`
  - `shared/.github/skills/*/SKILL.md`

## Editing patterns to follow
- Make changes under `shared/.github/...`, then validate. Do not edit an installed `.github/` copy and backport later.
- Match the existing style: short, task-focused markdown with compact rules or numbered steps. Good examples:
  - `shared/.github/agents/python-engineer.agent.md`
  - `shared/.github/skills/fastapi-endpoint-workflow/SKILL.md`
- When adding a prompt, point it at an existing agent name or add that agent first.
- When adding an agent, ensure `name:` is globally unique across all `shared/.github/agents/*.agent.md` files.
- Keep skills directory-based (`skills/<name>/SKILL.md`); agents, instructions, and prompts are flat files in their own folders.

## Developer workflow
- Validate before and after edits:
  ```bash
  python scripts/validate.py
  ```
- Smoke-test installation after structural changes:
  ```bash
  bash scripts/install.sh /tmp/copilot-config-smoke-test
  ```
- For exact-mirror behavior during a smoke test:
  ```bash
  bash scripts/install.sh --prune /tmp/copilot-config-smoke-test
  ```
- Check installer usage:
  ```bash
  bash scripts/install.sh --help
  ```

## Project-specific gotchas
- `scripts/install.sh` depends on `rsync` being available.
- In this workspace, `scripts/install.sh` is **not executable**, so invoke it as `bash scripts/install.sh ...` unless file permissions are changed.
- There is no broader test suite or package manifest here; `scripts/validate.py` is the authoritative automated check.
- `scripts/validate.py` currently uses tab indentation internally; avoid unrelated reformatting if you modify it.

