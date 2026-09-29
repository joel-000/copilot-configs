# Prompt-to-Skill Migration Plan

## Purpose and scope

This report is an execution plan for maintainers and delivery agents migrating the
configuration pack away from unsupported prompt files. It is based on a fresh
review of all five files under `copilot/prompts/`, all nine current
`copilot/skills/*/SKILL.md` files, and the repository's agent, instruction,
installer, validation, and Markdown conventions.

This plan does not implement the migration. It defines the target state,
canonical ownership boundaries, safe deletion order, file actions, acceptance
criteria, and validation commands.

## Executive summary

All five prompts can be represented by skills or durable agent/instruction
policy. None should remain as a thin prompt wrapper because prompt files are
reported as unsupported in the target environment.

The migration should:

1. Merge `add-fastapi-endpoint` into `fastapi-endpoint-workflow`.
2. Merge `review-terraform-plan` into `terraform-plan-review`.
3. Add a concise `docker-workflow` skill that orchestrates an improvement
   workflow while leaving Docker and application-security rules in their
   existing instruction files.
4. Move the approval checkpoint from `plan-approved-slice` into the
   `Implementer` and global planning policy. Do not create an
   `approval-checkpoint` skill unless a representative trigger test proves that
   the supported clients invoke it reliably without an explicit prompt command.
5. Add a `pr-readiness` skill for readiness assessment and PR-package
   preparation. Keep commit creation in `git-commit`.
6. Retire all five prompt files only after their replacement capability is
   installed and validated.
7. Remove prompt-only validation, installer, instruction, and documentation
   assumptions so unsupported artifacts are not advertised or left behind.

The target contains 11 skills: seven retained existing skills with targeted
boundary clarifications, two enriched existing domain skills, and two new
workflow skills. Existing overlaps must be narrowed rather than multiplied:

- `create-readme` owns only README creation and refreshes;
  `documentation-writer` owns documentation type, information architecture, and
  non-README documentation.
- `pytest-unit-test-workflow` owns test-only pytest work;
  `tdd-red-green` owns a strict test-first implementation cycle that changes both
  tests and production code.
- `git-commit` owns staging and commit creation; `pr-readiness` owns pre-PR
  evidence, gate status, risks, and reviewer-facing output.
- Domain skills own task sequencing. Instruction files remain the canonical
  source for cross-cutting policy and detailed standards.

## Design rules for the migration

### Canonical ownership

Use one canonical owner for each rule:

| Concern | Canonical owner | Consumers |
| --- | --- | --- |
| Approval checkpoint and smallest useful slice | `Implementer` plus global repository instructions | All planning and implementation workflows |
| Review timing, re-review, and waivers | `agent-topology.instructions.md` | `Implementer`, `pr-readiness`, and domain workflows |
| Docker standards and review checklist | `containerization-docker-best-practices.instructions.md` | `docker-workflow` |
| General application security | `security-and-owasp.instructions.md` and the independent Security Review Agent | Application-code workflows |
| Platform and supply-chain security | `security-and-owasp-platform.instructions.md` and the independent Security Review Agent | Docker, Terraform, CI, and dependency workflows |
| FastAPI endpoint sequencing and domain checks | `fastapi-endpoint-workflow` | FastAPI changes |
| Terraform plan analysis and output contract | `terraform-plan-review` | Terraform review requests |
| PR readiness and reviewer package | `pr-readiness` | PR preparation requests |
| Commit staging and Conventional Commits | `git-commit` | Commit requests |
| README creation | `create-readme` | README-only requests |
| General documentation method | `documentation-writer` | Tutorials, how-to guides, reference, and explanation outside README work |
| Pytest test maintenance | `pytest-unit-test-workflow` | Test-only additions, fixes, and reviews |
| Strict test-first implementation | `tdd-red-green` | Behaviour changes explicitly using red-green-refactor |

Skills should link to canonical instruction files and state the workflow-specific
decisions they add. They should not copy long checklists, security rules, gate
definitions, or waiver wording.

### Skill file shape

Every new or changed skill must:

- live at `copilot/skills/<kebab-case-name>/SKILL.md`;
- begin with simple YAML frontmatter containing parseable `name` and
  `description` scalar fields;
- use a description that states when the skill applies so supported clients can
  select it;
- use direct, imperative wording and compact sections;
- define inputs, stop conditions, workflow, output, and validation where those
  are material;
