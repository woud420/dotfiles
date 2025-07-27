#!/bin/bash
# System and file operation aliases

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# List commands
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias lt='ls -altr'  # Sort by time, newest last
alias lh='ls -alh'   # Human readable sizes
alias lsd='ls -d */' # List only directories

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto' 
alias egrep='egrep --color=auto'

# File operations with safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# File sizes
alias du='du -h'
alias df='df -h'
alias free='free -h'

# Process operations
alias ps='ps aux'
alias psg='ps aux | grep'
alias top='htop || top'
alias jobs='jobs -l'

# Network
alias ping='ping -c 5'
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'
alias localip='hostname -I | awk "{print \$1}"'

# File finding and searching
alias ff='find . -name'
alias fd='find . -type d -name'
alias fgrep='grep -r'

# Archive operations
alias tar='tar -v'
alias untar='tar -xvf'
alias targz='tar -czvf'
alias untargz='tar -xzvf'

# Permission shortcuts
alias 000='chmod 000'
alias 644='chmod 644'
alias 755='chmod 755'
alias 777='chmod 777'
alias mx='chmod +x'

# History
alias h='history'
alias hg='history | grep'
alias hl='history | tail -20'

# Date and time
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
alias timestamp='date "+%Y-%m-%d %H:%M:%S"'

# Path
alias path='echo $PATH | tr ":" "\n"'

# Reload shell
alias reload='source ~/.bashrc || source ~/.zshrc'

# Clear screen variants
alias c='clear'
alias cls='clear'

# Make directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick backup
bak() {
    cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
}

# Extract various archive types
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
        *.rar)       unrar x "$1"     ;;
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

# Find and kill process
killproc() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: killproc process_name"
        return 1
    fi
    ps aux | grep "$1" | grep -v grep | awk '{print $2}' | xargs kill
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    echo "Starting HTTP server on port $port..."
    if command -v python3 >/dev/null 2>&1; then
        python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        python -m SimpleHTTPServer "$port"
    else
        echo "Python not found"
    fi
}

# File count in directory
count() {
    local dir="${1:-.}"
    echo "Files: $(find "$dir" -type f | wc -l)"
    echo "Directories: $(find "$dir" -type d | wc -l)"
}

# Disk usage of current directory
usage() {
    du -sh * | sort -h
}

# Show environment variables
alias env='env | sort'
alias envg='env | grep -i'

# System info
sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime)"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Memory Usage:"
    free -h
    echo "Disk Usage:"
    df -h
}

# Weather
weather() {
    local location="${1:-}"
    curl -s "wttr.in/${location}?format=3"
}

# Generate random password
genpass() {
    local length="${1:-16}"
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 32 | tr -d "=+/" | cut -c1-"$length"
    else
        < /dev/urandom tr -dc A-Za-z0-9 | head -c"$length"; echo
    fi
}

# Copy to clipboard (if available)
if command -v pbcopy >/dev/null 2>&1; then
    alias clip='pbcopy'
elif command -v xclip >/dev/null 2>&1; then
    alias clip='xclip -selection clipboard'
fi

# Get file info
finfo() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: finfo file"
        return 1
    fi
    echo "File: $1"
    echo "Size: $(ls -lh "$1" | awk '{print $5}')"
    echo "Modified: $(ls -l "$1" | awk '{print $6, $7, $8}')"
    echo "Permissions: $(ls -l "$1" | awk '{print $1}')"
    echo "Type: $(file "$1")"
}