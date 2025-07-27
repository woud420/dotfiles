#!/bin/bash
# Git short aliases and helpers

# Core git aliases
alias g='git'

# Status and info
alias gs='git status'
alias gss='git status -s'
alias gsb='git status -sb'

# Add and commit
alias ga='git add'
alias gaa='git add .'
alias gap='git add -p'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'

# Push and pull
alias gp='git push'
alias gpu='git push -u origin'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias glr='git pull --rebase'

# Branch operations
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main || git checkout master'
alias gcd='git checkout develop'

# Log and diff
alias glog='git log --oneline'
alias glg='git log --graph --oneline --decorate'
alias glga='git log --graph --oneline --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gdh='git diff HEAD'

# Stash
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gstd='git stash drop'

# Remote
alias gr='git remote'
alias grv='git remote -v'
alias gra='git remote add'
alias grr='git remote remove'

# Reset and clean
alias grh='git reset HEAD'
alias grhh='git reset --hard HEAD'
alias gclean='git clean -fd'

# Merge and rebase
alias gm='git merge'
alias gmn='git merge --no-ff'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'

# Show and describe
alias gsh='git show'
alias gsp='git show --pretty=fuller'

# Tags
alias gt='git tag'
alias gta='git tag -a'
alias gtd='git tag -d'

# Worktree
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtl='git worktree list'
alias gwtr='git worktree remove'

# Submodules
alias gsm='git submodule'
alias gsmu='git submodule update'
alias gsmi='git submodule init'

# Config
alias gcf='git config'
alias gcfl='git config --list'
alias gcfg='git config --global'

# Common workflows
alias gup='git fetch && git rebase'
alias gsync='git fetch origin && git rebase origin/main || git rebase origin/master'
alias gclone='git clone'

# Quick commit workflows
alias gwip='git add . && git commit -m "WIP"'
alias gunwip='git reset HEAD~1'
alias gquick='git add . && git commit -m'

# Undo operations
alias gundo='git reset --soft HEAD~1'
alias gredo='git reset --hard HEAD~1'

# Find and search
alias ggrep='git grep'
alias gfind='git ls-files | grep'

# Pretty log formats
alias glp='git log --pretty=format:"%h %s (%cr) <%an>" --abbrev-commit'
alias glpg='git log --pretty=format:"%h %s (%cr) <%an>" --abbrev-commit --graph'

# Branch management helpers
gbclean() {
    echo "Deleting merged branches..."
    git branch --merged | grep -v '\*\|main\|master\|develop' | xargs -n 1 git branch -d
}

# Quick push current branch
gpush() {
    local branch=$(git branch --show-current)
    if [[ -n "$branch" ]]; then
        git push -u origin "$branch"
    else
        echo "No current branch found"
    fi
}

# Switch to previous branch
alias g-='git checkout -'
alias gco-='git checkout -'

# Interactive rebase last N commits
grbn() {
    local count="${1:-5}"
    git rebase -i "HEAD~$count"
}

# Commit with ticket number from branch
gcmt() {
    local branch=$(git branch --show-current)
    local ticket=$(echo "$branch" | grep -o '[A-Z]\+-[0-9]\+' | head -1)
    
    if [[ -n "$ticket" ]]; then
        git commit -m "[$ticket] $*"
    else
        git commit -m "$*"
    fi
}

# Show files changed in last commit
alias gfiles='git diff-tree --no-commit-id --name-only -r HEAD'

# Show authors
alias gauthors='git shortlog -sn'

# Blame with line numbers
gblame() {
    git blame -L "${2:-1},+${3:-10}" "$1"
}

# Create and push new branch
gnb() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: gnb branch_name"
        return 1
    fi
    git checkout -b "$1" && git push -u origin "$1"
}

# Show git aliases
galias() {
    git config --get-regexp alias
}