- remain compatible with VS Code and PyCharm shared conventions;
- avoid prompt-only `agent` frontmatter and prompt variables;
- follow `markdown.instructions.md`.

## Prompt-by-prompt disposition matrix

| Prompt | Can become a skill? | Exact changes required | Existing skill with the same work | Recommended disposition |
| --- | --- | --- | --- | --- |
| `add-fastapi-endpoint.prompt.md` | Yes. Its durable domain workflow belongs in a skill. | Update `fastapi-endpoint-workflow/SKILL.md` to add the approval checkpoint, compact approved-slice plan, plan review gates for material plans, explicit red-green-refactor default where practical, post-change quality/security gates, documentation checks, and a compact completion packet. Keep existing router/schema discovery, thin-handler, service-layer, auth, error mapping, endpoint-test, and OpenAPI checks. Reference topology policy instead of copying waiver or re-review rules. | Yes: `fastapi-endpoint-workflow` already owns FastAPI endpoint creation and modification. `pytest-unit-test-workflow` may support test-only work, and `tdd-red-green` may support the implementation loop, but neither owns endpoint design. | Merge only the missing durable workflow details into `fastapi-endpoint-workflow`, validate the enriched skill, then delete the prompt. Do not create another FastAPI skill. |
| `improve-docker-setup.prompt.md` | Yes. It is a reusable container-improvement workflow. | Create `copilot/skills/docker-workflow/SKILL.md` with discovery of Dockerfile, Compose, ignore-file, build, runtime, and repository validation conventions; an approved slice; plan gates only when a material plan exists; minimal implementation; focused build/config checks; post-change gates; and a completion packet. Link to `containerization-docker-best-practices.instructions.md`, `security-and-owasp-platform.instructions.md`, and `agent-topology.instructions.md`. Do not reproduce their multi-stage-build, image, non-root, secret, exposure, health-check, or scanning checklists. Use a trigger-oriented description covering Dockerfiles, Compose, image size, build reliability, and container security. | No current skill owns Docker workflow execution. The Docker and platform-security instruction files already own almost all technical standards, so the new skill must orchestrate rather than duplicate them. | Add one concise `docker-workflow` skill, prove it validates and is discoverable in supported clients, then delete the prompt. Do not retain a wrapper prompt. |
| `plan-approved-slice.prompt.md` | Conditionally. The text is skill-shaped, but an approval boundary is universal policy and is unsafe to depend on if automatic skill triggering is not reliable. | Preferred path: add a concise planning/approval section to `implementer.agent.md`; add the universal “goal, uncertainty, smallest useful slice, explicit approval” rule to `copilot-instructions.md`; keep gate, waiver, and re-review semantics solely in `agent-topology.instructions.md`; remove duplicated planning/gate text from `planning-agent-orchestration.instructions.md` and delete that instruction if it has no remaining distinct rule. Update affected documentation. Alternative path only after trigger proof: create `approval-checkpoint/SKILL.md` containing just the checkpoint and stop condition, while still keeping the minimum no-code-before-approval safety rule in `Implementer`. | No skill is an exact equivalent. The `Implementer`, global instructions, `planning-agent-orchestration.instructions.md`, and `agent-topology.instructions.md` already contain pieces of the behaviour. Creating a skill without consolidation would increase redundancy. | Use the preferred policy path now and retire the prompt. Do not make migration completion depend on an unproven skill trigger. Add an approval-checkpoint skill later only if both supported clients reliably select it in representative planning and implementation requests. |
| `prepare-pr.prompt.md` | Yes. PR readiness is a reusable, discoverable workflow distinct from committing. | Create `copilot/skills/pr-readiness/SKILL.md`. Require current diff/status, acceptance criteria, validation evidence, relevant documentation, and latest gate verdicts. Reuse verdicts unless subsequent changes materially affect the gate-owned surface. Block a “ready” verdict when required evidence or gates are absent. Output PR title, summary, tests, risks, reviewer checklist, fixes required before opening, and any explicit waiver summary. Reference topology policy for gate lifecycle and waiver semantics instead of copying it. Explicitly exclude staging, committing, pushing, opening, or merging a PR unless separately requested. | No. `git-commit` creates a local commit and owns Conventional Commit formatting; it does not establish PR readiness or create reviewer-facing evidence. `Implementer` has a generic completion packet but not the full PR-readiness contract. | Add `pr-readiness`, validate it, then delete the prompt. Keep `git-commit` and state the boundary in both skill descriptions or scope sections. |
| `review-terraform-plan.prompt.md` | Yes. It is a read-only review workflow. | Enrich `terraform-plan-review/SKILL.md` with explicit read-only scope; added/changed/replaced/destroyed categorisation; irreversible data-change priority; module, state-address, and replacement-trigger analysis; IAM and public-exposure review; evidence, severity, affected resource, and smallest safe follow-up per finding; missing-command reporting; and a final go/no-go judgement. Add `terraform fmt -check`, `terraform validate`, and `terraform plan` as conditional narrow checks, making clear that unavailable commands are not passes. Preserve the existing blockers/risks/safe-changes summary. Reference Terraform and security instructions rather than repeating their standards. | Yes: `terraform-plan-review` already owns Terraform diff, plan, and AWS-risk review. | Merge the richer review, output, and validation constraints into `terraform-plan-review`, validate it, then delete the prompt. Do not create a second Terraform review skill. |

