## Communication

### Drafting rule
Always draft PR replies, review comments, commit messages, Linear updates, and any user-facing text for my approval BEFORE posting or committing. Never post to GitHub/Linear or run `git commit` without showing me the draft first.

## Writing style

Be concise by default. Never use em dashes anywhere: chat, code, comments, commit messages, PR text, docs. Prefer short paragraphs and bullet lists. A commit message gets a one-line subject and at most 3 bullets. Keep PR replies and docs to half the length you first think is right. I'll ask for more if I need it.

## How to start a task

### Investigation order
Before implementing or searching the codebase, confirm what I'm asking for. It's one of these: a design question, a review of existing work, or new implementation. Check whether an open PR or branch already covers it. State the repo you're operating in before you start exploring.

# General rules

- Do NOT modify existing working code unless explicitly asked. When fixing a bug or adding a feature, limit changes to the specific area requested.
- Prefer the simplest approach first. Don't add Pydantic validators, complex abstractions, or over-engineered solutions when a simple inline fix works. Ask before choosing between approaches if unclear.
- Change files with the Edit and Write tools, not python, sed, or heredoc scripts. Scripted edits skip review and add permission prompts.
- Run the formatter, linter and tests that CI runs before calling work done. Enable the repo's git hooks once per clone if it has them.
- Tests use temp directories, never real system paths. Anything that touches real user data needs my approval first and must be undoable.

# Code style

- Comment only what the code can't say, in one line by default. Don't write a comment or doc comment that restates a name or type, unless the package is a public API. Never describe the change ("added X", "now uses Y").
- Don't encode state in a nil pointer or an in-band sentinel such as `*bool`, `-1` or "zero means now". Use an explicit value, an enum or a set.
- Name flag and magic number literals instead of writing `0x2`.
- Run `/pstack:no-comments` on a branch's diff before opening a PR.

# Workflow

- Before making any changes, explain your hypothesis for the root cause and the evidence for it. Wait for confirmation before editing code.
- When asked to implement something, read the relevant code and propose a plan that names each file to change and the approach for it. Don't write any code until I approve the plan.
- When fixing a bug, first write a test that reproduces it and verify it fails. Then fix the code and verify the test passes. Do not modify any code that the failing test doesn't exercise.
- When a subagent implements a change, its brief requires it to quote the failing test output before the fix. Check that output before accepting the work.

# Git

- Commit subjects follow Conventional Commits, 72 characters at most. Add no trailers.
- Commit and branch from a git worktree, never the primary checkout, because other sessions may share it. A user-level hook blocks `git commit`, `git checkout -b` and `git switch -c` there.
- Commit with `git commit --only <paths>` so the commit includes only those paths.
- Messages say what the change does, not how it was tidied.
- Local notes stay untracked.
- Keep PRs independent. Never cherry-pick commits between PR branches. Ask which PR a change belongs in.
- PR titles follow Conventional Commits. The `NOCC=1` prefix skips the commit hook. Use it only when I ask for a non-conventional message.
- Before saying a PR is merged or CI is green, check with `gh pr view` or `gh pr checks`.
- Run `git push` and `gh pr create/edit/comment/merge` as their own Bash call, not chained after checks or `cd`, so my approval prompt shows only that action.

# Verification

- Run the linters and type checkers that CI uses. Quote their output before claiming code is clean.
- For anything that writes to a live system or external data, dry-run first and show me the planned changes.

# Environment

- `brw` is my own Homebrew-compatible client, not a typo for `brew`.
- GNU `timeout` isn't installed on macOS. Use a background job instead.
- The homelab is Flux-managed Kubernetes. Check the kubectl context first, and make changes through homelab repo PRs, not by hand.
- In frontend code, use Tailwind spacing tokens, not arbitrary values like `pl-[42px]`.

# Docker

- Use `host.docker.internal` instead of `localhost` to reach the host from a container on macOS and Windows.
- Always check that the Go version works with the target base image.

# Rules and what enforces them

When I correct a mistake, add or update its row. If the rule was already here with nothing enforcing it, enforce it in the same change. Drop a row once its mistake can't happen.

| Rule | Enforced by |
| --- | --- |
| No em or en dashes in commits, PR text, gh comments or Linear posts | `~/.claude/hooks/no-em-dash.sh` blocks the call |
| Change files with Edit or Write, not `sed -i`, `perl -i`, python writes or heredocs | `~/.claude/hooks/no-scripted-edits.sh` blocks the call |
| Commit and branch only from a worktree | `~/.claude/hooks/primary-checkout.sh` |
| Conventional Commits subjects | `~/.claude/hooks/check-conventional.sh` |
| No GNU `timeout` | `~/.claude/hooks/no-gnu-timeout.sh` |
| Show drafts before posting or pushing | `ask` permissions on `git push`, `gh pr create/edit/comment/review` and `gh api` writes |
| Push and PR commands run as their own Bash call | Nothing. It's a judgment call. |
| hadrian-platform needs .NET SDK 10 | SessionStart hook in `~/src/work/.agents/.claude/settings.local.json` sets `DOTNET_ROOT` and `PATH` |
| Failing test first, including in subagent briefs | Nothing. It's a judgment call. |
| Run `/pstack:no-comments` before a PR | Nothing. It's a judgment call. |
