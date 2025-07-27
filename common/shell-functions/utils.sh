#!/bin/bash
# General utility functions

# Create directory and cd into it
mkcd() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: mkcd directory_name"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: extract archive_file"
        return 1
    fi
    
    if [[ ! -f "$1" ]]; then
        echo "Error: '$1' is not a valid file"
        return 1
    fi
    
    case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.rar)       rar x "$1"       ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *)           echo "Error: '$1' cannot be extracted" ;;
    esac
}

# Find files and directories
ff() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ff pattern [path]"
        return 1
    fi
    
    local pattern="$1"
    local path="${2:-.}"
    
    find "$path" -iname "*$pattern*" 2>/dev/null
}

# Find in files
findin() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: findin pattern [path]"
        return 1
    fi
    
    local pattern="$1"
    local path="${2:-.}"
    
    if command -v rg >/dev/null 2>&1; then
        rg -i "$pattern" "$path"
    elif command -v grep >/dev/null 2>&1; then
        grep -r -i "$pattern" "$path"
    else
        echo "No search tool found (rg or grep)"
        return 1
    fi
}

# Process finder
psg() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: psg process_name"
        return 1
    fi
    
    ps aux | grep -i "$1" | grep -v grep
}

# Kill process by name
killall() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: killall process_name"
        return 1
    fi
    
    local pids=$(psg "$1" | awk '{print $2}')
    if [[ -n "$pids" ]]; then
        echo "Killing processes: $pids"
        echo "$pids" | xargs kill
    else
        echo "No processes found matching '$1'"
    fi
}

# Weather
weather() {
    local location="${1:-}"
    curl -s "wttr.in/${location}?format=3"
}

# URL encode
urlencode() {
    python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"
}

# URL decode
urldecode() {
    python3 -c "import urllib.parse; print(urllib.parse.unquote('$1'))"
}

# Generate password
genpass() {
    local length="${1:-16}"
    openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length"
}

# Get public IP
myip() {
    curl -s ifconfig.me
}

# Get local IP
localip() {
    if command -v ip >/dev/null 2>&1; then
        ip route get 1 | awk '{print $7}' | head -1
    elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | head -1
    else
        echo "No network tool found"
    fi
}

# File size in human readable format
sizeof() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: sizeof file_or_directory"
        return 1
    fi
    
    du -sh "$1"
}

# Tree with fallback
tree() {
    if command -v tree >/dev/null 2>&1; then
        command tree "$@"
    else
        find "${1:-.}" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
    fi
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    local dir="${2:-.}"
    
    echo "Serving $dir on http://localhost:$port"
    
    if command -v python3 >/dev/null 2>&1; then
        cd "$dir" && python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        cd "$dir" && python -m SimpleHTTPServer "$port"
    else
        echo "Python not found"
        return 1
    fi
}

# Backup file with timestamp
backup() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: backup file"
        return 1
    fi
    
    local file="$1"
    local backup_name="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    cp "$file" "$backup_name"
    echo "Backed up $file to $backup_name"
}

# Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias h='history'
alias path='echo $PATH | tr ":" "\n"'
alias reload='source ~/.bashrc || source ~/.zshrc'