#!/usr/bin/env bash
# GNU timeout isn't on macOS; catch it before the command fails.
cmd=$(jq -r '.tool_input.command // empty')
if grep -qE '(^|[;&|(])[[:space:]]*timeout[[:space:]]' <<<"$cmd"; then
  echo "timeout isn't installed on macOS. Use run_in_background, or a background job plus kill." >&2
  exit 2
fi
