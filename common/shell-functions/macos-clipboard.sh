#!/usr/bin/env bash
# macOS-compatible clipboard commands for Linux shells.
# On macOS, leave the real pbcopy/pbpaste commands untouched.
if [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
    if ! command -v pbcopy >/dev/null 2>&1; then
        pbcopy() {
            wl-copy "$@"
        }
    fi

    if ! command -v pbpaste >/dev/null 2>&1; then
        pbpaste() {
            wl-paste "$@"
        }
    fi
fi
