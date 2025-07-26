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

# Colors using tput for better compatibility
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support
    ROSEWATER=$(tput setaf 217)
    MAUVE=$(tput setaf 183)
    TEAL=$(tput setaf 116)
    PEACH=$(tput setaf 215)
    SOFT_GRAY=$(tput setaf 243)
    RESET=$(tput sgr0)
else
    # No color support, use empty strings
    ROSEWATER=""
    MAUVE=""
    TEAL=""
    PEACH=""
    SOFT_GRAY=""
    RESET=""
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
            # For bash, use \w for relative path
            echo "\w"
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
    # Note: In bash, we need to escape the $ in the function call
    PS1="⭐ ${MAUVE}[${ROSEWATER}\u${MAUVE}@${TEAL}\$(pretty_pwd)${MAUVE}]${PEACH}${GIT_INFO}${RESET} ➔ "
    
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

# Source FZF if available
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Load custom shell functions
if [ -d ~/.config/shell-functions ]; then
    for f in ~/.config/shell-functions/*.sh; do
        [ -r "$f" ] && source "$f"
    done
fi

# Kubernetes context switcher
kctx() {
    if ! command -v kubectl >/dev/null 2>&1; then
        echo "kubectl not found"
        return 1
    fi
    
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

# Git branch switcher
git-ch() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    local branch
    branch=$(git branch --sort=-committerdate | sed 's/* //' | sed 's/^[[:space:]]*//' | \
        fzf --prompt="Checkout branch > " \
            --height=40% \
            --layout=reverse \
            --border)
    if [[ -n "$branch" ]]; then
        git checkout "$branch"
    fi
}

# Aliases
alias kc=kctx
alias gch="git-ch"

# Add local bin to PATH if exists
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# Export PATH
export PATH

# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

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