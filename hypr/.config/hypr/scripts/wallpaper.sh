#!/bin/bash
wpDIR="$HOME/.config/wallpapers"
wpPICS=($(ls "$wpDIR"))

RANDOMPICS="${wpPICS[$RANDOM % ${#wpPICS[@]}]}"

wait

awww img "${wpDIR}/${RANDOMPICS}" --transition-type center --transition-fps 60 --transition-duration 1 --transition-angle 30 --transition-step 90 &
wait

wal -i "${wpDIR}/${RANDOMPICS}"
wait
pkill waybar && waybar &
