#!/bin/bash
# Ultra-minimal bashrc installer - no git required
# Usage: curl -fsSL https://raw.githubusercontent.com/woud420/dotfiles/master/scripts/minimal-bashrc.sh | bash

# Just download the essential files directly
mkdir -p ~/.config/shell-functions
mkdir -p ~/.config/git

# Download server bashrc
curl -fsSL https://raw.githubusercontent.com/woud420/dotfiles/master/common/shell/.bashrc.server -o ~/.bashrc

# Download GNU aliases
curl -fsSL https://raw.githubusercontent.com/woud420/dotfiles/master/common/shell/.gnu_aliases -o ~/.gnu_aliases

# Download git config
curl -fsSL https://raw.githubusercontent.com/woud420/dotfiles/master/common/git/.gitconfig -o ~/.gitconfig

# Download git commit template
curl -fsSL https://raw.githubusercontent.com/woud420/dotfiles/master/common/git/commit-template.md -o ~/.config/git/commit-template.md

# Download git hooks (the gitconfig sets core.hooksPath, so they must exist
# or git stops running ANY hooks, including repo-local ones like husky)
mkdir -p ~/.config/git/hooks
curl -fsSL https://raw.githubusercontent.com/woud420/dotfiles/master/common/git/hooks/pre-commit -o ~/.config/git/hooks/pre-commit
curl -fsSL https://raw.githubusercontent.com/woud420/dotfiles/master/common/git/hooks/pre-push -o ~/.config/git/hooks/pre-push
chmod +x ~/.config/git/hooks/pre-commit ~/.config/git/hooks/pre-push

echo "✅ Minimal configs installed! Run: source ~/.bashrc"
