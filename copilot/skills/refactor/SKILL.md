---
name: refactor
description: 'Surgical code refactoring to improve maintainability without changing behavior. Covers extracting functions, renaming variables, breaking down god functions, improving type safety, eliminating code smells, and applying design patterns. Less drastic than repo-rebuilder; use for gradual improvements.'
license: MIT
---

# Refactor

Improve structure and readability without changing external behavior. Refactoring is gradual evolution, not a rewrite.

## When to use

- Code is hard to understand or maintain, or functions/classes are too large
- Code smells need addressing or structure makes adding features difficult
- The user asks to "clean up", "refactor" or "improve" code

## Golden rules

1. Preserve behavior; change how the code works, not what it does.
2. Take small steps and test after each.
3. Commit before and after each safe state.
4. Without tests you are editing, not refactoring; add tests first for untested critical code.
5. Do one thing at a time; do not mix refactoring with feature changes.
6. Prefer the simplest structure; follow the repository's abstraction rules.

Do not refactor code that works and will not change again, or without a clear purpose.

## Code smells and fixes

| Smell | Fix |
|-------|-----|
| Long method | Extract focused functions; the top-level function reads as a sequence of named steps |
| Duplicated code | Extract the shared logic into one function or lookup table |
| Large class/module (god object) | Split by responsibility (e.g. `UserService`, `EmailService`, `PaymentService`) |
| Long parameter list | Introduce a parameter object or typed interface; builder for complex construction |
| Feature envy | Move logic to the object that owns the data |
| Primitive obsession | Introduce domain types (`Email`, `PhoneNumber`) that validate on construction |
| Magic numbers/strings | Named constants, enums or `as const` objects |
| Nested conditionals | Guard clauses and early returns; a Result type for multi-step validation |
| Dead code | Delete unused functions, imports and commented-out code; git history keeps it |
| Inappropriate intimacy | Tell, don't ask: call methods (`order.getShippingAddress()`) instead of reaching through `order.user.profile.address` |
| Conditional logic per variant | Strategy pattern (one class or function per variant) |
| Sequential validation branches | Chain of responsibility or a list of validator functions |
| Untyped code | Add types for public APIs, union types for fixed sets (`'bronze' \| 'silver' \| 'gold'`), explicit nullables, and input checks; avoid `any` |

Example of extracting a method and using guard clauses:

```diff
- function process(order) {
-   if (order) {
-     if (order.user && order.user.isActive) {
-       return order.total > 0 ? processOrder(order) : { error: 'Invalid total' };
-     }
-   }
- }
+ function process(order) {
+   if (!order) return { error: 'No order' };
+   if (!order.user?.isActive) return { error: 'User inactive' };
+   if (order.total <= 0) return { error: 'Invalid total' };
+   return processOrder(order);
+ }
```

## Process

1. **Prepare:** ensure tests exist, commit the current state, work on a branch.
2. **Identify:** find the smell, understand what the code does, plan the change.
3. **Refactor in small steps:** change one thing, run tests, commit if green, repeat.
4. **Verify:** all tests pass, manual testing if needed, performance unchanged or better.
5. **Clean up:** update comments and documentation.

## Checklist

- [ ] Functions are small and do one thing
- [ ] No duplication, magic values or dead code
- [ ] Descriptive names
- [ ] Related code is together; clear module boundaries; dependencies flow one way; no cycles
- [ ] Public APIs are typed; no unjustified `any`; nullables explicit
- [ ] Refactored code is tested, including edge cases, and all tests pass

## Common operations

Extract Method/Class/Interface, Inline Method/Class, Pull Up/Push Down Method, Rename, Introduce Parameter Object, Replace Conditional with Polymorphism, Replace Magic Number with Constant, Decompose/Consolidate Conditional, Replace Nested Conditional with Guard Clauses, Introduce Null Object, Replace Type Code with Class/Enum, Replace Inheritance with Delegation.
