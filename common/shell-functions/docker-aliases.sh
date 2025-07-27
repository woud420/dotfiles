#!/bin/bash
# Docker short aliases

# Check if docker is available
if ! command -v docker >/dev/null 2>&1; then
    return 0
fi

# Core docker alias
alias d='docker'

# Images
alias di='docker images'
alias dip='docker image prune'
alias dipa='docker image prune -a'

# Containers
alias dc='docker ps'
alias dca='docker ps -a'
alias dcp='docker container prune'

# Run containers
alias dr='docker run'
alias dri='docker run -it'
alias drr='docker run --rm'
alias drir='docker run -it --rm'

# Execute into containers
alias de='docker exec'
alias dei='docker exec -it'

# Start, stop, restart
alias dst='docker stop'
alias dsta='docker start'
alias dre='docker restart'

# Logs
alias dl='docker logs'
alias dlf='docker logs -f'
alias dlt='docker logs --tail'

# Build
alias db='docker build'
alias dbt='docker build -t'

# Pull and push
alias dpl='docker pull'
alias dps='docker push'

# Remove
alias drm='docker rm'
alias drmi='docker rmi'
alias drmf='docker rm -f'

# System commands
alias dinfo='docker info'
alias dver='docker version'
alias dsys='docker system'
alias ddf='docker system df'
alias dclean='docker system prune -af'

# Volume operations
alias dv='docker volume'
alias dvl='docker volume ls'
alias dvp='docker volume prune'
alias dvc='docker volume create'
alias dvr='docker volume rm'

# Network operations
alias dn='docker network'
alias dnl='docker network ls'
alias dnp='docker network prune'
alias dnc='docker network create'
alias dnr='docker network rm'

# Docker Compose aliases
alias dco='docker-compose'
alias dcup='docker-compose up'
alias dcupd='docker-compose up -d'
alias dcdown='docker-compose down'
alias dcstop='docker-compose stop'
alias dcstart='docker-compose start'
alias dcrestart='docker-compose restart'
alias dcps='docker-compose ps'
alias dclogs='docker-compose logs'
alias dclogsf='docker-compose logs -f'
alias dcbuild='docker-compose build'
alias dcpull='docker-compose pull'
alias dcexec='docker-compose exec'
alias dcrun='docker-compose run'

# Shorthand functions
dsh() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: dsh container_name_or_id"
        return 1
    fi
    docker exec -it "$1" bash || docker exec -it "$1" sh
}

# Quick container run with common options
drun() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: drun image [command]"
        return 1
    fi
    docker run -it --rm "$@"
}

# Run with port mapping
drunp() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: drunp port image [command]"
        return 1
    fi
    local port="$1"
    shift
    docker run -it --rm -p "$port:$port" "$@"
}

# Build and tag with current directory name
dbuild() {
    local tag="${1:-$(basename $(pwd))}"
    docker build -t "$tag" .
}

# Run latest build
drunl() {
    local tag="${1:-$(basename $(pwd))}"
    docker run -it --rm "$tag"
}

# Stop all containers
dstopa() {
    docker stop $(docker ps -q)
}

# Remove all stopped containers
drma() {
    docker rm $(docker ps -aq)
}

# Remove all images
drmia() {
    docker rmi $(docker images -q)
}

# Show container resource usage
dstats() {
    docker stats --no-stream
}

# Follow logs for multiple containers
dlogsm() {
    if [[ $# -eq 0 ]]; then
        docker logs -f $(docker ps --format "{{.Names}}" | head -5 | tr '\n' ' ')
    else
        docker logs -f "$@"
    fi
}

# Quick alpine container for testing
dalp() {
    docker run -it --rm alpine:latest sh
}

# Quick ubuntu container for testing
dub() {
    docker run -it --rm ubuntu:latest bash
}

# List containers with custom format
dlsc() {
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
}

# List images with custom format
dlsi() {
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"
}

# Docker inspect with jq
dinspect() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: dinspect container_name_or_id [jq_filter]"
        return 1
    fi
    
    local container="$1"
    local filter="${2:-.}"
    
    if command -v jq >/dev/null 2>&1; then
        docker inspect "$container" | jq "$filter"
    else
        docker inspect "$container"
    fi
}

# Copy files to/from containers
dcp() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: dcp container:path local_path OR dcp local_path container:path"
        return 1
    fi
    docker cp "$1" "$2"
}