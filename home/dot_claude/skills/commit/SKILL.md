---
name: commit
description: Write a conventional commit message and commit the staged changes after confirmation
---

# Conventional Commit Skill

Write a conventional commit message for the staged changes, then run `git commit` after confirmation.

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

## Output and confirmation

1. Show the proposed commit message as plain text (no code fences)
2. Ask the user to confirm before committing — wait for explicit approval
3. Once confirmed, run `git commit` using a HEREDOC to pass the message:

```
git commit -m "$(cat <<'EOF'
<subject>

<body if any>
EOF
)"
```

4. Report success or any error from git
