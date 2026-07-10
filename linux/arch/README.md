# Arch Linux Desktop Configuration

This directory contains configuration files for my Arch Linux desktop setup.

## System Info
- **Window Manager**: SwayFX 0.5.3 (Wayland compositor with rounded corners and effects)
- **Status Bar**: Waybar with custom modules
- **Terminal**: Kitty with FiraCode Nerd Font
- **Launcher**: Rofi
- **Notifications**: Mako
- **Theme**: Purple/dark color scheme

## What's Included

### Sway/SwayFX Configuration
- **Location**: `.config/sway/config`
- **Features**:
  - 10px rounded corners on windows
  - Window shadows and blur effects
  - 4px purple borders (#9d5a7f)
  - 28px inner gaps, -8px outer gaps
  - Workspace assignments (Firefox→2, Slack→3, Steam→4)
  - Custom keybindings

### Waybar
- **Location**: `.config/waybar/`
- **Modules**:
  - Docker container monitoring (`modules/docker.py`)
  - Kubernetes cluster info (`modules/k8s.py`) - filters out system namespaces
  - CPU/Memory usage display
  - Dual drive monitoring (root + workspace drive)
  - Custom app launchers (Firefox, Slack, Spotify, Steam)
- **Theme**: Purple/dark (#6b4456 backgrounds, #9d5a7f accents)
- **Font**: FiraCode Nerd Font 10px for tooltips

### Kitty Terminal
- **Location**: `.config/kitty/current-theme.conf` (Arch-only theme overlay)
- The base config comes from `linux/common/kitty.conf` (installed to
  `~/.config/kitty/kitty.conf`); this overlay applies the personal-pink
  palette on top:
  - Background: #2A1E2E (plum)
  - Accent: #9d5a7f
  - Font: FiraCode Nerd Font

### Rofi Launcher
- **Location**: `.config/rofi/theme.rasi`
- **Theme**: Purple/dark matching system colors
- **Border radius**: 16px rounded corners

### Mako Notifications
- **Location**: `.config/mako/config`
- **Theme**: Purple borders, dark background
- **Font**: FiraCode Nerd Font 10px
- **Border radius**: 16px

## Installation

1. **Prerequisites**:
   ```bash
   sudo pacman -S waybar kitty rofi mako grim slurp \
                  firefox spotify-launcher steam

   # AUR (pacman cannot install these; use an AUR helper)
   paru -S swayfx slack-desktop nordic-theme
   ```

2. **Install configs** (from the dotfiles root - configs are copied, never
   symlinked; packages come from `linux/arch/packages.list`):
   ```bash
   ./install.sh
   ```

3. **Reload Sway**:
   ```bash
   swaymsg reload
   ```

4. **(Optional) auto-refresh the AI machine-state snapshot on package changes**
   (the installer deliberately does not enable this; it writes into the repo):
   ```bash
   sed -e "s|__DOTFILES_DIR__|$PWD|" -e "s|__DOTFILES_USER__|$USER|" \
       linux/arch/hooks/90-refresh-ai-context.hook \
     | sudo tee /etc/pacman.d/hooks/90-refresh-ai-context.hook
   ```

## Color Scheme

- **Primary Purple**: `#9d5a7f` (borders, accents)
- **Dark Purple-Gray**: `#6b4456` (waybar backgrounds)
- **Background**: `#221820` (pink-gray tint)
- **Text**: `#d0d0d0` (light gray)
- **Unfocused**: `#4a3844` (dark purple-gray)

## Notes

- Waybar tooltips use FiraCode Nerd Font for consistency
- Docker and Kubernetes modules require respective CLIs installed
- All configs use rounded corners (10-16px) for visual consistency
