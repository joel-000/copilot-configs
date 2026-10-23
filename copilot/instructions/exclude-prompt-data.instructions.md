---
description: "Write only resulting content in docs, code and config files. Never echo prompt instructions, rationale, or meta-commentary into files generated from a prompt."
applyTo: '**/*.{md,mdx,markdown,rst,adoc,txt,c,cc,cpp,cxx,cs,go,java,js,jsx,mjs,cjs,ts,tsx,py,rb,rs,php,swift,kt,kts,scala,sql,sh,bash,zsh,ps1,yaml,yml,json,toml,ini,cfg,conf,xml,html,css,scss,sass,less}'
---

# Exclude Prompt Data

Instructional or contextual data in a prompt must not appear in the file being updated, whether documentation, source code or configuration. Write only the *result* of the instruction, not the instruction, its rationale, or any acknowledgment that it was applied.

## What counts as prompt data

- Descriptions of what to add or change (`"add a --verbose flag that..."`)
- Inline rationale or motivation (`"because the old behavior caused..."`)
- References to the prompt (`"as requested"`, `"per the prompt"`, `"has been added as"`)
- Meta-commentary about the update (`"This section has been updated to reflect..."`)
- Code comments that narrate a change instead of describing the code (`"// Added email validation as requested"`)
- Scaffold labels used as template slots (the word `this` in `## this Title`)

## What belongs in the output

- The requested content, written as if it always belonged there and useful to a reader who never saw the prompt.
- Generic placeholder data in examples (`Jane Doe`, `jane.doe@example.com`, `Acme Corp`, `example.com`), never real names, emails, domains or organizations from the prompt or local configuration.
- The same formatting conventions the prompt uses for terms (e.g. backticks).

## Output quality

Choose the audience from the request and context. Follow any filename or format the user requests; otherwise default to `README.md` for human developers and `AGENTS.md` for coding agents. When both need a plan, keep a concise plain-English human summary separate from detailed agent steps. If the audience or output is unclear, ask.

Match detail to audience and purpose; prefer concise, scannable content. Output must be polished and production-ready (correct grammar and punctuation, no draft-quality prose) regardless of how casually the prompt was written.

## Example

Prompt: `Update file.ext with new feature --new-opt <argument>, documenting the new feature in features.md`

Acceptable `features.md` entry:

```text
### --new-opt

Enables extended output. Requires a value argument. Example:

    file --new-opt foo
```

Unacceptable: the same entry prefixed with "The new feature `--new-opt` requiring an argument has now been added as requested." That language belongs in the prompt, not the file.

Code comments and documentation are encouraged when they describe what code does, its constraints or its intent, never when they narrate the change or respond to the requester.

## Exceptions

- **Verbatim transcription requested:** insert exactly what was requested and nothing more.
- **The file is a prompt or instruction artifact** (prompt files, skills, instruction files): instructional content is the payload, but add no meta-commentary about the edit itself.
- **Changelog or release-note entries:** a short factual line about the change, not the request (`Added --verbose flag` ✓ / `Added --verbose flag as requested by user` ✗).

## Self-check before saving

Remove any of the following found in the diff, and rewrite so a fresh reader with no knowledge of the prompt finds it natural and self-contained:

- "as requested", "per the prompt", "per your instruction", "as you asked"
- Sentences that announce a change ("This section now covers...", "Updated to include...")
- Comments explaining why code was written instead of what it does
- Verbatim restatements of the request or any acknowledgment of the prompt
