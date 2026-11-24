#!/usr/bin/env bash
# Blocks file edits done through shell scripts. Exit 2 returns stderr to Claude.
cmd=$(jq -r '.tool_input.command // empty')
# Message and body arguments may mention these commands without running them.
cmd=$(perl -0777 -pe "s/(?:^|\s)(?:-m|--message|--body|--title|-b|-t)\s+(?:\"(?:[^\"\\\\]|\\\\.)*\"|'[^']*')/ /g" <<<"$cmd")

block() {
  echo "Scripted file edit ($1). Change files with the Edit or Write tool. Writes under /tmp or /private/tmp are allowed." >&2
  exit 2
}

grep -qE '(^|[;&|(]|[[:space:]])sed[[:space:]]+(-[a-zA-Z]*i|--in-place)' <<<"$cmd" && block "sed -i"
grep -qE '(^|[;&|(]|[[:space:]])perl[[:space:]]+-[a-zA-Z]*i' <<<"$cmd" && block "perl -i"

if grep -qE '(^|[;&|(]|[[:space:]])python3?[[:space:]]' <<<"$cmd" &&
  grep -qE "open\([^)]*['\"][wa]\+?['\"]|\.write_text\(|\.write_bytes\(" <<<"$cmd"; then
  block "python file write"
fi

if grep -q '<<' <<<"$cmd"; then
  targets=$(
    grep -oE '(^|[^0-9&>])>>?[[:space:]]*[^&|;<>[:space:]]+' <<<"$cmd" | sed -E 's/^[^>]*>>?[[:space:]]*//'
    grep -oE 'tee[[:space:]]+(-a[[:space:]]+)?[^&|;<>[:space:]]+' <<<"$cmd" | sed -E 's/^tee[[:space:]]+(-a[[:space:]]+)?//'
  )
  while read -r t; do
    [[ -z $t || $t == /tmp/* || $t == /private/tmp/* || $t == /dev/* ]] && continue
    block "heredoc write to $t"
  done <<<"$targets"
fi
exit 0
