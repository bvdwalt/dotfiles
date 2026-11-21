---
name: wt-clean
description: Find stale git worktrees and claude/* branches, classify them as prunable, merged, dirty or active, and remove the safe ones after confirmation. Use when the user asks to clean up worktrees or branches, or invokes /wt-clean. Pass `all` to sweep every repo under ~/src and the chezmoi repo.
---

# Worktree Cleanup Skill

Report stale worktrees and Claude-created branches, propose an action for each, and remove only what the user approves.

## Scope

- Default: the git repo containing the current directory (use the main worktree root: `git rev-parse --path-format=absolute --git-common-dir`, then its parent).
- `all`: every repo found by `find ~/src -maxdepth 3 -name .git -type d` plus `~/.local/share/chezmoi`. Skip repos with a single worktree and no candidate branches.

## Steps

1. Per repo, run in parallel:
   - `git fetch --prune --quiet`
   - `git worktree list --porcelain`
   - `git for-each-ref --format='%(refname:short) %(committerdate:relative) %(upstream:track)' refs/heads/claude/ refs/heads/worktree-`
   - Default branch: `git symbolic-ref --short refs/remotes/origin/HEAD` (strip `origin/`; fall back to `main`)
2. Candidates are every non-main worktree plus every `claude/*` and `worktree-*` branch, deduplicated by branch.
3. Classify each candidate, first match wins:
   - **Current**: the worktree this session runs in. Always skip.
   - **Prunable**: worktree directory no longer exists (porcelain shows `prunable`, or the path is missing).
   - **Dirty**: `git -C <path> status --porcelain` is non-empty. Flag, never remove.
   - **Unpushed**: branch has commits not on its upstream or has no upstream and is not merged. Flag, never remove.
   - **Merged**: no open PR, and either `gh pr list --head <branch> --state merged` returns a PR (squash-merge) or `git branch --merged origin/<default>` includes it. A merged PR wins over a recent commit date.
   - **Active**: open PR (`gh pr list --head <branch> --state open`) or last commit within 3 days. Keep.
   - Anything else is **Unknown**: flag for the user to decide.
4. Detached worktrees: classify by dirty state and whether `HEAD` is reachable from `origin/<default>` (`git merge-base --is-ancestor`).

## Output and confirmation

1. Show one table per repo: path, branch, state, PR number, last commit, proposed action.
   - Prunable: `git worktree prune`
   - Merged: `git worktree remove <path>` (if a worktree) then `git branch -D <branch>`, only after confirming the merge: `git merge-base --is-ancestor <branch> origin/<default>` succeeds, or a merged PR exists. Don't use `-d`: it compares against local `<default>`, which is often behind `origin`.
   - Dirty, Unpushed, Unknown: keep, with a one-line reason
2. Ask the user to confirm, or to name which rows to include or skip. Wait for explicit approval.
3. Once confirmed, run the approved actions. Never use `git worktree remove --force` or delete a Dirty or Unpushed branch, even if asked in bulk; ask again per item.
4. Report what was removed and what was kept, per repo. Stop and report on the first error in a repo, then continue with the next repo.
