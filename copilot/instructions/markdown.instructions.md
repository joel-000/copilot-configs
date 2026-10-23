---
description: 'Markdown formatting aligned to the CommonMark specification (0.31.2)'
applyTo: '**/*.md'
---

# CommonMark Markdown

Follow the [CommonMark spec 0.31.2](https://spec.commonmark.org/0.31.2/) when writing or reviewing `.md` files. It is a reference only; do not download it.

## Blocks

- **Headings:** ATX only: 1–6 `#` followed by a space, with a blank line before a following paragraph. Setext headings cannot interrupt a paragraph.
- **Code blocks:** Use fenced blocks with matching fence characters (backticks or tildes, not mixed) and a closing fence of at least the opening length. Specify a language identifier; a backtick fence's info string cannot contain backticks. Indented code (4+ spaces) cannot interrupt a paragraph.
- **Thematic breaks:** 3+ matching `-`, `_` or `*`.
- **Link reference definitions:** `[label]: destination "title"`. Labels are case-insensitive, the first definition wins, and they cannot interrupt a paragraph.
- **HTML blocks:** Type 7 (custom or inline-level tags) cannot interrupt a paragraph; precede it with a blank line.
- **Block quotes:** `>` prefix; lazy continuation applies to paragraph text only. A blank line separates consecutive quotes.
- **Lists:** Bullets (`-`, `+`, `*`) or ordered (1–9 digits + `.` or `)`). Indent sublists to the item's content column. Changing the bullet character or delimiter starts a new list. An ordered list interrupting a paragraph must start with `1`. A list is loose if any items are separated by blank lines.

## Inlines

- **Escapes and entities:** `\` before ASCII punctuation renders it literally; HTML5 entities (`&amp;`, `&#123;`) are valid. Neither applies inside code spans, code blocks or autolinks.
- **Code spans:** Backtick-delimited; one leading and trailing space is stripped when both are present.
- **Emphasis:** `*`/`_` for emphasis, `**`/`__` for strong. Use `*` for intraword emphasis; `_` only at word boundaries.
- **Links:** `[text](url "title")` or reference `[text][label]`, `[text][]`, `[text]`, with no whitespace between the text and `(` or `[`. Link text cannot contain other links. Use `<…>` around destinations with spaces; bare destinations need balanced parentheses.
- **Images:** `![alt](src "title")` with non-empty alt text.
- **Autolinks:** `<URI>` or `<email>` in angle brackets; bare URLs are not autolinked.
- **Raw HTML:** Tags, comments, processing instructions, declarations and CDATA pass through literally.
- **Line breaks:** Hard break is two or more trailing spaces or `\` (not at the end of a block, not in code spans or HTML tags). Otherwise a soft break renders as a space.