## Target skill inventory after migration

The preferred target has 11 skills and no prompt files.

| Skill | Target action | Canonical responsibility | Explicit exclusions or boundary |
| --- | --- | --- | --- |
| `create-readme` | Narrow | Create or refresh a repository `README.md` using project evidence and README-specific sections and assets. | Do not own general documentation architecture or all Diátaxis document types. Remove the instruction to review the entire workspace; inspect only evidence needed for the README. |
| `documentation-writer` | Narrow | Select and author tutorials, how-to guides, reference, and explanation; establish audience, goal, scope, and structure. | Exclude README creation when `create-readme` is available. Do not force a second clarification/outline round when the user has already supplied document type, audience, goal, scope, and required structure. |
| `fastapi-endpoint-workflow` | Enrich | End-to-end FastAPI route, schema, service-boundary, contract, and endpoint-test workflow. | Refer test-only maintenance to `pytest-unit-test-workflow`; use `tdd-red-green` only for a strict test-first implementation request. |
| `git-commit` | Clarify | Inspect/stage a logical change and create a safe Conventional Commit. | No PR-readiness verdict, push, PR creation, or merge. |
| `pytest-unit-test-workflow` | Retain and clarify | Add, fix, or review pytest tests without requiring a production-code implementation cycle. | No strict red-green production change and no mandatory Hypothesis usage. |
| `quasi-coder` | Retain | Interpret shorthand, pseudo-code, imperfect terminology, and marked shorthand blocks. | No ownership of domain workflows, planning gates, or generic implementation policy. |
| `refactor` | Retain | Behaviour-preserving, incremental code-structure improvement. | No feature work or broad rewrite. |
| `tdd-red-green` | Retain and clarify | Implement one observable behaviour through strict red, green, and optional refactor steps, changing tests and production code. Use Hypothesis only where broad input exploration is useful. | No ownership of routine test-only maintenance or review; that remains with `pytest-unit-test-workflow`. |
| `terraform-plan-review` | Enrich | Read-only Terraform diff/plan risk analysis, evidence-based findings, validation status, and go/no-go output. | No infrastructure modification or apply. |
| `docker-workflow` | Add | Orchestrate scoped Dockerfile/Compose improvement and validation. | Do not duplicate Docker or OWASP standards from instructions. |
| `pr-readiness` | Add | Assess readiness and prepare reviewer-facing PR title, summary, evidence, risk, checklist, and blockers. | Do not stage, commit, push, open, update, merge, or close a PR. |

### Intentional pytest and TDD boundary

Preserve both test skills. They are not duplicates:

- Select `pytest-unit-test-workflow` when the requested deliverable is a test
  addition, test fix, or test review. Production code need not change.
- Select `tdd-red-green` when the requested deliverable is production behaviour
  and the user requests, or the workflow requires, a strict test-first cycle.
  The skill proves red, makes the minimum production change for green, and then
  refactors only if useful.
- When both apply to a FastAPI change, `fastapi-endpoint-workflow` owns the
  endpoint contract and sequencing, `tdd-red-green` owns the implementation
  loop, and `pytest-unit-test-workflow` supplies repository-specific pytest
  conventions without replacing the TDD lifecycle.

### README and general documentation boundary

Retain both documentation skills only after narrowing them:

- `create-readme` is the task recipe for one artifact: `README.md`.
- `documentation-writer` is the documentation-method skill for selecting and
  producing Diátaxis document types.
