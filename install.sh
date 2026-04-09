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

function config_zshShell() {
    if ! command -v zsh &> /dev/null; then
        echo_error "Zsh n'est pas installé"
        return 1
    fi

    local current_shell=$(basename "$SHELL")

    if [ "$current_shell" = "zsh" ]; then
        echo_success "Zsh est déjà le shell par défaut"
        return 0
    fi

    echo_info "Shell actuel: $current_shell"
    echo_info "Shell cible: zsh"
    echo

    echo -n "Changer le shell par défaut pour zsh ? [O/n] "
    read -n 1 -r REPLY
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]] && [[ ! -z $REPLY ]]; then
        echo_info "Shell non modifié."
        return 0
    fi

    if chsh -s "$(which zsh)"; then
        echo_success "Shell changé pour zsh"
        echo_info "Déconnectez-vous et reconnectez-vous pour appliquer."
    else
        echo_error "Échec du changement de shell"
        return 1
    fi
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

function install_extras() {
    if ! command -v paru &> /dev/null; then
        echo_warn "Paru n'est pas installé. Installation via pacman uniquement."
        echo_info "Installez paru avec: sudo pacman -S paru"
        sleep 2
    fi

    local -A categories=(
        ["1"]="Navigateurs"
        ["2"]="Multimédia"
        ["3"]="Utilitaires"
        ["4"]="Développement"
        ["5"]="Graphisme"
        ["6"]="Bureautique"
        ["7"]="Gaming"
    )

    local -A packages=(
        ["1_1"]="firefox"
        ["1_2"]="brave-bin"
        ["1_3"]="opera-ffmpeg-codecs"
        ["1_4"]="opera"

        ["2_1"]="vlc"
        ["2_2"]="kodi"
        ["2_3"]="spotify"

        ["3_1"]="ncdu"

        ["4_1"]="zed"
        ["4_2"]="vscodium"

        ["5_1"]="gimp"
        ["5_2"]="krita"
        ["5_3"]="inkscape"

        ["6_1"]="onlyoffice-bin"
        ["6_2"]="libreoffice-fresh"

        ["7_1"]="steam"
        ["7_2"]="lutris"
        ["7_3"]="heroic-games-launcher"
    )

    local -A source
    local -A status
    local -A selected

    for key in "${!packages[@]}"; do
        status["$key"]="[ ]"
    done

    while true; do
        clear
        echo -e "${BLUE}================================${NC}"
        echo -e "${BLUE}  Installation de logiciels${NC}"
        echo -e "${BLUE}================================${NC}"
        echo
        echo -e "${YELLOW}Sélectionnez les logiciels à installer${NC}"
        echo -e "Touche numérique pour toggle, Entrée pour valider, q pour quitter"
        echo

        local cat_prev=""
        for key in $(printf '%s\n' "${!packages[@]}" | sort); do
            local cat="${key%%_*}"
            if [ "$cat" != "$cat_prev" ]; then
                echo
                echo -e "${GREEN}[ ${categories[$cat]} ]${NC}"
                cat_prev="$cat"
            fi
            local pkg="${packages[$key]}"
            local source_tag=""

            if pacman -Q "$pkg" &> /dev/null; then
                source["$key"]="installed"
                source_tag=" ${GREEN}(pacman)${NC}"
            elif paru -Si "$pkg" &> /dev/null; then
                source["$key"]="aur"
                source_tag=" ${YELLOW}(AUR)${NC}"
            else
                source["$key"]="missing"
                source_tag=" ${RED}(indisponible)${NC}"
            fi

            echo "  $key. ${status[$key]} $pkg$source_tag"
        done

        echo
        local count=0
        for key in "${!selected[@]}"; do
            ((count++))
        done
        echo -e "Sélectionnés: ${GREEN}$count${NC}"
        echo

        echo -e "1-9. Toggle  |  Entrée. Valider  |  q. Quitter"
        echo -n "Choix: "

        local key
        read -n 1 -s key
        echo

        if [ -z "$key" ]; then
            break
        elif [ "$key" = "q" ] || [ "$key" = "Q" ]; then
            return 0
        elif [[ "$key" =~ ^[0-9]$ ]]; then
            for prefix in "1_" "2_" "3_" "4_" "5_" "6_" "7_"; do
                local full_key="${prefix}${key}"
                if [ -n "${packages[$full_key]:-}" ] && [ "${source[$full_key]}" != "installed" ] && [ "${source[$full_key]}" != "missing" ]; then
                    if [ "${status[$full_key]}" = "[ ]" ]; then
                        status["$full_key"]="[X]"
                        selected["$full_key"]="${packages[$full_key]}"
                    else
                        status["$full_key"]="[ ]"
                        unset selected["$full_key"]
                    fi
                    break
                fi
            done
        fi
    done

    local count=0
    for key in "${!selected[@]}"; do
        ((count++))
    done

    if [ $count -eq 0 ]; then
        echo_info "Aucun paquet sélectionné."
        return 0
    fi

    echo
    echo -e "${YELLOW}Paquets sélectionnés:${NC}"

    local pacman_pkgs=()
    local aur_pkgs=()

    for key in "${!selected[@]}"; do
        local pkg="${selected[$key]}"
        local src="${source[$key]}"
        echo "  - $pkg (${src})"
        if [ "$src" = "aur" ]; then
            aur_pkgs+=("$pkg")
        else
            pacman_pkgs+=("$pkg")
        fi
    done
    echo

    echo -n "Installer ces paquets ? [O/n] "
    read -n 1 -r REPLY
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]] && [[ ! -z $REPLY ]]; then
        echo_info "Installation annulée."
        return 0
    fi

    if [ ${#pacman_pkgs[@]} -gt 0 ]; then
        echo_info "Installation depuis pacman: ${pacman_pkgs[*]}"
        sudo pacman -S --needed "${pacman_pkgs[@]}"
    fi

    if [ ${#aur_pkgs[@]} -gt 0 ]; then
        echo_info "Installation depuis AUR: ${aur_pkgs[*]}"
        paru -S --needed "${aur_pkgs[@]}"
    fi

    echo_success "Installation terminée !"
}

echo_info "Script d'installation - YehneeN\n"\
"   Depuis la source ${CONFIG_SRC}\n"\
"   Dans le dossier ${CONFIG_DIR}\n"

echo -n "Installer les prérequis (paquets Arch) ? [O/n] "
read -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
    install_arch
fi

echo
echo -n "Configurer SDDM ? [O/n] "
read -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
    config_sddm
fi

echo
echo -n "Stow les configs ? [O/n] "
read -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
    stowThat
fi

echo
echo -n "Configurer Zsh comme shell par défaut ? [O/n] "
read -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
    config_zshShell
fi

echo
echo -n "Installer des logiciels supplémentaires ? [o/N] "
read -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Oo]$ ]]; then
    install_extras
fi

echo
echo_success "Installation terminée !"
