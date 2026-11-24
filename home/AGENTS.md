## Communication

### Drafting rule
Always draft PR replies, review comments, commit messages, Linear updates, and any user-facing text for my approval BEFORE posting or committing. Never post to GitHub/Linear or run `git commit` without showing me the draft first.

## Writing style

Be concise by default. No em dashes. Prefer short paragraphs and bullet lists. A commit message gets a one-line subject and at most 3 bullets. Keep PR replies and docs to half the length you first think is right. I'll ask for more if I need it.

## How to start a task

### Investigation order
Before implementing or searching the codebase, confirm what I'm asking for. It's one of these: a design question, a review of existing work, or new implementation. Check whether an open PR or branch already covers it. State the repo you're operating in before you start exploring.

# General rules

- Do NOT modify existing working code unless explicitly asked. When fixing a bug or adding a feature, limit changes to the specific area requested.
- Prefer the simplest approach first. Don't add Pydantic validators, complex abstractions, or over-engineered solutions when a simple inline fix works. Ask before choosing between approaches if unclear.
- Run the formatter, linter and tests that CI runs before calling work done. Enable the repo's git hooks once per clone if it has them.
- Tests use temp directories, never real system paths. Anything that touches real user data needs my approval first and must be undoable.

# Code style

- Comment only what the code can't say. Don't write a comment or doc comment that restates a name or type, unless the package is a public API.
- Don't encode state in a nil pointer or an in-band sentinel such as `*bool`, `-1` or "zero means now". Use an explicit value, an enum or a set.
- Name flag and magic number literals instead of writing `0x2`.
- Run `/pstack:no-comments` on a branch's diff before opening a PR.

# Workflow

- Before making any changes, explain your hypothesis for the root cause and the evidence for it. Wait for confirmation before editing code.
- When asked to implement something, read the relevant code and propose a plan that names each file to change and the approach for it. Don't write any code until I approve the plan.
- When fixing a bug, first write a test that reproduces it and verify it fails. Then fix the code and verify the test passes. Do not modify any code that the failing test doesn't exercise.

# Git

- Commit subjects follow Conventional Commits, 72 characters at most. Add no trailers.
- Commit and branch from a git worktree, never the primary checkout, because other sessions may share it. A user-level hook blocks `git commit`, `git checkout -b` and `git switch -c` there.
- Commit with `git commit --only <paths>` so the commit includes only those paths.
- Messages say what the change does, not how it was tidied.
- Local notes stay untracked.

# Docker

- Use `host.docker.internal` instead of `localhost` to reach the host from a container on macOS and Windows.
- Always check that the Go version works with the target base image.
