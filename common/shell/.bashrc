# ~/.bashrc - Bash configuration for servers
# Adapted from zshrc for consistent experience

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Enable programmable completion features
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Git branch info for prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

# Plain ANSI codes, so colors work even where the host lacks the terminal's terminfo
if [ "$TERM" != "dumb" ]; then
    ROSEWATER=$'\e[38;5;217m'
    MAUVE=$'\e[38;5;183m'
    TEAL=$'\e[38;5;116m'
    PEACH=$'\e[38;5;215m'
    SOFT_GRAY=$'\e[38;5;243m'
    # Theme red (ANSI color 1) so the host and root follow each terminal's palette
    THEME_RED=$'\e[31m'
    BOLD=$'\e[1m'
    RESET=$'\e[0m'
else
    ROSEWATER="" MAUVE="" TEAL="" PEACH="" SOFT_GRAY="" THEME_RED="" BOLD="" RESET=""
fi

# Kubernetes context function (optional for servers)
kube_prompt() {
    if command -v kubectl >/dev/null 2>&1; then
        local context=$(kubectl config current-context 2>/dev/null)
        if [ -n "$context" ]; then
            echo "(k8s:$context)"
        fi
    fi
}

# Pretty pwd function
pretty_pwd() {
    case "$PWD" in
        "$HOME")
            echo "🏡"
            ;;
        "$HOME/Documents")
            echo "📄"
            ;;
        "$HOME/Downloads")
            echo "📁"
            ;;
        "$HOME/Pictures")
            echo "🖼️"
            ;;
        "$HOME/Music")
            echo "🎵"
            ;;
        "$HOME/Desktop")
            echo "🖥️"
            ;;
        "$HOME/workspace")
            echo "💻"
            ;;
        *)
            case "$PWD" in
                "$HOME"/*)
                    printf '~/%s\n' "${PWD#"$HOME"/}"
                    ;;
                *)
                    printf '%s\n' "$PWD"
                    ;;
            esac
            ;;
    esac
}

# Dynamic time prompt based on hour
dynamic_time_prompt() {
    local hour=$(date +%H)
    local color

    if (( hour >= 6 && hour < 12 )); then
        color=$PEACH
    elif (( hour >= 12 && hour < 18 )); then
        color=$TEAL
    elif (( hour >= 18 && hour < 21 )); then
        color=$MAUVE
    else
        color=$SOFT_GRAY
    fi

    echo "${color}$(date +%H:%M:%S)${RESET}"
}

# Build the prompt - bash version
build_prompt() {
    local GIT_INFO=$(parse_git_branch)
    local LEAD="⭐" HOST="" TITLE=""
    local USER_COLOR="${ROSEWATER}"
    if [ -n "$SSH_CONNECTION" ]; then
        LEAD="🌐"
        HOST="\[${MAUVE}\][\[${BOLD}${THEME_RED}\]\h\[${RESET}${MAUVE}\]] "
        TITLE="\[\e]0;\h: \w\a\]"
    fi
    if [ "$EUID" -eq 0 ]; then
        LEAD="🔥"
        USER_COLOR="${BOLD}${THEME_RED}"
    fi
    # Note: In bash, we need to escape the $ in the function call
    PS1="${TITLE}${LEAD} ${HOST}\[${MAUVE}\][\[${USER_COLOR}\]\u\[${RESET}${MAUVE}\]@\[${TEAL}\]\$(pretty_pwd)\[${MAUVE}\]]\[${PEACH}\]${GIT_INFO}\[${RESET}\] ➔ "

    # Optional: Add time to right side of prompt (requires special handling in bash)
    # For simpler setup, we'll skip the right prompt
}

# Set the prompt
PROMPT_COMMAND=build_prompt

# Load GNU aliases
if [ -f ~/.gnu_aliases ]; then
    source ~/.gnu_aliases
fi

# FZF configuration
export FZF_DEFAULT_OPTS="
  --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8
  --color=fg+:#f5e0dc,bg+:#313244,hl+:#fab387
  --color=info:#89b4fa,prompt:#94e2d5,pointer:#f5c2e7
  --color=marker:#a6e3a1,spinner:#b4befe,header:#cba6f7
  --layout=reverse
  --border
"

# fzf key bindings (Ctrl-R / Ctrl-T / Alt-C) and completion: the git installer
# writes ~/.fzf.bash; pacman/brew builds expose the same via `fzf --bash` (>= 0.48)
if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
elif command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash 2>/dev/null)"
fi

# PATH helper - prevents duplicates
path_prepend() {
    local dir p
    for dir in "$@"; do
        [[ -d "$dir" ]] || continue
        # Move an existing entry so the order doesn't depend on what set PATH first
        p=":$PATH:"
        while [[ "$p" == *":$dir:"* ]]; do p="${p//":$dir:"/:}"; done
        p="${p#:}"; p="${p%:}"
        PATH="$dir${p:+:$p}"
    done
}

path_append() {
    local dir p
    for dir in "$@"; do
        [[ -d "$dir" ]] || continue
        p=":$PATH:"
        while [[ "$p" == *":$dir:"* ]]; do p="${p//":$dir:"/:}"; done
        p="${p#:}"; p="${p%:}"
        PATH="${p:+$p:}$dir"
    done
}

path_prepend "/usr/local/sbin" "/usr/local/bin"
# macOS only: Homebrew, plus llvm last so Apple's clang and clangd stay the default
if [[ "$OSTYPE" == darwin* ]]; then
    path_prepend "/opt/homebrew/sbin" "/opt/homebrew/bin"
    path_append "/opt/homebrew/opt/llvm/bin"
fi
path_prepend "$HOME/bin" "$HOME/.local/bin" "$HOME/.cargo/bin"
export PATH

# Load custom shell functions
if [ -d ~/.config/shell-functions ]; then
    for f in ~/.config/shell-functions/*.sh; do
        [ -r "$f" ] && source "$f"
    done
fi

# ls/grep color aliases and LS_COLORS come from ~/.gnu_aliases (shared with zsh)

# Common aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# mise (version manager for Python, Node, etc.)
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
fi

# kubectl context switcher with fzf
kctx() {
    local selected
    selected=$(kubectl config get-contexts -o name | \
        fzf --prompt="Select context > " \
            --height=40% \
            --layout=reverse \
            --border \
            --ansi)

    if [[ -n "$selected" ]]; then
        kubectl config use-context "$selected"
    else
        echo "No context selected."
    fi
}

# Source local secrets (if exists)
[ -f ~/.env.secrets ] && source ~/.env.secrets
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Machine-local overrides - kept out of the repo, survives reinstalls
if [ -f "$HOME/.config/shell/local.sh" ]; then
  . "$HOME/.config/shell/local.sh"
fi
