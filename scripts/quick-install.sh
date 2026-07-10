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

# Detect if we're in a container, SSH session, or minimal environment
if [ -f /.dockerenv ] || [ -n "$CONTAINER" ]; then
    echo "Container environment detected, using minimal setup..."
    MINIMAL=1
elif [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ]; then
    echo "Remote SSH session detected, using server configs..."
    MINIMAL=1
else
    MINIMAL=0
fi

# Install common configs
echo "Installing common configurations..."

# Bash configs
[ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc.backup"
if [ "$MINIMAL" = "1" ]; then
    cp -f "$DOTFILES_DIR/common/shell/.bashrc.server" "$HOME/.bashrc"
else
    cp -f "$DOTFILES_DIR/common/shell/.bashrc" "$HOME/.bashrc"
fi
cp -f "$DOTFILES_DIR/common/shell/.bash_profile" "$HOME/.bash_profile"

# Git config
cp -f "$DOTFILES_DIR/common/git/.gitconfig" "$HOME/.gitconfig"
mkdir -p "$HOME/.config/git"
cp -f "$DOTFILES_DIR/common/git/.gitignore_global" "$HOME/.config/git/ignore"
cp -f "$DOTFILES_DIR/common/git/commit-template.md" "$HOME/.config/git/commit-template.md"

# Git hooks: the gitconfig above sets core.hooksPath, so the hooks must exist
# or git stops running ANY hooks (including repo-local ones like husky)
mkdir -p "$HOME/.config/git/hooks"
for hook in "$DOTFILES_DIR/common/git/hooks/"*; do
    base="$(basename "$hook")"
    [ -f "$hook" ] && [ "$base" != "README.md" ] || continue
    cp -f "$hook" "$HOME/.config/git/hooks/$base"
    chmod +x "$HOME/.config/git/hooks/$base"
done

# GNU aliases (copy to avoid symlink on targets)
cp -f "$DOTFILES_DIR/common/shell/.gnu_aliases" "$HOME/.gnu_aliases"

# Shell functions (copy to ensure standalone files)
mkdir -p "$HOME/.config/shell-functions"
cp -f "$DOTFILES_DIR/common/shell-functions/"*.sh "$HOME/.config/shell-functions/"

# Optional: Install FZF if not in minimal mode
if [ "$MINIMAL" = "0" ] && ! command -v fzf >/dev/null 2>&1; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --bin --no-update-rc --no-key-bindings --no-completion
fi

echo "✅ Dotfiles installed! Please run: source ~/.bashrc"
