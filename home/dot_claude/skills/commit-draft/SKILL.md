---
name: commit-draft
description: Write a conventional commit message based on staged changes and branch commits vs main, without committing
---

# Conventional Commit Message Skill

Write a conventional commit message for the current staged/unstaged changes. Print the message only — do not commit.

## Steps

1. Run the following in parallel to understand the full scope of changes:
   - `git diff --staged` — staged changes ready to commit
   - `git diff main..HEAD` — commits already on this branch but not yet on main
   - `git log --oneline -5` — match the repo's existing commit style
2. Do NOT look at unstaged changes — only staged changes and existing branch commits matter
3. Choose the appropriate type:
   - `feat` — new user-facing feature (triggers **minor** version bump)
   - `fix` — bug fix (triggers **patch** bump)
   - `perf` — performance improvement (triggers **patch** bump)
   - `refactor` — restructuring with no behaviour change (no bump)
   - `docs` — documentation only (no bump)
   - `test` — tests only (no bump)
   - `chore` — tooling, deps, config (no bump)
   - `ci` — CI/CD changes (no bump)
   - `style` — formatting/whitespace (no bump)
4. Add `!` after the type (e.g. `feat!`) or a `BREAKING CHANGE:` footer if the change breaks backwards compatibility (triggers **major** bump)
5. Optionally add a scope in parentheses to narrow the area: `feat(ui): ...`
6. Write a short, imperative description (max ~72 chars): what it does, not what you did
7. Add a body if the *why* isn't obvious from the description

## Output

Print the commit message as plain text — no code fences, no explanation, no filler.

If the changes are complex, also include a short body paragraph separated by a blank line.
