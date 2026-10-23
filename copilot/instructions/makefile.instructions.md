---
description: "Best practices for authoring GNU Make Makefiles"
applyTo: "**/Makefile,**/makefile,**/*.mk,**/GNUmakefile"
---

# Makefile Development Instructions

Write clear, maintainable, portable GNU Make makefiles ([manual](https://www.gnu.org/software/make/manual/)).

## Structure and naming

- Name the file `Makefile`; use `GNUmakefile` only for GNU-specific features.
- Order: header comment (purpose, usage, variables), variables, default goal (first rule, the most common build), rules, phony targets.
- Use descriptive target names (`clean`, `install`, `test`) and uppercase for conventional variables (`CC`, `CFLAGS`, `LDFLAGS`, `PREFIX`).
- Comment complex rules and non-obvious behavior.

## Variables

- `:=` for immediate (simple) expansion, `=` for recursive expansion, `?=` for overridable defaults, `+=` to append.
- Reference with `$(VAR)`, not `$VAR`.
- Use automatic variables (`$@`, `$<`, `$^`, `$?`, `$*`) to keep rules generic.
- Override implicit-rule variables (`CC`, `CFLAGS`) instead of rewriting built-in rules.

## Rules and recipes

- Recipe lines start with a **tab** (unless `.RECIPEPREFIX` is set).
- List all real prerequisites for correct rebuilds; avoid circular dependencies.
- Use order-only prerequisites (after `|`) for directories; they are omitted from `$^`, so reference them explicitly if needed.
- Use pattern rules (`%.o: %.c`) for generic transformations; define custom ones only when built-in rules are insufficient.
- Use `@` to suppress echo and `-` to ignore errors sparingly. Chain commands that must run together with `&&` and split long commands with `\`.
- Keep recipes short; move complex shell logic into script files.

```makefile
CC ?= gcc
CFLAGS = -Wall -Wextra -O2
PREFIX ?= /usr/local
objects = main.o utils.o
deps = $(objects:.o=.d)

.PHONY: all clean install

all: program

program: $(objects)
	$(CC) -o $@ $^

obj/%.o: %.c | obj
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

obj:
	mkdir -p obj

clean:
	-rm -f program $(objects) $(deps)

install: program
	install -d $(PREFIX)/bin
	install -m 755 program $(PREFIX)/bin

-include $(deps)
```

## Phony and special targets

- Declare non-file targets (`all`, `clean`, `test`, `install`) with `.PHONY`; always provide `clean` (and `distclean` if needed).
- `.DELETE_ON_ERROR:` removes targets when a recipe fails; `.SECONDARY`/`.PRECIOUS` keep intermediate files.

## Line splitting

- Backslash-newline becomes a single space outside recipes. To join without whitespace, use `$ ` before the backslash: `var := one$ \` then `word` yields `oneword`.
- No trailing whitespace after a backslash.

## Includes, conditionals, dependencies

- `include` for shared definitions; `-include` for optional files (including generated `.d` dependency files from `-MMD -MP`).
- Put conditionals (`ifeq`, `ifdef`, ...) at makefile level, not inside recipes (use shell conditionals there).
- Validate required tools and variables early with `$(error ...)`.

## Debugging and performance

- Dry run with `make -n`, print the database with `make -p`, force a rebuild with `make -B`.
- Prefer `:=` and avoid unnecessary `$(shell ...)`; use `$(wildcard ...)` rather than `$(shell ls ...)`.
- Make targets safe for `make -j`.

## Anti-patterns

- Spaces instead of tabs in recipes.
- Missing `.PHONY` declarations.
- Hardcoded file lists that could use wildcards or functions.
- Recursive make (`$(MAKE) -C`) unless necessary.
- GNU-only features when portability is required without documenting them.
