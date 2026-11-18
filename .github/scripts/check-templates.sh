#!/usr/bin/env bash
# Render every chezmoi template for each platform case and lint the output.
# Usage: check-templates.sh [case...]   (default: all cases)
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
src="$root/home"
out=${OUT_DIR:-$(mktemp -d)}

declare -A cases=(
  [darwin-work]='{"isArch":false,"isFedora":false,"isWork":true,"chezmoi":{"os":"darwin"}}'
  [darwin-personal]='{"isArch":false,"isFedora":false,"isWork":false,"chezmoi":{"os":"darwin"}}'
  [fedora]='{"isArch":false,"isFedora":true,"isWork":false,"chezmoi":{"os":"linux","osRelease":{"id":"fedora","idLike":"","versionID":"43"}}}'
  [asahi]='{"isArch":false,"isFedora":true,"isWork":false,"chezmoi":{"os":"linux","osRelease":{"id":"fedora-asahi-remix","idLike":"fedora","versionID":"42"}}}'
  [arch]='{"isArch":true,"isFedora":false,"isWork":false,"chezmoi":{"os":"linux","osRelease":{"id":"arch","idLike":""}}}'
  [cachyos]='{"isArch":true,"isFedora":false,"isWork":true,"chezmoi":{"os":"linux","osRelease":{"id":"cachyos","idLike":"arch"}}}'
)

if [ $# -gt 0 ]; then selected=("$@"); else mapfile -t selected < <(printf '%s\n' "${!cases[@]}" | sort); fi

have_shellcheck=true
command -v shellcheck >/dev/null || { have_shellcheck=false; echo "warning: shellcheck not found, skipping it" >&2; }
have_fish=true
command -v fish >/dev/null || { have_fish=false; echo "warning: fish not found, skipping fish -n" >&2; }

failures=0
fail() { echo "  FAIL $*"; failures=$((failures + 1)); }

# Lint one deployed file; empty output means the template skipped this platform.
lint() {
  local file=$1 name=$2
  [ -n "$(tr -d '[:space:]' < "$file")" ] || return 0
  case $name in
    *.sh)
      bash -n "$file" || fail "bash -n: $name"
      if $have_shellcheck; then shellcheck -S warning -s bash "$file" || fail "shellcheck: $name"; fi ;;
    *.fish)
      if $have_fish; then fish -n "$file" || fail "fish -n: $name"; fi ;;
    *.json)
      jq empty "$file" || fail "invalid json: $name" ;;
  esac
}

for c in "${selected[@]}"; do
  data=${cases[$c]:?unknown case $c}
  echo "== $c"
  dir="$out/$c"
  mkdir -p "$dir"

  work=$(jq -r .isWork <<<"$data")
  chezmoi execute-template -S "$src" --init --promptBool "Is this a work machine=$work" \
    < "$src/.chezmoi.toml.tmpl" > "$dir/chezmoi.toml" || fail "render: .chezmoi.toml.tmpl"

  while IFS= read -r -d '' f; do
    rel=${f#"$src"/}
    dest="$dir/${rel%.tmpl}"
    mkdir -p "$(dirname "$dest")"
    if [[ $f == *.tmpl ]]; then
      chezmoi execute-template -S "$src" --override-data "$data" < "$f" > "$dest" 2> "$dest.err" \
        || { fail "render: $rel"; cat "$dest.err"; continue; }
    else
      cp "$f" "$dest"
    fi
    lint "$dest" "${rel%.tmpl}"
  done < <(find "$src" -type f \( -name '*.tmpl' -o -name '*.sh' -o -name '*.fish' -o -name '*.json' \) \
             ! -name '.chezmoi.toml.tmpl' ! -path '*/dot_config/nvim/*' -print0)
done

echo
if [ "$failures" -gt 0 ]; then echo "$failures check(s) failed (rendered output in $out)"; exit 1; fi
echo "all checks passed"
