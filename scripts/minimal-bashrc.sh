#!/bin/bash
# Ultra-minimal bashrc installer - no git required
# Usage: curl -sSL https://raw.githubusercontent.com/woud420/dotfiles/master/scripts/minimal-bashrc.sh | bash

# Just download the essential files directly
mkdir -p ~/.config/shell-functions

# Download server bashrc
curl -sSL https://raw.githubusercontent.com/woud420/dotfiles/master/common/shell/.bashrc.server -o ~/.bashrc

# Download GNU aliases
curl -sSL https://raw.githubusercontent.com/woud420/dotfiles/master/common/shell/.gnu_aliases -o ~/.gnu_aliases

# Download git config
curl -sSL https://raw.githubusercontent.com/woud420/dotfiles/master/common/git/.gitconfig -o ~/.gitconfig

echo "✅ Minimal configs installed! Run: source ~/.bashrc"