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
- Write a code comment only when the why is non-obvious. Keep it to one line by default. Never restate what the code does or describe the change ("added X", "now uses Y").

# Workflow

- Before making any changes, explain your hypothesis for the root cause and the evidence for it. Wait for confirmation before editing code.
- When asked to implement something, read the relevant code and propose a plan that names each file to change and the approach for it. Don't write any code until I approve the plan.
- When fixing a bug, first write a test that reproduces it and verify it fails. Then fix the code and verify the test passes. Do not modify any code that the failing test doesn't exercise.

# Git

- Do NOT add a `Co-Authored-By: Claude` trailer to commit messages.
- Do NOT add a `Claude-Session:` link trailer to commit messages or PR descriptions.
- Keep PRs independent. Never cherry-pick commits between PR branches. Ask which PR a change belongs in.
- PR titles follow Conventional Commits. The `NOCC=1` prefix skips the commit hook. Use it only when I ask for a non-conventional message.
- Before saying a PR is merged or CI is green, check with `gh pr view` or `gh pr checks`.

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
