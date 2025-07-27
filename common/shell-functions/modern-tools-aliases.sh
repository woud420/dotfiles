#!/bin/bash
# Modern CLI tool aliases and replacements

# Modern replacements for classic tools (if available)

# bat instead of cat
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
    alias c='bat'
fi

# exa instead of ls
if command -v exa >/dev/null 2>&1; then
    alias ls='exa'
    alias l='exa'
    alias la='exa -a'
    alias ll='exa -la'
    alias lt='exa -la --sort=modified'
    alias tree='exa --tree'
fi

# fd instead of find
if command -v fd >/dev/null 2>&1; then
    alias find='fd'
    alias ff='fd'
fi

# rg instead of grep
if command -v rg >/dev/null 2>&1; then
    alias grep='rg'
    alias rg='rg --smart-case'
    alias rgi='rg -i'  # case insensitive
    alias rgf='rg --files'  # list files only
fi

# delta for git diff
if command -v delta >/dev/null 2>&1; then
    alias gdiff='git diff | delta'
    alias gshow='git show | delta'
fi

# dust instead of du
if command -v dust >/dev/null 2>&1; then
    alias du='dust'
    alias dust='dust -r'  # reverse order (largest first)
fi

# procs instead of ps
if command -v procs >/dev/null 2>&1; then
    alias ps='procs'
    alias pst='procs --tree'  # tree view
    alias psk='procs --use-config=kernel'  # kernel processes
fi

# bottom instead of top/htop
if command -v btm >/dev/null 2>&1; then
    alias top='btm'
    alias htop='btm'
fi

# httpie for curl
if command -v http >/dev/null 2>&1; then
    alias get='http GET'
    alias post='http POST'
    alias put='http PUT'
    alias delete='http DELETE'
fi

# jq for JSON processing
if command -v jq >/dev/null 2>&1; then
    alias json='jq .'
    alias jsonp='jq . -C | less -R'  # pretty print with color
fi

# yq for YAML processing  
if command -v yq >/dev/null 2>&1; then
    alias yaml='yq .'
    alias yamlp='yq . -C | less -R'
fi

# mc (midnight commander) shortcuts
if command -v mc >/dev/null 2>&1; then
    alias files='mc'
    alias fm='mc'
fi

# fzf enhanced commands
if command -v fzf >/dev/null 2>&1; then
    # File finder with preview
    alias fzf='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
    
    # Enhanced cd with fzf
    fcd() {
        local dir
        dir=$(find . -type d -not -path '*/\.*' 2>/dev/null | fzf +m) && cd "$dir"
    }
    
    # Enhanced vim with fzf
    fvim() {
        local file
        file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}') && vim "$file"
    }
    
    # Process killer with fzf
    fkill() {
        local pid
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
        if [[ -n "$pid" ]]; then
            echo "$pid" | xargs kill "${1:--9}"
        fi
    }
    
    # Git branch switcher (enhanced)
    fgb() {
        local branch
        branch=$(git branch -a | sed 's/^..//' | sed 's/remotes\/origin\///' | sort -u | fzf)
        if [[ -n "$branch" ]]; then
            git checkout "$branch"
        fi
    }
    
    # History search
    fh() {
        eval $(history | fzf --tac --no-sort | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//')
    }
fi

# z for quick directory jumping
if command -v z >/dev/null 2>&1; then
    alias j='z'  # jump to directory
fi

# ag (silver searcher) alternatives
if command -v ag >/dev/null 2>&1; then
    alias search='ag'
    alias agi='ag -i'  # case insensitive
    alias agf='ag -l'  # files only
fi

# tldr for simplified man pages
if command -v tldr >/dev/null 2>&1; then
    alias help='tldr'
    alias examples='tldr'
fi

# micro editor
if command -v micro >/dev/null 2>&1; then
    alias edit='micro'
    alias m='micro'
fi

# lazygit for git TUI
if command -v lazygit >/dev/null 2>&1; then
    alias lg='lazygit'
    alias gitui='lazygit'
fi

# lazydocker for docker TUI
if command -v lazydocker >/dev/null 2>&1; then
    alias ld='lazydocker'
    alias dockerui='lazydocker'
fi

# k9s for kubernetes TUI
if command -v k9s >/dev/null 2>&1; then
    alias k9='k9s'
    alias kubeui='k9s'
fi

# ncdu for disk usage analyzer
if command -v ncdu >/dev/null 2>&1; then
    alias diskusage='ncdu'
    alias ncdu='ncdu --color dark'
fi

# bandwhich for network usage
if command -v bandwhich >/dev/null 2>&1; then
    alias netusage='sudo bandwhich'
fi

# gping for visual ping
if command -v gping >/dev/null 2>&1; then
    alias ping='gping'
    alias gping='gping --clear'
fi

# Modern git commands with enhanced output
if command -v git >/dev/null 2>&1; then
    # Enhanced git log
    alias glog='git log --oneline --graph --decorate --color=always'
    alias glol='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
    
    # Git status with short format
    alias gst='git status --short --branch'
    
    # Git diff with better formatting
    if command -v delta >/dev/null 2>&1; then
        export GIT_PAGER='delta'
    fi
fi

# Directory bookmarks (if available)
if [[ -f ~/.config/shell-functions/bookmarks.sh ]]; then
    source ~/.config/shell-functions/bookmarks.sh
fi

# Function to install missing tools
install-modern-tools() {
    echo "Installing modern CLI tools..."
    
    if command -v brew >/dev/null 2>&1; then
        # macOS with Homebrew
        brew install bat exa fd ripgrep delta dust procs bottom httpie jq yq fzf lazygit k9s
    elif command -v apt >/dev/null 2>&1; then
        # Debian/Ubuntu
        sudo apt update
        sudo apt install -y bat fd-find ripgrep jq fzf
    elif command -v yum >/dev/null 2>&1; then
        # RHEL/CentOS
        sudo yum install -y bat fd-find ripgrep jq fzf
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        sudo pacman -S bat fd ripgrep jq fzf
    else
        echo "Package manager not supported. Install tools manually."
    fi
}

# List available modern tools
list-modern-tools() {
    echo "Modern CLI tools status:"
    
    local tools=(
        "bat:Enhanced cat with syntax highlighting"
        "exa:Modern ls replacement"  
        "fd:Simple find alternative"
        "rg:Fast grep alternative"
        "delta:Better git diff"
        "dust:Intuitive du alternative"
        "procs:Modern ps replacement"
        "btm:Resource monitor (top alternative)"
        "http:User-friendly curl"
        "jq:JSON processor"
        "yq:YAML processor"
        "fzf:Fuzzy finder"
        "lazygit:Git TUI"
        "k9s:Kubernetes TUI"
        "micro:Terminal-based text editor"
    )
    
    for tool_info in "${tools[@]}"; do
        local tool="${tool_info%%:*}"
        local desc="${tool_info#*:}"
        
        if command -v "$tool" >/dev/null 2>&1; then
            echo "✅ $tool - $desc"
        else
            echo "❌ $tool - $desc"
        fi
    done
}