- Shared clarity, accuracy, audience, and Markdown rules belong in
  `documentation-writer` or `markdown.instructions.md`; do not copy them into
  `create-readme`.
- A README request selects `create-readme`. A documentation-set, tutorial,
  how-to, reference, or explanation request selects `documentation-writer`.

This boundary preserves useful specialization while eliminating competing
claims to generic documentation authorship.

## Phased migration work

Dependencies are stable work-item IDs, not execution-order prose. Complete each
item's acceptance criteria before marking it done.

### MIG-001: Confirm baseline and skill-trigger support

**Depends on:** None.

**File actions:**

- Do not modify artifacts for the baseline step.
- Record the current output of `python scripts/validate.py`.
- In both supported clients, install the current skill set and run representative
  natural-language requests that should select `fastapi-endpoint-workflow`,
  `terraform-plan-review`, and a temporary or branch-only approval-checkpoint
  prototype.
- Record whether selection is automatic, explicit-only, unavailable, or
  inconsistent. Do not add the approval skill to the target branch unless both
  clients reliably select it.

**Acceptance criteria:**

- Baseline validation passes or every pre-existing failure is recorded.
- Skill discovery is demonstrated for normal domain skills.
- The approval-skill decision has evidence from VS Code and PyCharm.
- Failure or uncertainty selects the preferred universal-policy path; it does
  not block the rest of the migration.

**Required discovery evidence:**

Record one row for each representative request in a migration completion
packet. Each row must include the client name and version, request text, target
skill or universal policy, actual selection, and fallback behavior. Use at
least these requests:

| Client | Request | Expected selection |
| --- | --- | --- |
| VS Code | "Add a FastAPI endpoint following this repository's conventions." | `fastapi-endpoint-workflow` |
| VS Code | "Review this Terraform plan for replacements and destructive changes." | `terraform-plan-review` |
| PyCharm | "Add a FastAPI endpoint following this repository's conventions." | `fastapi-endpoint-workflow` |
| PyCharm | "Review this Terraform plan for replacements and destructive changes." | `terraform-plan-review` |
| VS Code | "Plan a change to this repository." | Implementer approval checkpoint |
| PyCharm | "Plan a change to this repository." | Implementer approval checkpoint |

For each row, classify the result as `automatic`, `explicit-only`,
`unavailable`, or `inconsistent`. Automatic skill selection is useful evidence
but is not a prerequisite for the migration; the Implementer and global
instructions remain the required fallback for approval safety.

**Validation commands:**

```bash
python scripts/validate.py
bash scripts/global_install.sh --help
```

Manual client checks are required because the repository validator checks skill
shape, not runtime selection.

### Capability traceability required before prompt deletion

Before completing MIG-070, add a compact before/after checklist to the
completion packet mapping every retired prompt behavior to its replacement
owner. The checklist must cover all five prompts and identify any behavior
intentionally dropped, with reviewer confirmation that the drop is in scope.
At minimum, map:

- FastAPI discovery, thin handlers, service boundaries, validation, errors,
  tests, OpenAPI checks, approval, gates, and completion reporting.
- Docker repository discovery, approved-slice workflow, focused validation,
  security-instruction references, and completion reporting.
- Approval checkpoint, no-edit boundary, and universal-policy fallback.
- PR readiness evidence, gate reuse, blocking conditions, and reviewer output.
- Terraform change classification, evidence-backed findings, read-only
  behavior, and unavailable-command reporting.

### MIG-010: Consolidate the FastAPI workflow

**Depends on:** `MIG-001`.

**File actions:**

- Modify `copilot/skills/fastapi-endpoint-workflow/SKILL.md` with the durable
  workflow details listed in the prompt matrix.
- Do not change `pytest-unit-test-workflow` or `tdd-red-green` ownership.
- Keep gate mechanics as references to
  `copilot/instructions/agent-topology.instructions.md`.

**Acceptance criteria:**

- One FastAPI skill covers discovery, approval, planning when material,
  implementation, contract tests, OpenAPI impact, gates, documentation, and
  completion reporting.
- No gate or waiver policy is copied into the skill.
- The skill still applies to both new and modified endpoints.

**Validation commands:**

```bash
python scripts/validate.py
git diff --check
```

### MIG-020: Consolidate Terraform plan review

**Depends on:** `MIG-001`.

