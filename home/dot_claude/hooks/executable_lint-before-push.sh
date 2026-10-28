#!/usr/bin/env bash
# Runs the repo's linters before git push / gh pr create so "lint is clean" claims are real.
input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
[[ $cmd =~ (git\ push|gh\ pr\ create) ]] || exit 0

cd "$(jq -r '.cwd' <<<"$input")" || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0

fail=0
if [[ -f go.mod ]] && command -v golangci-lint >/dev/null; then
  golangci-lint run ./... >&2 || fail=1
fi
if [[ -f pyproject.toml ]] && grep -q pyrefly pyproject.toml; then
  uv run pyrefly check >&2 || fail=1
fi
if [[ -f tsconfig.json && -x node_modules/.bin/tsc ]]; then
  node_modules/.bin/tsc --noEmit >&2 || fail=1
fi

if (( fail )); then
  echo "Lint/type check failed. Fix it before pushing." >&2
  exit 2
fi
