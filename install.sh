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
KVANTUM_THEME="Layan"
GTK_THEME="Layan-Dark"
BACKUP_DIR="$HOME/Backup_Config"

function backup_configs() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi

    local -A configs=(
        ["$HOME/.config/hypr"]="hypr"
        ["$HOME/.config/kitty"]="kitty"
        ["$HOME/.config/alacritty"]="alacritty"
        ["$HOME/.config/rofi"]="rofi"
        ["$HOME/.config/waybar"]="waybar"
        ["$HOME/.config/swaync"]="swaync"
        ["$HOME/.config/wlogout"]="wlogout"
        ["$HOME/.config/zsh"]="zsh"
        ["$HOME/.zshrc"]="zshrc"
        ["$HOME/.config/gtk-3.0"]="gtk-3.0"
        ["$HOME/.config/Kvantum"]="kvantum"
        ["$HOME/.local/share/icons"]="icons"
        ["$HOME/.local/share/wallpapers"]="wallpapers"
        ["$HOME/.config/quickshell"]="quickshell"
        ["$HOME/.config/fastfetch"]="fastfetch"
    )

    local backed_up=0
    local skipped=0

    for path in "${!configs[@]}"; do
        if [ -e "$path" ]; then
            local name="${configs[$path]}"
            local dest="$BACKUP_DIR/$name"
            local count=1
            while [ -d "$dest" ]; do
                dest="$BACKUP_DIR/${name}_$count"
                ((count++))
            done

            cp -r "$path" "$dest"
            echo "$path -> $dest"
            ((backed_up++))
        else
            ((skipped++))
        fi
    done

    echo_info "Sauvegarde terminée: $backed_up fichiers backupés, $skipped ignorés"
}

function echo_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
function echo_success() { echo -e "${GREEN}[OK]${NC} $1"; }
function echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }
function echo_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

function install_arch() {
    local packages=(
        "hyprland"
        "waybar"
        "awww"
        "rofi"
        "swaync"
        "upower"
        "pywal-git"
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
        "yazi"
        "ffmpeg"
        "7zip"
        "poppler"
        "fd"
        "ripgrep"
        "resvg"
        "imagemagick"
        "keepassxc"
        "bluez"
        "bluez-utils"
        "bluetui"
        "wine-staging"
        "wine-mono"
        "wine-gecko"
        "winetricks"
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

function clone_dotfiles() {
    if [ -d "$CONFIG_DIR" ]; then
        echo_info "Dotfiles déjà présents: $CONFIG_DIR"
        echo -n "Voulez-vous les mettre à jour ? [O/n] "
        read -n 1 -r REPLY
        echo
        if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
            cd "$CONFIG_DIR"
            git pull origin main || git pull origin master
            echo_success "Dotfiles mis à jour"
        fi
        return 0
    fi

    echo_info "Clonage des dotfiles depuis $CONFIG_SRC\n"

    echo -n "Cloner le repository ? [O/n] "
    read -n 1 -r REPLY
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]] && [[ ! -z $REPLY ]]; then
        echo_info "Clonage annulé."
        return 1
    fi

    if ! command -v git &> /dev/null; then
        echo_error "Git n'est pas installé"
        return 1
    fi

    git clone "$CONFIG_SRC" "$CONFIG_DIR"
    echo_success "Dotfiles clonés dans: $CONFIG_DIR"
}

function config_git() {
    echo_info "Configuration Git\n"

    local current_name=$(git config --global user.name 2>/dev/null)
    local current_email=$(git config --global user.email 2>/dev/null)

    if [ -n "$current_name" ] && [ -n "$current_email" ]; then
        echo_info "Git déjà configuré:"
        echo "  Name: $current_name"
        echo "  Email: $current_email"
        echo -n "Voulez-vous modifier la configuration ? [n/O] "
        read -n 1 -r REPLY
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]] && [[ ! -z $REPLY ]]; then
            return 0
        fi
    fi

    echo -n "Nom d'utilisateur Git: "
    read -r git_name
    echo -n "Email Git: "
    read -r git_email
    echo

    if [ -z "$git_name" ] || [ -z "$git_email" ]; then
        echo_error "Nom et email requis"
        return 1
    fi

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    echo_success "Git configuré: $git_name <$git_email>"
}