**File actions:**

- Modify `copilot/skills/terraform-plan-review/SKILL.md` with the full read-only
  review, evidence, output, validation, and go/no-go contract from the matrix.
- Link to `copilot/instructions/terraform.instructions.md` and
  `copilot/instructions/security-and-owasp-platform.instructions.md` for
  standards; do not restate them.

**Acceptance criteria:**

- The skill distinguishes create, update, replace, and destroy.
- Every reported finding requires resource, evidence, severity, and smallest
  safe follow-up.
- Missing or unavailable Terraform commands are reported as not run, never as
  passing.
- The skill never edits or applies infrastructure.

**Validation commands:**

```bash
python scripts/validate.py
git diff --check
```

### MIG-030: Add the Docker workflow skill

**Depends on:** `MIG-001`.

**File actions:**

- Add `copilot/skills/docker-workflow/SKILL.md`.
- Reference
  `copilot/instructions/containerization-docker-best-practices.instructions.md`,
  `copilot/instructions/security-and-owasp-platform.instructions.md`, and
  `copilot/instructions/agent-topology.instructions.md`.
- Keep the skill concise and workflow-focused.

**Acceptance criteria:**

- The description is discoverable for Dockerfile, Compose, image-size,
  build-reliability, and container-security requests.
- The skill inspects repository conventions before proposing changes.
- It requires the smallest relevant build, configuration, lint, or runtime
  checks available in the target repository.
- It contains no copied Docker or OWASP checklist.

**Validation commands:**

```bash
python scripts/validate.py
git diff --check
```

### MIG-040: Make approval policy universal

**Depends on:** `MIG-001`.

**File actions for the preferred path:**

- Modify `copilot/agents/implementer.agent.md` to require a concise checkpoint
  for unapproved planning or implementation requests: goal, largest uncertainty,
  smallest useful slice, and explicit approval before deeper planning or edits.
- Modify `copilot/copilot-instructions.md` to state the universal approval
  boundary without duplicating the detailed Implementer procedure.
- Keep all review-gate, re-review, and waiver rules in
  `copilot/instructions/agent-topology.instructions.md`.
- Delete
  `copilot/instructions/planning-agent-orchestration.instructions.md` after its
  unique approval behaviour is moved. Its current `applyTo` targets only prompt
  files that will be removed.

**Conditional alternative:**

- Only if `MIG-001` proves reliable automatic selection in both supported
  clients, add `copilot/skills/approval-checkpoint/SKILL.md`.
- Limit it to checkpoint output and the stop-before-approval rule.
- Still retain the minimum no-edit-before-approval rule in `Implementer`; safety
  must not depend solely on skill selection.
- If this alternative is selected, add the skill to the target inventory and
  document the trigger evidence in the migration PR.

**Acceptance criteria:**

- Every Implementer-led plan or implementation request has an approval boundary
  even when no skill is selected.
- Detailed plans require gates only under the existing topology policy.
- There is no dead `applyTo` glob referring only to deleted prompt names.
- Approval text, gate text, and waiver text each have one canonical owner.

**Validation commands:**

```bash
python scripts/validate.py
git diff --check
```

### MIG-050: Add PR readiness

**Depends on:** `MIG-001`, `MIG-040`.

**File actions:**

- Add `copilot/skills/pr-readiness/SKILL.md` with the scope and output contract
  in the matrix.
- Modify `copilot/skills/git-commit/SKILL.md` only as needed to state that PR
  readiness and PR operations are out of scope.
- Reference `agent-topology.instructions.md`; do not duplicate its lifecycle or
  waiver rules.

**Acceptance criteria:**

- The skill cannot return “ready” without acceptance, validation,
  documentation, and applicable gate evidence.
- The skill reuses still-current gate verdicts and requests re-review only after
  a material delta.
- The output includes title, summary, tests, risks, reviewer checklist, required
  fixes, and explicit waivers.
- No step stages, commits, pushes, opens, updates, or merges a PR.

**Validation commands:**

```bash
python scripts/validate.py
git diff --check
```

### MIG-060: Normalize overlapping existing skills

**Depends on:** `MIG-001`.

**File actions:**

- Modify `copilot/skills/create-readme/SKILL.md` to make it README-only,
  evidence-scoped, and free of generic documentation-method duplication.
