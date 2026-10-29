## Communication

### Drafting Rule
Always draft PR replies, review comments, commit messages, Linear updates, and any user-facing text for my approval BEFORE posting or committing. Never post to GitHub/Linear or run `git commit` without showing me the draft first.

## Writing Style

Be concise by default. Never use em dashes (—) anywhere: chat, code, comments, commit messages, PR text, docs. Use a comma, colon, or parentheses instead. Prefer short paragraphs and bullet lists. For commit messages: one-line subject plus at most 3 bullets. For PR replies and docs: aim for half the length you first think is right, then let me ask for more.

## How to Start a Task

### Investigation Order
Before implementing or searching the codebase, confirm what I'm actually asking for: a design question, a review of existing work, or new implementation. Check whether an open PR/branch already covers it. State the repo you're operating in before you start exploring.

# General Rules

- Do NOT modify existing working code unless explicitly asked. When fixing a bug or adding a feature, limit changes to the specific area requested.
- Prefer the simplest approach first. Don't add Pydantic validators, complex abstractions, or over-engineered solutions when a simple inline fix suffices. Ask before choosing between approaches if unclear.
- Change files with the Edit/Write tools, not python/sed/heredoc scripts. Scripted edits skip review and add permission prompts.
- Code comments: only when the why is non-obvious. One line by default. Never restate what the code does or describe the change ("added X", "now uses Y").

# Workflow

- Before making any changes, explain your hypothesis for the root cause and what evidence supports it. Wait for confirmation before editing code.
- When asked to implement something, read the relevant code and propose an implementation plan with specific files to change and the approach for each. Don't write any code until the plan is approved.
- When fixing a bug, first write a test that reproduces it and verify it fails. Then fix the code and verify the test passes. Do not modify any code that the failing test doesn't exercise.

# Git

- Do NOT add a `Co-Authored-By: Claude` trailer to commit messages.
- Do NOT add a `Claude-Session:` link trailer to commit messages or PR descriptions.
- Keep PRs independent: never cherry-pick commits between PR branches. Ask which PR a change belongs in.
- PR titles follow Conventional Commits. Only prefix a commit with `NOCC=1` (skips the hook) when I ask for a non-conventional message.
- Before saying a PR is merged or CI is green, check with `gh pr view` or `gh pr checks`.

# Verification

- Run the linters and type checkers CI uses and quote the actual output before claiming code is clean.
- For anything that writes to a live system or external data, dry-run first and show me the planned changes.

# Environment

- `brw` is my own Homebrew-compatible client, not a typo for `brew`.
- macOS: GNU `timeout` isn't installed; use a background job instead.
- Homelab is Flux-managed Kubernetes: check the kubectl context first, and make changes through homelab repo PRs, not by hand.
- Frontend: use Tailwind spacing tokens, not arbitrary values like `pl-[42px]`.

# Docker

- When working with Docker containers, use `host.docker.internal` instead of `localhost` for host-to-container networking on macOS/Windows. Always verify Go version compatibility with the target base image.
