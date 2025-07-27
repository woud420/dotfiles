#!/usr/bin/env bash
# Quick dotfiles installer for remote servers
# Usage: curl -sSL https://raw.githubusercontent.com/woud420/dotfiles/master/scripts/quick-install.sh | bash

set -e

REPO_URL="https://github.com/woud420/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# Minimal dependencies check
command -v git >/dev/null 2>&1 || { echo "Git is required but not installed. Aborting." >&2; exit 1; }

# Clone or update dotfiles
if [ -d "$DOTFILES_DIR" ]; then
    echo "Updating existing dotfiles..."
    cd "$DOTFILES_DIR" && git pull
else
    echo "Cloning dotfiles..."
    git clone --depth 1 "$REPO_URL" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

# Detect if we're in a container or minimal environment
if [ -f /.dockerenv ] || [ -n "$CONTAINER" ]; then
    echo "Container environment detected, using minimal setup..."
    MINIMAL=1
else
    MINIMAL=0
fi

# Install common configs
echo "Installing common configurations..."

# Bash configs
[ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc.backup"
if [ "$MINIMAL" = "1" ]; then
    ln -sf "$DOTFILES_DIR/common/shell/.bashrc.server" "$HOME/.bashrc"
else
    ln -sf "$DOTFILES_DIR/common/shell/.bashrc" "$HOME/.bashrc"
fi
ln -sf "$DOTFILES_DIR/common/shell/.bash_profile" "$HOME/.bash_profile"

# Git config
ln -sf "$DOTFILES_DIR/common/git/.gitconfig" "$HOME/.gitconfig"
mkdir -p "$HOME/.config/git"
ln -sf "$DOTFILES_DIR/common/git/.gitignore_global" "$HOME/.config/git/ignore"

# GNU aliases
ln -sf "$DOTFILES_DIR/common/shell/.gnu_aliases" "$HOME/.gnu_aliases"

# Shell functions
mkdir -p "$HOME/.config/shell-functions"
ln -sf "$DOTFILES_DIR/common/shell-functions/"* "$HOME/.config/shell-functions/"

# Optional: Install FZF if not in minimal mode
if [ "$MINIMAL" = "0" ] && ! command -v fzf >/dev/null 2>&1; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --bin --no-update-rc --no-key-bindings --no-completion
fi

echo "✅ Dotfiles installed! Please run: source ~/.bashrc"