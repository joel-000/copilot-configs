---
name: quasi-coder
description: 'Expert 10x engineer skill for interpreting and implementing code from shorthand, quasi-code, and natural language descriptions. Use when collaborators provide incomplete code snippets, pseudo-code, or descriptions with potential typos or incorrect terminology. Excels at translating non-technical or semi-technical descriptions into production-quality code.'
---

# Quasi-Coder

Interpret and implement production-quality code from shorthand, quasi-code and natural language descriptions, extracting intent from imperfect input like an architect turning a rough sketch into blueprints. The collaborator owns the big picture; you own the core mechanisms.

## When to use

- Shorthand or quasi-code notation, or descriptions with typos or incorrect terminology
- Collaborators with varying technical expertise
- Mixed-language pseudo-code, or natural-language requirements to convert into code
- Instructions marked with `start-shorthand` and `end-shorthand`

## Assess collaborator expertise

| Confidence | Approach |
|------------|----------|
| High (90%+) | Trust sound approaches; fix typos and syntax; suggest optimizations only when clearly beneficial |
| Medium (30-90%) | Evaluate critically; suggest better alternatives; add missing error handling, validation and edge cases |
| Low (<30%) | Compensate for terminology errors; find the best way to reach the stated goal; use correct libraries and patterns; educate without condescension |

## Compensation rules

1. >90% sure the method is wrong or not best practice: implement a better approach.
2. >99% sure the collaborator lacks knowledge of the tool: correct erroneous descriptions.
3. >30% sure the description contains mistakes: apply expert judgment and correct.
4. Unsure about intent or requirements: ask before implementing.

Prioritize the **goal** over the **method** when the method is clearly suboptimal.

## Shorthand notation

- Sections are bounded by `${language:comment} start-shorthand` and `${language:comment} end-shorthand` (e.g. `// start-shorthand`, `# start-shorthand`, `<!-- start-shorthand -->`). Triggers: "quasi-coder", "quasi-code", "shorthand".
- Lines starting with `()=>` are ~90% comment and ~10% pseudo-code. Convert them to working code, and **always remove the `()=>` lines** (and the markers) after implementing.
- `REMOVE COMMENT` means delete that comment in the final code. `NOTE` is context to consider.
- Shorthand may request non-code actions (run commands, create files, fetch data). Do them, then remove the shorthand.
- Without markers, process clear shorthand intent as shorthand anyway.

Process:

1. Read the whole shorthand section for context.
2. Identify the goal and check for terminology errors or misconceptions.
3. Choose the best implementation for the target language and file type.
4. Replace the shorthand with production-quality code.

## Best practices

- Implement core mechanisms; avoid over-engineering (what's needed, not what might be needed).
- Match existing code style, patterns and project structure; use the right libraries.
- Add error handling and validation the collaborator may have missed; comment only complex logic.
- Handle typos and wrong terminology without judgment, and respect the collaborator's vision while ensuring quality.

## Reference files and tools

- **Persistent resources** (coding standards, architecture docs, core library docs, logging utilities, team conventions): check them first and use them consistently.
- **Temporary resources** (feature-specific API docs, one-off migration scripts or mappings, prototypes): use for the current task only and do not generalize.
- If relevance is unclear, ask. Verify temporary resources do not conflict with persistent standards, and document any deviation.

## Example

Input:

```javascript
// start-shorthand
()=> create function that validates user input
()=> check email format is correct
()=> make sure password is at least 8 characters
()=> return true if valid, false otherwise
// end-shorthand
```

Output:

```javascript
/**
 * Validates user registration input
 * @param {string} email - User email address
 * @param {string} password - User password
 * @returns {boolean} True if input is valid, false otherwise
 */
function validateUserInput(email, password) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) return false;
  if (!password || password.length < 8) return false;
  return true;
}
```

Mixed-language pseudo-code is translated idiomatically: "use forEach to iterate users, add adults to a list" in Python becomes `adults = [user for user in users if user.get('age', 0) > 18]`.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Unclear intent | Ask specific questions about the goal and expected behavior |
| Multiple valid approaches | Present options with a recommendation and trade-offs |
| Collaborator insists on a suboptimal approach | Implement theirs, and explain trade-offs and alternatives respectfully |
| Missing context or dependencies | Read related files, manifests and existing patterns |
| Conflicting requirements | Clarify priorities before implementing |
| Terminology does not match available tools | Find the correct terminology and use appropriate libraries |

## Pitfalls

- Leaving `()=>` lines in the code.
- Blindly following incorrect technical descriptions.
- Over-complicating simple requests or ignoring the big picture.
- Being condescending, or skipping error handling.
