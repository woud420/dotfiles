#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$ROOT_DIR/scripts/editor-parity.vim"

run() {
    printf '==> %s\n' "$*"
    "$@"
}

require() {
    local command_name="$1"
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Missing required command: %s\n' "$command_name" >&2
        exit 1
    fi
}

require vim
require nvim

if [[ ! -r "$HOME/.vim/vimrc" ]]; then
    printf 'Missing %s/.vim/vimrc. Run ./install.sh --no-packages first.\n' "$HOME" >&2
    exit 1
fi

if [[ ! -r "$HOME/.config/nvim/init.vim" ]]; then
    printf 'Missing %s/.config/nvim/init.vim. Run ./install.sh --no-packages first.\n' "$HOME" >&2
    exit 1
fi

if [[ ! -r "$HOME/.config/nvim/coc-settings.json" ]]; then
    printf 'Missing %s/.config/nvim/coc-settings.json. Run ./install.sh --no-packages first.\n' "$HOME" >&2
    exit 1
fi

run vim -Nu "$HOME/.vim/vimrc" -n -es -S "$FIXTURE"
run nvim --headless -u "$HOME/.config/nvim/init.vim" -n -S "$FIXTURE"
run cmp -s "$HOME/.vim/coc-settings.json" "$HOME/.config/nvim/coc-settings.json"

printf 'Editor parity checks passed.\n'
