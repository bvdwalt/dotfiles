#!/usr/bin/env bash
# Another session can move the primary checkout's HEAD mid-task, so commits and new branches go in a worktree.
# Prefix the command with ALLOW_PRIMARY_CHECKOUT=1 to opt out.
input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
grep -qE '(^|[;&|(])[[:space:]]*ALLOW_PRIMARY_CHECKOUT=1[[:space:]]' <<<"$cmd" && exit 0

git_re='git[[:space:]]+(-C[[:space:]]+([^[:space:];&|]+)[[:space:]]+)?(commit|checkout[[:space:]]+-[bB]|switch[[:space:]]+-[cC])([[:space:]]|$)'
full_re="^((.*[;&|(])?)[[:space:]]*$git_re"
[[ $cmd =~ $full_re ]] || exit 0
before=${BASH_REMATCH[1]}
git_c=${BASH_REMATCH[4]}

# The git command runs in the last directory the command cd's into before it, or in its -C path.
resolve() {
  local d=${1//[\"\']/}
  d=${d/#\~/$HOME}
  [[ $d == /* ]] && echo "$d" || echo "$2/$d"
}
dir=${cwd:-$PWD}
last_cd=$(grep -oE '(^|[;&|(])[[:space:]]*cd[[:space:]]+[^;&|[:space:]]+' <<<"$before" | tail -1 | sed -E 's/.*cd[[:space:]]+//')
[[ -n $last_cd ]] && dir=$(resolve "$last_cd" "$dir")
[[ -n $git_c ]] && dir=$(resolve "$git_c" "$dir")

dirs=$(git -C "$dir" rev-parse --path-format=absolute --git-dir --git-common-dir 2>/dev/null) || exit 0
[[ $(sed -n 1p <<<"$dirs") != "$(sed -n 2p <<<"$dirs")" ]] && exit 0

echo "$dir is a primary checkout, which other sessions may share. Use EnterWorktree or 'git worktree add ../<name> -b <branch> main', then run this there. To commit here anyway, prefix the command with ALLOW_PRIMARY_CHECKOUT=1." >&2
exit 2
