#!/usr/bin/env bash
set -e

# VARIABLES
## Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

## Paths
CONFIG_DIR="${CONFIG_DIR:-$HOME/.dotfiles}"
CONFIG_SRC="${CONFIG_SRC:-https://github.com/YehneeN/dotfiles.git}"

## Verifs.
SYSTEM_TYPE=$(uname -s)

function echo_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
function echo_success() { echo -e "${GREEN}[OK]${NC} $1"; }
function echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

function install_arch() {
    local packages=(
        "hyprland"
        "waybar"
        "rofi"
        "swaync"
        "wlogout"
        "hyprlock"
        "hyprpaper"
        "hyprpolkitagent"
        "xdg-desktop-portal-hyprland"
        "hyprland-qt-support"
        "qt6-base"
        "qt6-5compat"
        "qt6-declarative"
        "qt6-imageformats"
        "qt6-multimedia"
        "qt6-multimedia-ffmpeg"
        "qt6-shadertools"
        "qt6-svg"
        "qt6-translations"
        "qt6-virtualkeyboard"
        "qt6-wayland"
        "qt5-graphicaleffects"
        "qt5-quickcontrols2"
        "qt5-svg"
        "qt5-multimedia"
        "kitty"
        "alacritty"
        "thunar"
        "fastfetch"
        "neovim"
        "btop"
        "zsh"
        "stow"
        "eza"
        "bat"
        "fzf"
        "zoxide"
        "grim"
        "trash-cli"
        "wl-clipboard"
        "brightnessctl"
        "networkmanager"
        "polkit"
        "pipewire"
        "wireplumber"
        "nwg-look"
        "kvantum"
        "gst-plugins-good"
        "gst-plugins-bad"
        "gst-plugins-ugly"
        "gst-plugins-base"
    )

    echo_info "Installation des paquets...\n"

    local to_install=()
    for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" &> /dev/null; then
            to_install+=("$pkg")
        else
            echo -e "  ${GREEN}✓${NC} $pkg (déjà installé)"
        fi
    done

    if [ ${#to_install[@]} -eq 0 ]; then
        echo_success "Tous les paquets prérequis sont déjà installés !\n"
        return 0
    fi

    echo_info "Paquets à installer : ${#to_install[@]}"
    for pkg in "${to_install[@]}"; do
        echo "  - $pkg\n"
    done

    read -p "Voulez-vous continuer ? [O/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]] && [[ ! -z $REPLY ]]; then
        echo_info "Installation annulée."
        return 1
    fi

    sudo pacman -S --needed "${to_install[@]}"
    echo_success "Installation terminée !"
}

function config_sddm() {
    echo_info "Configuration SDDM en cours..."
    sudo cp -r $HOME/.dotfiles/sddm/enfield /usr/share/sddm/themes/
    sudo cp $HOME/.dotfiles/sddm/enfield/fonts/Orbitron-VariableFont_wght.ttf /usr/share/fonts/TTF/
    sudo fc-cache -fv
    sudo mv /etc/sddm.conf /etc/sddm.conf.old
    sudo cp $HOME/.dotfiles/sddm/sddm.conf /etc/sddm.conf
}

echo_info "Script d'installation - YehneeN\n"\
"   Ce script installera les fichiers:\n"\
"   Depuis la source ${CONFIG_SRC}\n"\
"   Dans le dossier ${CONFIG_DIR}\n"\
"   >>> Bien lire les différents Readme avant de faire quoi que ce soit.\n"

install_arch
config_sddm
