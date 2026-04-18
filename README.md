# Dotfiles

Configuration personnelle pour Arch Linux (Cachy) avec Hyprland.
Toujours en travaux.

## Composants

| Programme | Description |
|-----------|-------------|
| **Hyprland** | Compositor Wayland |
| **Waybar** | Barre de statut |
| **Rofi** | Lanceur d'applications |
| **SwayNC** | Centre de notifications |
| **Hyprlock** | Écran de verrouillage (Non utilisé dans ma configuration > QS) |
| **Alacritty / Kitty** | Terminaux |
| **Zsh** | Shell |
| **Yazi** | Gestionnaire de fichiers TUI |
| **Thunar** | Gestionnaire de fichiers |
| **SDDM** | Gestionnaire GUI de session |

## Installation

```bash
git clone https://github.com/YehneeN/dotfiles.git $HOME/.dotfiles
./install.sh
```

Le script guide à travers les étapes :
1. Clone/mise à jour des dotfiles
2. Configuration Git
3. Installation des paquets (pacman)
4. Configuration des thèmes (Kvantum, GTK)
5. Configuration SDDM
6. Stow des configs
7. Configuration du shell
8. Logiciels supplémentaires (optionnel)
9. Pray. J'ai pas encore fait de test :p

## Paquets inclus

- Bureau : hyprland, waybar, rofi, swaync, wlogout, hyprlock, hyprpaper
- Terminal : alacritty, kitty
- Utils : fastfetch, btop, neovim, fzf, zoxide, eza, bat, ...
- Média : pipewire, wireplumber, grim, wl-clipboard, ...
- Thèmes : kvantum,gtk, sddm
- Autres : yazi, ffmpeg, keepassxc, ...

## Logiciels supplémentaires

Le script `install.sh` propose l'installation de logiciels additionnels par catégorie :
- Navigateurs : Firefox, Brave, Chromium, Opera
- Multimédia : VLC, Kodi, Spotify
- Développement : Zed, VSCode
- Graphisme : GIMP, Krita, Inkscape
- Bureautique : OnlyOffice, LibreOffice
- Gaming : Steam, Lutris, Heroic

## Structure

```
.dotfiles/
├── alacritty/      # Config Alacritty
├── fastfetch/      # Config fastfetch
├── gtktheme/       # Config GTK
├── hypr/           # Config Hyprland
├── icons/          # Icônes personnalisées
├── kitty/          # Config Kitty
├── local/          # Scripts locaux
├── quickshell/     # Config Quickshell
├── rofi/           # Config Rofi
├── sddm/           # Thème SDDM
├── swaync/         # Config SwayNC
├── usr/            # Binaires utilisateur
├── vesktop/        # Config Vesktop
├── wallpapers/     # Fonds d'écran
├── waybar/         # Config Waybar
├── waybar-backup/  # Backup scripts waybar
├── wlogout/        # Config Wlogout
├── yazi/           # Config Yazi
├── zshrc/          # Config Zsh
└── install.sh      # Script d'installation
```
