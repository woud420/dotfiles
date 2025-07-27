#!/bin/bash
# Git functions and helpers

# Fuzzy git branch checkout
git-ch() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        echo "fzf not found, using basic branch selector"
        git branch --sort=-committerdate
        return 1
    fi
    
    local branch
    branch=$(git branch --sort=-committerdate | sed 's/* //' | sed 's/^[[:space:]]*//' | \
        fzf --prompt="Checkout branch > " \
            --height=40% \
            --layout=reverse \
            --border \
            --preview='git log --oneline --color=always -10 {}' \
            --preview-window=right:50%:wrap)
    
    if [[ -n "$branch" ]]; then
        git checkout "$branch"
    fi
}

# Create and checkout new branch
git-new() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: git-new branch-name"
        return 1
    fi
    
    git checkout -b "$1"
}

# Fuzzy git log viewer
git-log() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        git log --oneline -20
        return 0
    fi
    
    git log --oneline --color=always | \
    fzf --ansi \
        --preview='git show --color=always {1}' \
        --preview-window=right:60%:wrap \
        --bind='enter:execute(git show {1} | less -R)'
}

# Interactive git add with fzf
git-add() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        git add -i
        return 0
    fi
    
    local files
    files=$(git status --porcelain | \
        fzf -m --preview='
            if [[ {1} == "??" ]]; then
                bat --color=always {2} 2>/dev/null || cat {2}
            else
                git diff --color=always {2}
            fi' \
        --preview-window=right:60%:wrap | \
        awk '{print $2}')
    
    if [[ -n "$files" ]]; then
        echo "$files" | xargs git add
        echo "Added files:"
        echo "$files"
    fi
}

# Show git status with fzf preview
git-status() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        git status
        return 0
    fi
    
    git status --porcelain | \
    fzf --preview='
        if [[ {1} == "??" ]]; then
            bat --color=always {2} 2>/dev/null || cat {2}
        else
            git diff --color=always {2}
        fi' \
    --preview-window=right:60%:wrap \
    --header='Git Status - Enter to show diff'
}

# Fuzzy git stash management
git-stash() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        git stash list
        return 0
    fi
    
    local stash
    stash=$(git stash list | \
        fzf --preview='git stash show -p {1}' \
            --preview-window=right:60%:wrap \
            --header='Select stash to apply (Ctrl-D to drop)' \
            --bind='ctrl-d:execute(git stash drop {1})+reload(git stash list)')
    
    if [[ -n "$stash" ]]; then
        local stash_id=$(echo "$stash" | cut -d: -f1)
        git stash apply "$stash_id"
    fi
}

# Quick commit with message
git-quick() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: git-quick 'commit message'"
        return 1
    fi
    
    git add . && git commit -m "$*"
}

# Push current branch to origin
git-push() {
    local branch=$(git branch --show-current)
    if [[ -z "$branch" ]]; then
        echo "Not on any branch"
        return 1
    fi
    
    git push -u origin "$branch"
}

# Pull with rebase
git-sync() {
    git pull --rebase
}

# Show branch info
git-info() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    echo "Repository: $(basename $(git rev-parse --show-toplevel))"
    echo "Branch: $(git branch --show-current)"
    echo "Remote: $(git remote get-url origin 2>/dev/null || echo 'No remote')"
    echo "Last commit: $(git log -1 --pretty=format:'%h - %s (%cr)' 2>/dev/null)"
    echo "Status:"
    git status --porcelain | head -10
}

# Delete merged branches
git-cleanup() {
    echo "Deleting merged branches..."
    git branch --merged | grep -v '\*\|main\|master\|develop' | xargs -n 1 git branch -d
}

# Fuzzy git branch delete
git-delete() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "fzf required for interactive branch deletion"
        return 1
    fi
    
    local branches
    branches=$(git branch | grep -v '\*' | fzf -m --header='Select branches to delete')
    
    if [[ -n "$branches" ]]; then
        echo "$branches" | xargs -n 1 git branch -d
    fi
}

# Aliases
alias gch='git-ch'
alias gnew='git-new'
alias glog='git-log'
alias gadd='git-add'
alias gst='git-status'
alias gstash='git-stash'
alias gq='git-quick'
alias gp='git-push'
alias gsync='git-sync'
alias ginfo='git-info'
alias gclean='git-cleanup'
alias gdel='git-delete'