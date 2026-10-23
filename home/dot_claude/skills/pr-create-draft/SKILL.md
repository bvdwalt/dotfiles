---
name: pr-create-draft
description: Create a draft GitHub PR with a concise description derived from branch commits, after confirmation
---

# PR Create Draft Skill

Derive a concise PR title and description from the branch commits, show it for confirmation, then run `gh pr create --draft`.

## Steps

1. Run the following in parallel to understand the full scope of changes:
   - `git status --short`: staged and unstaged changes
   - `git diff --staged`: changes to include in a new commit
   - `git log main..HEAD --oneline`: commits on this branch not yet on main
   - `git diff main..HEAD --stat`: files changed
   - `git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null`: upstream, if pushed
   - `gh pr list --state open --head $(git branch --show-current) 2>/dev/null`: check if a PR already exists
2. Handle uncommitted work:
   - If there are staged changes, draft a conventional commit message for them following ~/.claude/skills/commit-draft/SKILL.md. Include the staged changes in the PR title and body.
   - If there are only unstaged changes, ask which to include before continuing. Do not stage anything yourself.
3. If a PR already exists, report its URL and stop.
4. Derive the PR title:
   - Short, imperative, max ~72 chars
   - If a Linear ticket ID is in the branch name (e.g. `feature/prod-7450-...`), include it: `[PROD-7450] Title here`
5. Write the PR body with these sections only, keeping each section tight:
   - **What**: 2 to 4 bullet points describing what changed (not how)
   - **Why**: 1 to 2 sentences on motivation (omit if obvious from title)
   - **Testing**: how this was verified (unit/integration tests, manual steps)
6. Do NOT include a `🤖 Generated with Claude Code` footer.

## Output and confirmation

1. Show as plain text (no code fences), in this order:
   - The commit message, if step 2 drafted one
   - The PR title and body
2. Ask the user to confirm or request changes, then wait for explicit approval. One approval covers the commit, push, and PR.
3. Once confirmed, run in order, stopping on any failure:
   - If a commit message was drafted: `git commit` using a HEREDOC
   - `git push -u origin HEAD` (only if there is no upstream or the branch is ahead of it)
   - Create the PR:

```
gh pr create --draft --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

4. Print the resulting PR URL.