- Modify `copilot/skills/documentation-writer/SKILL.md` to exclude README work
  when the specialized skill exists and to accept already-complete user inputs
  without redundant clarification and outline-approval rounds.
- Modify descriptions or scope text in
  `copilot/skills/pytest-unit-test-workflow/SKILL.md` and
  `copilot/skills/tdd-red-green/SKILL.md` only enough to encode the intentional
  boundary above.
- Do not change `quasi-coder` or `refactor` beyond a cross-skill reference that
  is demonstrably necessary.

**Acceptance criteria:**

- A maintainer can select exactly one primary skill for README, general
  documentation, test-only pytest, and strict TDD requests.
- No skill claims universal ownership of another skill's workflow.
- Existing useful capability is retained.

**Validation commands:**

```bash
python scripts/validate.py
git diff --check
```

### MIG-070: Retire prompt files without capability loss

**Depends on:** `MIG-010`, `MIG-020`, `MIG-030`, `MIG-040`, `MIG-050`.

**File actions:**

- Delete `copilot/prompts/add-fastapi-endpoint.prompt.md`.
- Delete `copilot/prompts/improve-docker-setup.prompt.md`.
- Delete `copilot/prompts/plan-approved-slice.prompt.md`.
- Delete `copilot/prompts/prepare-pr.prompt.md`.
- Delete `copilot/prompts/review-terraform-plan.prompt.md`.
- Delete `copilot/instructions/prompt.instructions.md`.
- Remove `prompt.md` from the `applyTo` glob in
  `copilot/instructions/agent-topology.instructions.md`.

**Acceptance criteria:**

- Each deleted prompt has a validated replacement from its dependency.
- No `*.prompt.md` file remains under `copilot/`.
- No active instruction targets prompt files.
- Domain, approval, and PR-readiness capability remains discoverable.

**Validation commands:**

```bash
find copilot -type f -name '*.prompt.md' -print
grep -R --line-number --include='*.md' 'prompt\.md' copilot || true
python scripts/validate.py
git diff --check
```

The `find` command must print nothing. Review every `grep` result and retain only
historical migration documentation where intentional.

### MIG-080: Retire prompt infrastructure and stale installs

**Depends on:** `MIG-070`.

**File actions:**

- Modify `scripts/validate.py` to remove `prompts` from `REQUIRED_SUBDIRS`, remove
  prompt-frontmatter validation, and remove its invocation.
- Modify `scripts/global_install.sh` to remove `prompts` from
  `MANAGED_DIRECTORIES`.
- Add a narrowly scoped upgrade cleanup in `scripts/global_install.sh` for a
  legacy `~/.copilot/prompts` symlink only when its canonical target is this
  pack's former `copilot/prompts` location. Verify that the entry is still a
  symlink immediately before removal, and handle a broken legacy symlink without
  following or deleting its target. Never delete an unrelated user directory.
- Remove the empty `copilot/prompts/` directory.
- Update `README.md` and `AGENTS.md` to remove prompts from the supported layout,
  installer mapping, frontmatter requirements, examples, and demo runbook.
- Document that repository installs are safe-merge by default and therefore do
  not remove already-copied `.github/prompts` files. Tell users to remove the
  five known legacy files explicitly or use the repository's confirmed prune
  flow after reviewing the target.

**Acceptance criteria:**

- Validation and global installation no longer require or advertise a prompt
  directory.
- An upgrade removes only the pack-owned legacy global prompt symlink.
- Default repository installation does not silently delete user-managed files.
- Documentation gives an explicit cleanup path for stale installed prompt
  copies.
- The source tree and documented layout agree.

**Validation commands:**

```bash
python scripts/validate.py
bash scripts/global_install.sh --help
bash scripts/repo_install.sh --help
git diff --check
```

For an isolated installer smoke test:

```bash
tmp_dir="$(mktemp -d)"
bash scripts/repo_install.sh "$tmp_dir"
find "$tmp_dir/.github" -maxdepth 3 -type f -print | sort
```

Also exercise global upgrade cleanup in disposable directories. Verify that a
broken symlink to this checkout's former `copilot/prompts` path is removed and
that an unrelated prompt symlink is preserved:

