#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Toggle Caffeinate
# @raycast.mode compact
# @raycast.icon ☕
if pgrep -qx caffeinate; then
  pkill -x caffeinate && echo "Caffeinate off"
else
  nohup caffeinate -dims >/dev/null 2>&1 &
  echo "Caffeinate on"
fi
