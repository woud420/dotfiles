#!/bin/bash
# Copy minimal dotfiles over SSH without git
# Usage: ./ssh-copy-dotfiles.sh user@host

if [ $# -eq 0 ]; then
    echo "Usage: $0 user@host"
    exit 1
fi

HOST=$1
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Copying dotfiles to $HOST..."

# Create directories
ssh "$HOST" 'mkdir -p ~/.config/shell-functions ~/.config/git'

# Copy essential files
scp "$DOTFILES_DIR/common/shell/.bashrc.server" "$HOST:~/.bashrc"
scp "$DOTFILES_DIR/common/shell/.bash_profile" "$HOST:~/.bash_profile"
scp "$DOTFILES_DIR/common/shell/.gnu_aliases" "$HOST:~/.gnu_aliases"
scp "$DOTFILES_DIR/common/git/.gitconfig" "$HOST:~/.gitconfig"
scp "$DOTFILES_DIR/common/git/.gitignore_global" "$HOST:~/.config/git/ignore"
scp "$DOTFILES_DIR/common/shell-functions/"*.sh "$HOST:~/.config/shell-functions/"

echo "✅ Dotfiles copied to $HOST"
echo "Run 'source ~/.bashrc' on the remote host"