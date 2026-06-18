---
description: 'Write only resulting implementation content in code and config files. Never leak prompt framing, rationale, or response-style narration into source output.'
applyTo: '**/*.{c,cc,cpp,cxx,cs,go,java,js,jsx,mjs,cjs,ts,tsx,py,rb,rs,php,swift,kt,kts,scala,sql,sh,bash,zsh,ps1,yaml,yml,json,toml,ini,cfg,conf,xml,html,css,scss,sass,less}'
---

# Exclude Prompt Data (Code and Config)

When editing source code or configuration from a prompt, write only the resulting implementation.

## Core Rule

> **Never echo prompt content into the file being changed.**

Do not include wording such as "as requested", "per the prompt", or change-narration comments.

## Allowed Content

- Behavior, logic, schemas, and configuration that satisfy the request
- Comments that explain code behavior, constraints, or non-obvious intent
- Neutral placeholders in examples (`example.com`, `Jane Doe`)

## Disallowed Content

- Prompt acknowledgments or response-like prose in code comments
- Meta-commentary about why an edit was made
- Verbatim restatement of the request unless explicitly asked

## Examples

### Good

```typescript
function createUser(name: string, email: string) {
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new Error('Invalid email address.');
  }
  // Continue with persistence.
}
```

### Bad

```typescript
// Added email validation as requested by the prompt
function createUser(name: string, email: string) {
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new Error('Invalid email address.');
  }
}
```

## Quick Diff Check

- [ ] Remove "as requested", "per prompt", "per instruction" phrasing
- [ ] Remove comments that narrate the edit itself
- [ ] Keep only implementation-facing content
