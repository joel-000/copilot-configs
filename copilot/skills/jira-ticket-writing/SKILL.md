---
name: jira-ticket-writing
description: Use when drafting, editing, or reviewing Jira Story tickets that require a description, Fibonacci story points, definition of done, and acceptance criteria.
---

# Jira Story Ticket Writing

Use this skill to produce a Jira Story that a product manager, developer, and QA
tester can understand without relying on the original conversation.

## Gather the required information

Before drafting, identify:

- the primary user or role affected by the change
- the user or business problem and the intended outcome
- the scope, including meaningful exclusions
- dependencies, assumptions, links, or design references
- the observable conditions that prove the work is complete
- uncertainty that prevents a clear, testable ticket

Infer the primary user or role from the context when it is clear. Ask one
focused question at a time when it is not. Do not invent product decisions,
business rules, or technical constraints.

## Write the ticket

Use concise, plain language. Describe the desired behavior and value before
implementation details. Place technical constraints, dependencies, and useful
links in the description only when they help delivery.

Write a specific title in active voice without a trailing period. Start the
description with a user story:

> As a `<user>`, I want `<goal>` so that `<benefit>`.

Use the directly affected role when the work has no external end user, such as
a support agent, operations engineer, administrator, or developer.

## Estimate story points

Recommend a Fibonacci estimate based on relative complexity, uncertainty, and
delivery risk. State the estimate and a short rationale; the team makes the
final commitment.

| Points | Typical scope |
| --- | --- |
| 1 | Small, well-understood change with low risk |
| 2 | Limited change with a straightforward dependency or verification need |
| 3 | Standard story affecting a focused workflow or component |
| 5 | Multi-part change with notable edge cases or coordination |
| 8 | Significant uncertainty, integration, or cross-component impact; consider splitting |
| 13 | Too large or uncertain for a single story; split or refine before starting |

## Define completion

The definition of done is the shared delivery checklist for the Story. Include
the following items unless the team supplies an approved alternative:

- Acceptance criteria are met.
- Automated and relevant manual tests pass.
- Required documentation is updated.
- Code review is approved.
- The work is deployed or ready for release according to the team's process.

## Write acceptance criteria

Acceptance criteria describe outcomes, not implementation steps. Each item must
be independently observable and testable by a person or automated check.

- Use plain, unambiguous language and measurable thresholds where relevant.
- Cover the primary behavior and at least one relevant error, empty, boundary,
  or fallback condition.
- Start with the actor or system when it improves clarity.
- Keep criteria scoped to the Story. Split the Story when the list becomes
  difficult to understand or validate.
- Use Given/When/Then only when it makes behavior clearer; do not force it.

## Output format

```markdown
# <Specific Story title>

## Description
As a <user>, I want <goal> so that <benefit>.

### Context
<Why this work matters and the intended outcome.>

### Scope
<Included behavior, relevant constraints, dependencies, and exclusions.>

## Story points
<1 | 2 | 3 | 5 | 8 | 13>

Rationale: <Relative complexity, uncertainty, and risk.>

## Definition of done
- [ ] Acceptance criteria are met.
- [ ] Automated and relevant manual tests pass.
- [ ] Required documentation is updated.
- [ ] Code review is approved.
- [ ] The work is deployed or ready for release according to the team's process.

## Acceptance criteria
- <Observable, testable primary outcome.>
- <Observable, testable secondary outcome.>
- <Observable, testable error, empty, boundary, or fallback outcome.>
```

## Review before presenting

Confirm that:

- the title, description, and acceptance criteria describe the same scope
- the description explains why the Story matters without becoming a technical
  design document
- the story-point recommendation matches the stated complexity and uncertainty
- every acceptance criterion has an observable pass or fail result
- the definition of done and acceptance criteria are separate: one is a
  delivery checklist, the other defines Story-specific behavior
