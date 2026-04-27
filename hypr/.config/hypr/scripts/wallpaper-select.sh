#!/bin/bash
CONFIG="$HOME/.config/waypaper/config.ini"
WALLPAPER=$(sed -n 's/^[[:space:]]*wallpaper[[:space:]]*=[[:space:]]*\(.*\)$/\1/p' \
  "$CONFIG")
WALLPAPER=$(echo "$WALLPAPER" | xargs)
WALLPAPER="${WALLPAPER/#\~/$HOME}"
wal -i "$WALLPAPER"
wait
pkill waybar && waybar &
