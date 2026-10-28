#!/usr/bin/env bash
# Blocks commits and PRs whose subject isn't a Conventional Commit. Exit 2 returns stderr to Claude.
cmd=$(jq -r '.tool_input.command // empty')
grep -qE '(^|[;&|])[[:space:]]*NOCC=1[[:space:]]' <<<"$cmd" && exit 0
pattern='^(feat|fix|chore|docs|refactor|test|ci|build|perf|style|revert)(\([^)]+\))?!?: .+'

if [[ $cmd =~ gh\ pr\ create ]]; then
  flag='--title|-t'
elif [[ $cmd =~ git\ commit ]]; then
  flag='-m|--message'
else
  exit 0
fi

subject=$(perl -0ne 'if (/(?:^|\s)(?:'"$flag"')[ =]+(?:"\$\(cat <<.?EOF.?\s*\n)?["'\'']?\s*([^\n"'\'']*)/) { print $1 }' <<<"$cmd")
[[ -z $subject ]] && exit 0

if ! grep -qE "$pattern" <<<"$subject"; then
  echo "Subject \"$subject\" isn't a Conventional Commit (e.g. 'fix(api): handle empty body')." >&2
  exit 2
fi
