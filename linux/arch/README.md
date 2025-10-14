# Arch Linux Desktop Configuration

This directory contains configuration files for my Arch Linux desktop setup.

## System Info
- **Window Manager**: SwayFX 0.5.3 (Wayland compositor with rounded corners and effects)
- **Status Bar**: Waybar with custom modules
- **Terminal**: Kitty with FiraCode Nerd Font
- **Launcher**: Rofi
- **Notifications**: Mako
- **GPU**: AMD Radeon RX 5700 XT (RADV driver)
- **Theme**: Purple/dark color scheme

## What's Included

### Sway/SwayFX Configuration
- **Location**: `.config/sway/config`
- **Features**:
  - 10px rounded corners on windows
  - Window shadows and blur effects
  - 4px purple borders (#9d5a7f)
  - 28px inner gaps, -8px outer gaps
  - GPU configuration for AMD RX 5700 XT
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
- **Location**: `.config/kitty/kitty.conf`
- **Settings**:
  - Font: FiraCode Nerd Font 12.5
  - Background: #221820 (pink-gray tint)
  - 85% opacity with tint
  - Matching purple theme

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
   sudo pacman -S swayfx waybar kitty rofi mako \
                  firefox slack-desktop spotify-launcher steam
   ```

2. **Link configs** (from dotfiles root):
   ```bash
   ln -sf $(pwd)/linux/arch/.config/sway ~/.config/sway
   ln -sf $(pwd)/linux/arch/.config/waybar ~/.config/waybar
   ln -sf $(pwd)/linux/arch/.config/kitty ~/.config/kitty
   ln -sf $(pwd)/linux/arch/.config/rofi ~/.config/rofi
   ln -sf $(pwd)/linux/arch/.config/mako ~/.config/mako
   ```

3. **Make waybar modules executable**:
   ```bash
   chmod +x ~/.config/waybar/modules/*.{sh,py}
   ```

4. **Reload Sway**:
   ```bash
   swaymsg reload
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
- Sway config includes GPU-specific settings for AMD RX 5700 XT
- All configs use rounded corners (10-16px) for visual consistency