function config_themes() {
    echo_info "Configuration des thèmes...\n"

    local kvantum_dir="$HOME/.config/Kvantum"
    local gtk_conf="$HOME/.config/gtk-3.0/settings.ini"

    if [ ! -d "$kvantum_dir" ]; then
        mkdir -p "$kvantum_dir"
    fi

    echo -n "Télécharger et installer le thème Kvantum '$KVANTUM_THEME' ? [O/n] "
    read -n 1 -r REPLY
    echo
    if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
        if [ -d "/tmp/Layan" ]; then
            rm -rf /tmp/Layan
        fi
        echo_info "Téléchargement du thème Layan..."
        git clone --depth 1 https://github.com/vinceliuice/Layan-kvantum.git /tmp/Layan
        sudo cp -r /tmp/Layan/* "$kvantum_dir/"
        rm -rf /tmp/Layan
        echo_success "Thème Kvantum '$KVANTUM_THEME' installé"

        echo "[Settings]" > "$kvantum_dir/$KVANTUM_THEME/$KVANTUM_THEME.conf"
        echo "theme=$KVANTUM_THEME" >> "$kvantum_dir/$KVANTUM_THEME/$KVANTUM_THEME.conf"
    fi

    echo
    echo -n "Installer le thème GTK '$GTK_THEME' ? [O/n] "
    read -n 1 -r REPLY
    echo
    if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
        if [ -d "/tmp/Layan-dark" ]; then
            rm -rf /tmp/Layan-dark
        fi
        echo_info "Téléchargement du thème Layan-Dark..."
        git clone --depth 1 https://github.com/vinceliuice/Layan-dark.git /tmp/Layan-dark
        mkdir -p "$HOME/.themes"
        cp -r /tmp/Layan-dark/* "$HOME/.themes/"
        rm -rf /tmp/Layan-dark
        echo_success "Thème GTK '$GTK_THEME' installé"

        if [ -f "$gtk_conf" ]; then
            if grep -q "gtk-theme-name" "$gtk_conf"; then
                sed -i "s/gtk-theme-name=.*/gtk-theme-name=$GTK_THEME/" "$gtk_conf"
            else
                echo "gtk-theme-name=$GTK_THEME" >> "$gtk_conf"
            fi
        else
            mkdir -p "$HOME/.config/gtk-3.0"
            echo "[Settings]" > "$gtk_conf"
            echo "gtk-theme-name=$GTK_THEME" >> "$gtk_conf"
        fi
        echo_success "Thème GTK '$GTK_THEME' appliqué"
    fi

    echo
    echo_info "Redémarrez la session pour appliquer les thèmes."
}

function config_sddm() {
    echo_info "Configuration SDDM...\n"

    local sddm_theme_source="$CONFIG_DIR/sddm/enfield"
    local sddm_font_source="$CONFIG_DIR/sddm/enfield/font/Orbitron-VariableFont_wght.ttf"
    local sddm_conf_source="$CONFIG_DIR/sddm/sddm.conf"

    if [ ! -d "$sddm_theme_source" ]; then
        echo_error "Thème SDDM introuvable: $sddm_theme_source"
        return 1
    fi
    echo_success "Thème source trouvé: $sddm_theme_source"

    if [ ! -f "$sddm_font_source" ]; then
        echo_error "Police SDDM introuvable: $sddm_font_source"
        return 1
    fi
    echo_success "Police source trouvée: $sddm_font_source"

    if [ ! -f "$sddm_conf_source" ]; then
        echo_error "Config SDDM introuvable: $sddm_conf_source"
        return 1
    fi
    echo_success "Config source trouvée: $sddm_conf_source\n"

    local sddm_conf="/etc/sddm.conf"
    if [ -f "$sddm_conf" ]; then
        echo_info "Sauvegarde de l'ancienne config..."
        sudo mv "$sddm_conf" "$sddm_conf.old"
        echo_success "Sauvegardée: /etc/sddm.conf.old\n"
    fi

    echo_info "Copie du thème..."
    sudo cp -r "$sddm_theme_source" "/usr/share/sddm/themes/"
    echo_success "Thème copié vers: /usr/share/sddm/themes/enfield"

    echo_info "Copie de la police..."
    sudo cp "$sddm_font_source" "/usr/share/fonts/TTF/"
    echo_success "Police copiée vers: /usr/share/fonts/TTF/"

    echo_info "Rafraîchissement du cache des polices..."
    sudo fc-cache -fv
    echo_success "Cache actualisé\n"

    echo_info "Application de la configuration..."
    sudo cp "$sddm_conf_source" "$sddm_conf"
    echo_success "Config appliquée: $sddm_conf\n"

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
        wal -i $HOME/.config/wallpapers
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
        wal -i $HOME/.config/wallpapers
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
        "vesktop"
        "local"
        "yazi"
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

function install_webapps() {
    if ! command -v chromium &> /dev/null; then
      pacman -S --needed chromium
    fi

    local webApps=(
        "Atera"
        "Outlook"
        "Teams"
    )

    local apps_dir="${HOME}/.local/share/applications"
    local source_dir="${CONFIG_DIR}/local/.local/share/applications"

    if [ ! -d "$apps_dir" ]; then
        mkdir -p "$apps_dir"
    fi

    for app in "${webApps[@]}"; do
        if [ -f "${source_dir}/${app}.desktop" ]; then
            cp -f "${source_dir}/${app}.desktop" "$apps_dir/"
            echo_info "Copie de ${app}.desktop"
        fi
    done

    update-desktop-database "$apps_dir"
    echo_success "Base de donnees des applications mise a jour"
}

echo_info "Script d'installation - YehneeN\n"\
"   Depuis la source ${CONFIG_SRC}\n"\
"   Dans le dossier ${CONFIG_DIR}\n"

echo
echo -n "Sauvegarder la configuration actuelle ? [O/n] "
read -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
    backup_configs
fi

echo
echo -n "Cloner/Mettre à jour les dotfiles ? [O/n] "
read -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
    clone_dotfiles
fi

echo
echo -n "Configurer Git ? [O/n] "
read -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
    config_git
fi

echo
echo -n "Installer les prérequis (paquets Arch) ? [O/n] "
read -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
    install_arch
fi

echo
echo -n "Configurer les thèmes (Kvantum + GTK) ? [O/n] "
read -n 1 -r REPLY
echo
if [[ $REPLY =~ ^[Oo]$ ]] || [[ -z $REPLY ]]; then
    config_themes
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

#echo
#echo -n "Installer des logiciels supplémentaires ? [o/N] "
#read -n 1 -r REPLY
#echo
#if [[ $REPLY =~ ^[Oo]$ ]]; then
#    install_extras
#fi

echo
echo_success "Installation terminée !"
