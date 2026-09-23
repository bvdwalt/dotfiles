#!/bin/bash
# Focus the Vivaldi window on a workspace, or open the profile there if none exists.
# Usage: vivaldi-profile.sh <profile-directory> <workspace>
profile="$1"
workspace="$2"
bundle="com.vivaldi.Vivaldi"

list() {
  aerospace list-windows "$@" --app-bundle-id "$bundle" --format '%{window-id}|%{window-title}' \
    | grep -viE '\|(Picture.in.Picture|PiP)$' | cut -d'|' -f1
}

id=$(list --workspace "$workspace" | head -1)
if [ -n "$id" ]; then
  aerospace focus --window-id "$id"
  exit 0
fi

before=$(list --all)
open -na /Applications/Vivaldi.app --args --profile-directory="$profile"
for _ in $(seq 20); do
  sleep 0.25
  new=$(list --all | grep -vxF "$before" | head -1)
  if [ -n "$new" ]; then
    aerospace move-node-to-workspace --window-id "$new" "$workspace"
    aerospace workspace "$workspace"
    exit 0
  fi
done
