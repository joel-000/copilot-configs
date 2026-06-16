# Copilot Config Suite Improvement Plan

## Goal
Evolve this repository into a high-quality Copilot extension suite that works reliably across many project types, while keeping behavior predictable and maintainable.

## Prioritized Improvements

1. **Split into profiles (core + domain packs)**
   - Keep a lean universal core.
   - Move stack-specific content (Python/FastAPI/AWS/Terraform) into optional packs.

2. **Reduce global instruction blast radius**
   - Narrow `applyTo: '**'` usage in:
     - `shared/.github/instructions/exclude-prompt-data.instructions.md`
     - `shared/.github/instructions/security-and-owasp.instructions.md`
   - Prefer focused instruction files by file type and workflow.

3. **Standardize agent tool declarations**
   - Normalize tool naming/schema across all agents.
   - Remove mixed legacy/namespaced tool patterns that can reduce portability.

4. **Consolidate overlapping planning agents**
   - Clarify or merge responsibilities between:
     - `shared/.github/agents/plan.agent.md`
     - `shared/.github/agents/implementation-plan.agent.md`

5. **Strengthen underspecified agents and prompts**
   - Expand short agents/prompts with explicit:
     - assumptions
     - constraints
     - guardrails
     - output contracts
     - validation expectations

6. **Upgrade skills to match skill standards**
   - Improve discovery descriptions (WHAT + WHEN + KEYWORDS).
   - Add/expand gotchas and troubleshooting where relevant.
   - Prioritize:
     - `create-readme`
     - `fastapi-endpoint-workflow`
     - `pytest-unit-test-workflow`
     - `terraform-plan-review`

7. **Remove brittle or low-signal prompt language**
   - Replace non-deterministic phrasing with clear operational instructions.
   - Avoid hardcoded style references unless they are required by policy.

8. **Add universal, cross-stack coverage**
   - Add core assets for common ecosystems and workflows:
     - JavaScript/TypeScript, Java, Go, C#, Rust
     - CI triage
     - dependency upgrades
     - release note generation
     - bug reproduction workflows
     - migration planning

## Execution Strategy

1. Build and lock a **core profile** first (minimal, safe defaults).
2. Extract and version **domain profiles** second.
3. Normalize frontmatter/tool schemas and revalidate.
4. Expand coverage for missing ecosystems/workflows.
5. Validate install behavior and quality after each phase.
