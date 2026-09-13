#!/usr/bin/env bash
# Weekly vim plugin maintenance: vim-plug, plugins, and coc extensions.
# Installed to ~/.local/bin/vim-plug-update by install.sh.
# Scheduled by vim-plug-update.timer (Linux/systemd) or
# com.woud420.vim-plug-update (macOS/launchd).
set -euo pipefail

log() { echo "[$(date '+%F %T')] $*"; }

if ! command -v nvim >/dev/null 2>&1; then
    log "nvim not found; nothing to update"
    exit 0
fi

# macOS ships no timeout(1); coreutils provides gtimeout when installed.
run_bounded() {
    if command -v timeout >/dev/null 2>&1; then
        timeout 600 "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout 600 "$@"
    else
        "$@"
    fi
}

log "Updating vim-plug and plugins..."
run_bounded nvim --headless -c 'PlugUpgrade' -c 'PlugUpdate --sync' -c 'qa!' 2>&1 \
    | tr '\r' '\n' | grep -v '^[[:space:]]*$' || true

log "Updating coc extensions..."
# Give the coc service a moment to initialize before the sync update.
run_bounded nvim --headless -c 'sleep 8' -c 'CocUpdateSync' -c 'qa!' 2>&1 \
    | tr '\r' '\n' | grep -v '^[[:space:]]*$' || true

log "Done."
