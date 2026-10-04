#!/usr/bin/env bash

swaymsg -t subscribe -m '["input"]' | jq --unbuffered -r \
  'select(.change=="xkb_layout") | .input.xkb_active_layout_name' |
while read -r layout; do
  notify-send -t 800 \
    -h string:x-canonical-private-synchronous:kbd-layout \
    "Klaviatura" "$layout"
done
