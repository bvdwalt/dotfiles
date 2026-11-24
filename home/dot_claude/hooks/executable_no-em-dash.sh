#!/usr/bin/env bash
# Blocks tool calls that would write an em or en dash. Exit 2 returns stderr to Claude.
dashes=$'\xe2\x80\x94|\xe2\x80\x93'
input=$(cat)
tool=$(jq -r '.tool_name' <<<"$input")

if [[ $tool == mcp__* ]]; then
  text=$(jq -r '[.tool_input | .. | strings] | join("\n")' <<<"$input")
else
  text=$(jq -r '.tool_input | [.content, .new_string, (.edits // [] | .[].new_string), .command] | map(select(. != null)) | join("\n")' <<<"$input")
fi

if [[ $tool == Bash ]]; then
  [[ $text =~ (git\ commit|gh\ (pr|issue|api)) ]] || exit 0
  # Also check files passed as a message or body, e.g. gh pr edit --body-file x.md, git commit -F x.txt
  while read -r f; do
    [[ -f $f ]] && text+=$'\n'$(cat "$f")
  done < <(grep -oE -- '(--body-file|--file|-F)[ =]+[^ ;&|]+' <<<"$text" | sed -E 's/^[^ =]+[ =]+//')
fi

if grep -qE "$dashes" <<<"$text"; then
  echo "Em or en dash found. Rewrite it as a period or comma, not parentheses." >&2
  grep -nE "$dashes" <<<"$text" | head -3 >&2
  exit 2
fi
