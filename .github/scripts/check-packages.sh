#!/usr/bin/env bash
# Check that every core Homebrew formula and cask in packages.yaml still exists upstream.
# Tap entries (owner/tap/name) are skipped: they are not in the formulae.brew.sh index.
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
src="$root/home"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

list() {
  chezmoi execute-template -S "$src" --override-data '{"isWork":true}' \
    "{{ range .packages.darwin.$1 }}{{ . }}
{{ end }}"
}

# Names plus aliases and renames, since packages.yaml may use any of them
curl -fsSL https://formulae.brew.sh/api/formula.json \
  | jq -r '.[] | .name, (.aliases // [])[], (.oldnames // [])[]' | sort -u > "$tmp/formulae"
curl -fsSL https://formulae.brew.sh/api/cask.json \
  | jq -r '.[] | .token, (.old_tokens // [])[]' | sort -u > "$tmp/casks"

failures=0
check() {
  local kind=$1 name=$2
  if [[ $name == */* ]]; then echo "  skip $name (tap)"; return; fi
  if grep -qxF "$name" "$tmp/$kind"; then echo "  ok   $name"; else echo "  FAIL $name (not in homebrew $kind)"; failures=$((failures + 1)); fi
}

for key in brews brw workBrews; do
  echo "== formulae: $key"
  while read -r name; do [ -n "$name" ] && check formulae "$name"; done < <(list "$key")
done
for key in casks workCasks; do
  echo "== casks: $key"
  while read -r name; do [ -n "$name" ] && check casks "$name"; done < <(list "$key")
done

echo
if [ "$failures" -gt 0 ]; then echo "$failures package(s) not found upstream"; exit 1; fi
echo "all packages found"
