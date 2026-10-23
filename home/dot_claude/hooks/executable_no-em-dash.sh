#!/usr/bin/env bash
# Blocks tool calls that would write an em dash. Exit 2 returns stderr to Claude.
input=$(cat)
tool=$(jq -r '.tool_name' <<<"$input")
text=$(jq -r '.tool_input | [.content, .new_string, (.edits // [] | .[].new_string), .command] | map(select(. != null)) | join("\n")' <<<"$input")

if [[ $tool == Bash && ! $text =~ (git\ commit|gh\ (pr|issue|api)) ]]; then
  exit 0
fi

if grep -q '—' <<<"$text"; then
  echo "Em dash found. Use a comma, colon, or parentheses instead." >&2
  exit 2
fi
