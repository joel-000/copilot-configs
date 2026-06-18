# Copilot Config Suite Improvement Plan

## Goal
Keep this repository as a portable, high-signal Copilot configuration pack with predictable behavior, minimal accidental scope, and strong validation.

## Current Baseline (Already Landed)

1. **Planning workflow split is implemented**
   - Human-facing checkpoint lives in `shared/.github/agents/plan.agent.md`.
   - Detailed internal planner lives in `shared/.github/agents/implementation-plan.agent.md`.
   - Approved-slice flow is exposed via `shared/.github/prompts/plan-approved-slice.prompt.md`.

2. **Installer and validation structure are modernized**
   - Installer split into `scripts/repo_install.sh` and `scripts/pycharm_install.sh`.
   - Validator checks source pack, root mirrors, references, and symlink constraints.

## Updated Prioritized Improvements

1. **Reduce global instruction blast radius**
   - Replace broad `applyTo: '**'` in:
     - `shared/.github/instructions/exclude-prompt-data.instructions.md`
     - `shared/.github/instructions/security-and-owasp.instructions.md`
   - Split into narrower, workflow/file-targeted instruction files.

2. **Standardize agent tool declarations for portability**
   - Normalize tools to one schema (for example: `read`, `edit`, `search`, `execute`, `web`, `agent`).
   - Remove mixed aliases/patterns such as `terminal` and inconsistent namespaced forms.

3. **Harden the planning workflow rather than merging it**
   - Keep the two-stage model.
   - Add explicit UX verification criteria for approval checkpoint and handoff transitions.
   - Tighten guardrails around approved-slice boundaries.

4. **Upgrade skill quality to repository standards**
   - Prioritize:
     - `shared/.github/skills/create-readme/SKILL.md`
     - `shared/.github/skills/fastapi-endpoint-workflow/SKILL.md`
     - `shared/.github/skills/pytest-unit-test-workflow/SKILL.md`
     - `shared/.github/skills/terraform-plan-review/SKILL.md`
   - Improve descriptions for discovery (WHAT + WHEN + KEYWORDS).
   - Add/expand `Gotchas` and `Troubleshooting`.
   - Break oversized skill docs into concise core + `references/` when needed.

5. **Strengthen prompt contracts**
   - Add clearer preconditions, scope limits, and output contracts to short prompts.
   - Remove low-signal wording and ambiguous phrasing.

6. **Define root `.github` mirror strategy**
   - Decide whether root `.github/` remains a manual mirror or becomes generated from `shared/.github/`.
   - Enforce the chosen approach consistently via validation and repository conventions.

7. **Add optional cross-stack profile coverage**
   - Extend pack coverage with optional assets for:
     - JavaScript/TypeScript, Java, Go, C#, Rust
     - CI triage, dependency upgrades, release notes, bug reproduction, migration planning

## Execution Strategy

1. **Phase 1 (foundation):** Reduce global instruction scope and standardize agent tool declarations.
2. **Phase 2 (quality):** Upgrade priority skills and prompt contracts.
3. **Phase 3 (structure):** Finalize/enforce root mirror strategy.
4. **Phase 4 (coverage):** Add optional cross-stack profile assets.
5. Run `python scripts/validate.py` after each phase and keep `shared/.github/` as source of truth.
