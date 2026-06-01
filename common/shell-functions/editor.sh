#!/usr/bin/env bash

if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
    export VISUAL=nvim
    alias vi='nvim'
    alias vim='nvim'
    alias vimdiff='nvim -d'
fi