```bash
owned_home="$(mktemp -d)"
ln -s -- "$PWD/copilot/prompts" "$owned_home/prompts"
bash scripts/global_install.sh \
  --copilot-home "$owned_home" --allow-outside-home
test ! -L "$owned_home/prompts"

unrelated_home="$(mktemp -d)"
unrelated_target="$(mktemp -d)"
ln -s -- "$unrelated_target" "$unrelated_home/prompts"
bash scripts/global_install.sh \
  --copilot-home "$unrelated_home" --allow-outside-home
test -L "$unrelated_home/prompts"
test "$(readlink -- "$unrelated_home/prompts")" = "$unrelated_target"
```

Use the destructive prune smoke test only in a disposable directory and with
the script's required confirmation flag.

### MIG-090: Final quality and security gates

**Depends on:** `MIG-060`, `MIG-080`.

**File actions:**

- Make no planned content changes during this item.
- Ask the Quality Review Test Agent to assess skill selection boundaries,
  capability preservation, validator/installer regression risk, and validation
  evidence.
- Ask the Security Review Agent to assess installer cleanup safety, destructive
  path handling, secret guidance, gate-policy preservation, and any changed
  trust boundary.
- If a reviewer changes tests, inspect and run them, then request the required
  fresh quality review.
- Resolve accepted findings with the smallest in-scope change and re-run affected
  checks.

**Acceptance criteria:**

- Both review gates pass or have explicit, recorded user waivers.
- No accepted blocker remains.
- The final diff contains only migration-related changes.

**Validation commands:**

```bash
python scripts/validate.py
git diff --check
git status --short
git diff --stat
```

## Deletion and rollout sequence

Use this order to avoid a capability gap:

1. Establish baseline and trigger evidence (`MIG-001`).
2. Enrich FastAPI and Terraform skills (`MIG-010`, `MIG-020`).
3. Add the Docker skill (`MIG-030`).
4. Move approval policy to an always-available owner (`MIG-040`).
5. Add PR readiness after its approval-policy dependency (`MIG-050`).
6. Validate every replacement while all prompts still exist.
7. Delete the five prompt files together (`MIG-070`).
8. Remove prompt-only validator, installer, instruction, and documentation
   support (`MIG-080`).
9. Smoke-test a fresh install and explicitly test legacy global-symlink cleanup.
10. Run final independent reviews and validation (`MIG-090`).
11. In existing repositories, remove only the five known copied legacy prompt
    files. Use prune mode only after inspecting the destination because it can
    remove unmanaged files.

Do not delete a prompt in the same change that first introduces its replacement
unless validation and client discovery evidence for the replacement is captured
before deletion.

## Risks and assumptions

| Risk or assumption | Impact | Mitigation or decision |
| --- | --- | --- |
| Prompt files are unsupported in the target environment. | Thin wrappers provide no dependable fallback. | Final state contains no prompt files or prompt-only infrastructure. |
| The validator checks only skill frontmatter, not runtime selection. | A syntactically valid skill may not trigger when needed. | Perform manual VS Code and PyCharm trigger checks in `MIG-001`; keep the approval safety boundary in always-loaded policy. |
| Instruction `applyTo` matching is file-oriented, not a reliable semantic planning trigger. | The current planning instruction becomes ineffective after its named prompts are deleted. | Move the checkpoint into `Implementer` and global instructions, then delete the dead planning instruction. |
| Safe-merge repository installs preserve stale `.github/prompts` files. | Users may continue seeing unsupported artifacts after upgrading. | Document explicit deletion of the five legacy files; reserve prune mode for reviewed, disposable or intentionally mirrored targets. |
| Removing `prompts` from the global installer can leave an old symlink. | A stale link may remain or become broken. | Add ownership-checked cleanup for only the legacy symlink that resolves to this pack. Never remove arbitrary user prompt directories. |
| Workflow skills can repeat topology policy. | Gate and waiver rules drift. | Skills reference `agent-topology.instructions.md`; only topology owns gate lifecycle. |
| The new Docker skill may duplicate the extensive Docker instruction. | Maintenance burden and conflicting standards increase. | Keep the skill to discovery, sequencing, validation, and reporting. Link to the instruction for technical rules. |
| README and general documentation skills currently overlap. | Client selection can be ambiguous and duplicate questioning. | Make `create-readme` artifact-specific and `documentation-writer` method-specific, with explicit exclusions. |
| Pytest and TDD skills look similar because both mention pytest. | An over-aggressive consolidation would lose either test-only maintenance or strict implementation sequencing. | Preserve both and encode the primary-deliverable boundary. |
| Current README and AGENTS text assumes prompts are part of the enforced layout. | Deleting prompt files alone leaves inaccurate operating guidance. | Update both documents and installer/validator assumptions in `MIG-080`. |
| The Docker instruction contains broad and potentially dated examples. | Copying examples into a skill would freeze more duplicated detail. | Reference the instruction; review its content separately from this migration if modernization is needed. |

