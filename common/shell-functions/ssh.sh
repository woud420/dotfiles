#!/bin/bash
# SSH and remote connection functions

# SSH with automatic dotfile installation
sshdot() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: sshdot user@host"
        return 1
    fi
    
    local host="$1"
    local install_cmd='curl -sSL https://raw.githubusercontent.com/woud420/dotfiles/master/scripts/minimal-bashrc.sh | bash'
    
    ssh -t "$host" "${install_cmd} && exec bash"
}

# SSH with temporary dotfiles (doesn't modify remote)
ssht() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ssht user@host"
        return 1
    fi
    
    local host="$1"
    local bashrc_url='https://raw.githubusercontent.com/woud420/dotfiles/master/common/shell/.bashrc.server'
    
    ssh -t "$host" "bash --rcfile <(curl -sSL $bashrc_url)"
}

# SSH and immediately install full dotfiles
sshfull() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: sshfull user@host"
        return 1
    fi
    
    local host="$1"
    local install_cmd='curl -sSL https://raw.githubusercontent.com/woud420/dotfiles/master/scripts/quick-install.sh | bash'
    
    ssh -t "$host" "${install_cmd} && exec bash"
}

# Copy dotfiles to remote host using scp
copy-dots() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: copy-dots user@host"
        return 1
    fi
    
    local host="$1"
    local script_path="${DOTFILES_DIR:-$HOME/.dotfiles}/scripts/ssh-copy-dotfiles.sh"
    
    if [[ -f "$script_path" ]]; then
        "$script_path" "$host"
    else
        echo "Error: ssh-copy-dotfiles.sh not found at $script_path"
        return 1
    fi
}

# SSH with port forwarding helper
sshport() {
    if [[ $# -lt 3 ]]; then
        echo "Usage: sshport local_port remote_port user@host"
        echo "Example: sshport 8080 80 user@webserver"
        return 1
    fi
    
    local local_port="$1"
    local remote_port="$2" 
    local host="$3"
    
    echo "Forwarding localhost:$local_port -> $host:$remote_port"
    ssh -L "$local_port:localhost:$remote_port" "$host"
}

# SSH tunnel with dynamic port forwarding (SOCKS proxy)
sshsocks() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: sshsocks [port] user@host"
        echo "Default port: 1080"
        return 1
    fi
    
    local port="1080"
    local host
    
    if [[ $# -eq 2 ]]; then
        port="$1"
        host="$2"
    else
        host="$1"
    fi
    
    echo "Starting SOCKS proxy on localhost:$port via $host"
    ssh -D "$port" -C -N "$host"
}

# SSH with X11 forwarding
sshx() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: sshx user@host"
        return 1
    fi
    
    ssh -X "$@"
}

# Quick SSH connection with common options
sshq() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: sshq user@host"
        return 1
    fi
    
    # -o ConnectTimeout=10: 10 second connection timeout
    # -o ServerAliveInterval=60: Send keepalive every 60 seconds
    # -o ServerAliveCountMax=3: Disconnect after 3 failed keepalives
    ssh -o ConnectTimeout=10 -o ServerAliveInterval=60 -o ServerAliveCountMax=3 "$@"
}

# SSH and run a command, then stay connected
sshrun() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: sshrun user@host 'command'"
        return 1
    fi
    
    local host="$1"
    local cmd="$2"
    
    ssh -t "$host" "$cmd; exec bash"
}

# Aliases for convenience
alias sd='sshdot'
alias st='ssht'
alias sf='sshfull'