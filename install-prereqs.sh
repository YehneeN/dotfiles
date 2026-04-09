#!/usr/bin/env bash
set -e

# VARIABLES
## Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

## Paths
CONFIG_DIR="${CONFIG_DIR:-$HOME/.dotfiles}"
CONFIG_SRC="${CONFIG_SRC:-https://github.com/YehneeN/dotfiles.git}"
THEME="enfield"
SDDM_THEME_DIR="/usr/share/sddm/themes"
SDDM_THEME_SOURCE="$HOME/.dotfiles/sddm/enfield"
SDDM_FONT_SOURCE="$HOME/.dotfiles/sddm/enfield/fonts/Orbitron-VariableFont_wght.ttf"
SDDM_FONT_DIR="/usr/share/fonts/TTF"
SDDM_CONF="/etc/sddm.conf"
SDDM_CONF_BACKUP="/etc/sddm.conf.old"
SDDM_CONF_SOURCE="$HOME/.dotfiles/sddm/sddm.conf"

function echo_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
function echo_success() { echo -e "${GREEN}[OK]${NC} $1"; }
function echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }
function echo_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

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
        "sddm"
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
    echo_info "Configuration SDDM...\n"

    if [ ! -d "$SDDM_THEME_SOURCE" ]; then
        echo_error "Thème SDDM introuvable: $SDDM_THEME_SOURCE"
        return 1
    fi
    echo_success "Thème source trouvé: $SDDM_THEME_SOURCE"

    if [ ! -f "$SDDM_FONT_SOURCE" ]; then
        echo_error "Police SDDM introuvable: $SDDM_FONT_SOURCE"
        return 1
    fi
    echo_success "Police source trouvée: $SDDM_FONT_SOURCE"

    if [ ! -f "$SDDM_CONF_SOURCE" ]; then
        echo_error "Config SDDM introuvable: $SDDM_CONF_SOURCE"
        return 1
    fi
    echo_success "Config source trouvée: $SDDM_CONF_SOURCE\n"

    if [ -f "$SDDM_CONF" ]; then
        echo_info "Sauvegarde de l'ancienne config..."
        sudo mv "$SDDM_CONF" "$SDDM_CONF_BACKUP"
        echo_success "Sauvegardée: $SDDM_CONF_BACKUP\n"
    fi

    echo_info "Copie du thème..."
    sudo cp -r "$SDDM_THEME_SOURCE" "$SDDM_THEME_DIR/"
    echo_success "Thème copié vers: $SDDM_THEME_DIR/enfield"

    echo_info "Copie de la police..."
    sudo cp "$SDDM_FONT_SOURCE" "$SDDM_FONT_DIR/"
    echo_success "Police copiée vers: $SDDM_FONT_DIR/"

    echo_info "Rafraîchissement du cache des polices..."
    sudo fc-cache -fv
    echo_success "Cache actualisé\n"

    echo_info "Application de la configuration..."
    sudo cp "$SDDM_CONF_SOURCE" "$SDDM_CONF"
    echo_success "Config appliquée: $SDDM_CONF\n"

    echo_success "Configuration SDDM terminée !"
}

function stowThat() {
    local packages=(
        "alacritty"
        "fastfetch"
        "gtktheme"
        "hypr"
        "icons"
        "kitty"
        "quickshell"
        "rofi"
        "swaync"
        "wallpapers"
        "waybar"
        "wlogout"
        "zshrc"
    )

    declare -A stow_targets=(
        ["alacritty"]="$HOME/.config/alacritty"
        ["fastfetch"]="$HOME/.config/fastfetch"
        ["gtktheme"]="$HOME/.config/gtk-3.0"
        ["hypr"]="$HOME/.config/hypr"
        ["icons"]="$HOME/.local/share/icons"
        ["kitty"]="$HOME/.config/kitty"
        ["quickshell"]="$HOME/.config/quickshell"
        ["rofi"]="$HOME/.config/rofi"
        ["swaync"]="$HOME/.config/swaync"
        ["wallpapers"]="$HOME/.local/share/wallpapers"
        ["waybar"]="$HOME/.config/waybar"
        ["wlogout"]="$HOME/.config/wlogout"
        ["zshrc"]="$HOME/.zshrc"
    )

    if ! command -v stow &> /dev/null; then
        echo_error "stow n'est pas installé"
        return 1
    fi

    local to_stow=()
    if [ $# -eq 0 ]; then
        to_stow=("${packages[@]}")
    else
        for pkg in "$@"; do
            if [[ " ${packages[*]} " =~ " $pkg " ]]; then
                to_stow+=("$pkg")
            else
                echo_error "Package inconnu: $pkg"
            fi
        done
    fi

    if [ ${#to_stow[@]} -eq 0 ]; then
        echo_error "Aucun package à stow"
        return 1
    fi

    echo_info "Stow des packages: ${to_stow[*]}\n"

    for pkg in "${to_stow[@]}"; do
        if [ ! -d "$CONFIG_DIR/$pkg" ]; then
            echo_error "$pkg: dossier source introuvable"
            continue
        fi

        local target="${stow_targets[$pkg]}"
        if [ -e "$target" ]; then
            echo_warn "Cible existe déjà: $target"
            echo_info "Sauvegarde..."
            local backup="${target}.stow-backup"
            if [ -e "$backup" ]; then
                local i=1
                while [ -e "${backup}-${i}" ]; do
                    ((i++))
                done
                backup="${backup}-${i}"
            fi
            mv "$target" "$backup"
            echo_success "Sauvegardé: $backup"
        fi

        stow -d "$CONFIG_DIR" -t "$HOME" -v 2 "$pkg"
        echo_success "$pkg stowed"
    done
}

echo_info "Script d'installation - YehneeN\n"\
"   Ce script installera les fichiers:\n"\
"   Depuis la source ${CONFIG_SRC}\n"\
"   Dans le dossier ${CONFIG_DIR}\n"\
"   >>> Bien lire les différents Readme avant de faire quoi que ce soit.\n"


install_arch
config_sddm
stowThat