## Final definition of done

The migration is complete only when all of the following are true:

- [x] Cross-client discovery evidence was recorded. VS Code and PyCharm were
  unavailable in the execution environment, so domain-skill scenarios are
  classified as `unavailable` with explicit skill-selection fallback, and
  approval scenarios use the always-available Implementer/global-policy
  boundary.

| Client | Request | Expected target | Actual result | Fallback |
| --- | --- | --- | --- | --- |
| VS Code (unavailable) | Add a FastAPI endpoint following repository conventions. | `fastapi-endpoint-workflow` | Unavailable | Explicit skill selection |
| VS Code (unavailable) | Review this Terraform plan for replacements and destructive changes. | `terraform-plan-review` | Unavailable | Explicit skill selection |
| PyCharm (unavailable) | Add a FastAPI endpoint following repository conventions. | `fastapi-endpoint-workflow` | Unavailable | Explicit skill selection |
| PyCharm (unavailable) | Review this Terraform plan for replacements and destructive changes. | `terraform-plan-review` | Unavailable | Explicit skill selection |
| VS Code (unavailable) | Plan a change to this repository. | Implementer approval checkpoint | Unavailable | Implementer/global instructions |
| PyCharm (unavailable) | Plan a change to this repository. | Implementer approval checkpoint | Unavailable | Implementer/global instructions |

- [x] Prompt capability traceability was reviewed before deletion:

| Retired prompt | Replacement owner | Preserved capabilities |
| --- | --- | --- |
| `add-fastapi-endpoint` | `fastapi-endpoint-workflow` | Repository discovery, thin handlers, service boundaries, validation, errors, endpoint tests, OpenAPI, approval, review gates, documentation, completion reporting |
| `improve-docker-setup` | `docker-workflow` | Repository/container discovery, approved slice, focused validation, canonical Docker and platform-security references, completion reporting |
| `plan-approved-slice` | Implementer plus global instructions | Goal, uncertainty, smallest useful slice, explicit approval, no-edit boundary, universal fallback |
| `prepare-pr` | `pr-readiness` | Acceptance, validation, documentation, gate evidence, risks, blockers, waivers, reviewer package; PR operations remain out of scope |
| `review-terraform-plan` | `terraform-plan-review` | Create/update/replace/destroy classification, evidence-backed findings, read-only behavior, unavailable-command reporting, go/no-go output |

- [x] No capability was intentionally dropped; unavailable client checks are
  recorded as an environment limitation rather than a pass claim.
- [x] The five source prompt files are deleted.
- [x] `fastapi-endpoint-workflow` contains the durable FastAPI workflow details
  without duplicating test or topology policy.
- [x] `terraform-plan-review` contains the richer read-only review, evidence,
  output, and validation contract.
- [x] `docker-workflow` and `pr-readiness` exist and are discoverable.
- [x] The approval checkpoint works without prompt-file support through
  `Implementer` and global policy; an approval skill exists only with recorded
  cross-client trigger evidence.
- [x] `git-commit` and `pr-readiness` have non-overlapping ownership.
- [x] `create-readme` and `documentation-writer` have non-overlapping primary
  selection rules.
- [x] `pytest-unit-test-workflow` and `tdd-red-green` retain their intentional
  test-only versus test-first-implementation boundary.
- [x] Docker and security standards remain canonical in instruction files rather
  than copied into workflow skills.
- [x] Gate timing, re-review, and waiver policy remain canonical in
  `agent-topology.instructions.md`.
- [x] Prompt-only instructions, validator logic, installer mapping, and
  documentation are removed or updated.
- [x] Legacy global prompt-symlink cleanup is ownership-checked, and repository
  cleanup does not silently delete user-managed files.
- [x] A fresh repository install contains the intended agents, instructions,
  skills, and global instructions with no prompt files.
- [x] `python scripts/validate.py` and `git diff --check` pass.
- [ ] Quality and security reviews pass, or explicit waivers are recorded.
- [ ] No accepted blocker remains and the completion packet records files,
  validation, gate verdicts, waivers, and follow-ups.
