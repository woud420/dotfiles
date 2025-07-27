#!/bin/bash
# Docker functions and helpers

# Fuzzy docker container selector
dcon() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "docker not found"
        return 1
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        docker ps
        return 0
    fi
    
    local selected
    selected=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | \
        tail -n +2 | \
        fzf --prompt="Select container > " \
            --height=40% \
            --layout=reverse \
            --border \
            --preview='docker inspect {1}' | \
        awk '{print $1}')

    if [[ -n "$selected" ]]; then
        if [[ $# -eq 0 ]]; then
            echo "$selected"
        else
            docker "$@" "$selected"
        fi
    fi
}

# Execute into container
dexec() {
    local container=$(dcon)
    if [[ -n "$container" ]]; then
        local shell="${1:-bash}"
        docker exec -it "$container" "$shell"
    fi
}

# View container logs
dlogs() {
    local container=$(dcon)
    if [[ -n "$container" ]]; then
        docker logs -f "$container"
    fi
}

# Stop containers
dstop() {
    if ! command -v fzf >/dev/null 2>&1; then
        docker ps
        return 0
    fi
    
    local containers
    containers=$(docker ps --format "{{.Names}}" | \
        fzf -m --prompt="Select containers to stop > " \
            --height=40% \
            --layout=reverse \
            --border)

    if [[ -n "$containers" ]]; then
        echo "$containers" | xargs docker stop
    fi
}

# Remove containers
drm() {
    if ! command -v fzf >/dev/null 2>&1; then
        docker ps -a
        return 0
    fi
    
    local containers
    containers=$(docker ps -a --format "{{.Names}}" | \
        fzf -m --prompt="Select containers to remove > " \
            --height=40% \
            --layout=reverse \
            --border)

    if [[ -n "$containers" ]]; then
        echo "$containers" | xargs docker rm
    fi
}

# Remove images
drmi() {
    if ! command -v fzf >/dev/null 2>&1; then
        docker images
        return 0
    fi
    
    local images
    images=$(docker images --format "{{.Repository}}:{{.Tag}}" | \
        fzf -m --prompt="Select images to remove > " \
            --height=40% \
            --layout=reverse \
            --border)

    if [[ -n "$images" ]]; then
        echo "$images" | xargs docker rmi
    fi
}

# Docker system cleanup
dclean() {
    echo "Cleaning up Docker..."
    docker system prune -af
    docker volume prune -f
}

# Quick container run with common options
drun() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: drun image [command]"
        return 1
    fi
    
    local image="$1"
    shift
    
    docker run -it --rm "$image" "$@"
}

# Build with tag
dbuild() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: dbuild tag [dockerfile_path]"
        return 1
    fi
    
    local tag="$1"
    local dockerfile="${2:-.}"
    
    docker build -t "$tag" "$dockerfile"
}

# Docker compose helpers
dc() {
    docker-compose "$@"
}

dcup() {
    docker-compose up -d
}

dcdown() {
    docker-compose down
}

dclogs() {
    docker-compose logs -f "$@"
}

# Aliases
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias de='dexec'
alias dl='dlogs'
alias ds='dstop'
alias dr='drun'
alias db='dbuild'