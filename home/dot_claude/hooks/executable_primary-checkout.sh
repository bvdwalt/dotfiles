#!/usr/bin/env bash
# Another session can move the primary checkout's HEAD mid-task, so commits and new branches go in a worktree.
# Prefix the command with ALLOW_PRIMARY_CHECKOUT=1 to opt out.
input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
grep -qE '(^|[;&|(])[[:space:]]*ALLOW_PRIMARY_CHECKOUT=1[[:space:]]' <<<"$cmd" && exit 0
grep -qE '(^|[;&|(])[[:space:]]*git[[:space:]]+(commit|checkout[[:space:]]+-[bB]|switch[[:space:]]+-[cC])([[:space:]]|$)' <<<"$cmd" || exit 0

dirs=$(git -C "${cwd:-.}" rev-parse --path-format=absolute --git-dir --git-common-dir 2>/dev/null) || exit 0
[[ $(sed -n 1p <<<"$dirs") != "$(sed -n 2p <<<"$dirs")" ]] && exit 0

echo "This is the primary checkout, which other sessions may share. Use EnterWorktree or 'git worktree add ../<name> -b <branch> main', then run this there. To commit here anyway, prefix the command with ALLOW_PRIMARY_CHECKOUT=1." >&2
exit 2
