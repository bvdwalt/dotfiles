## Communication

### Drafting Rule
Always draft PR replies, review comments, commit messages, Linear updates, and any user-facing text for my approval BEFORE posting or committing. Never post to GitHub/Linear or run `git commit` without showing me the draft first.

## Writing Style

Be concise by default. No em dashes. Prefer short paragraphs and bullet lists. For commit messages: one-line subject plus at most 3 bullets. For PR replies and docs: aim for half the length you first think is right, then let me ask for more.

## How to Start a Task

### Investigation Order
Before implementing or searching the codebase, confirm what I'm actually asking for: a design question, a review of existing work, or new implementation. Check whether an open PR/branch already covers it. State the repo you're operating in before you start exploring.

# General Rules

- Do NOT modify existing working code unless explicitly asked. When fixing a bug or adding a feature, limit changes to the specific area requested.
- Prefer the simplest approach first. Don't add Pydantic validators, complex abstractions, or over-engineered solutions when a simple inline fix suffices. Ask before choosing between approaches if unclear.

# Workflow

- Before making any changes, explain your hypothesis for the root cause and what evidence supports it. Wait for confirmation before editing code.
- When asked to implement something, read the relevant code and propose an implementation plan with specific files to change and the approach for each. Don't write any code until the plan is approved.
- When fixing a bug, first write a test that reproduces it and verify it fails. Then fix the code and verify the test passes. Do not modify any code that the failing test doesn't exercise.

# Git

- Do NOT add a `Co-Authored-By: Claude` trailer to commit messages.

# Docker

- When working with Docker containers, use `host.docker.internal` instead of `localhost` for host-to-container networking on macOS/Windows. Always verify Go version compatibility with the target base image.
