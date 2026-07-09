#!/bin/bash
# Sudo askpass for GUI password prompts (used by Claude CLI, etc.)
# The installer copies scripts/sudo-askpass.sh to ~/.local/bin/sudo-askpass,
# so this works regardless of where the dotfiles repo is checked out.
if [[ -x "$HOME/.local/bin/sudo-askpass" ]]; then
    export SUDO_ASKPASS="$HOME/.local/bin/sudo-askpass"
fi
