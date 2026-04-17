#!/bin/bash

MONITORS_DIR="$HOME/.dotfiles/hypr/.config/hypr/sFiles/monitors"
DYN_DIR="$HOME/.dotfiles/hypr/.config/hypr/dynFiles"

usage() {
    echo "Usage: $0 <mode>"
    echo "  mirror      - Mirror mode"
    echo "  mono        - Single monitor mode"
    echo "  presentation - Presentation mode (presFF)"
    exit 1
}

case "$1" in
    mirror)
        config="mirror.conf"
        ;;
    mono)
        config="mono.conf"
        ;;
    presentation)
        config="presFF.conf"
        ;;
    *)
        usage
        ;;
esac

rm "$MONITORS_DIR"/*.conf
cp "$DYN_DIR/$config" "$MONITORS_DIR/$config"
hyprctl reload