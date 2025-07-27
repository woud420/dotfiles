#!/bin/bash
# Kubernetes functions and helpers

# Fuzzy kubectl context switcher
kctx() {
    if ! command -v kubectl >/dev/null 2>&1; then
        echo "kubectl not found"
        return 1
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Available contexts:"
        kubectl config get-contexts -o name
        return 0
    fi
    
    local selected
    selected=$(kubectl config get-contexts -o name | \
        fzf --prompt="Select context > " \
            --height=40% \
            --layout=reverse \
            --border \
            --preview='kubectl config get-contexts | grep {}' \
            --ansi)

    if [[ -n "$selected" ]]; then
        kubectl config use-context "$selected"
        echo "Switched to context: $selected"
    else
        echo "No context selected."
    fi
}

# Fuzzy kubectl namespace switcher
kns() {
    if ! command -v kubectl >/dev/null 2>&1; then
        echo "kubectl not found"
        return 1
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        kubectl get namespaces
        return 0
    fi
    
    local selected
    selected=$(kubectl get namespaces -o name | sed 's/namespace\///' | \
        fzf --prompt="Select namespace > " \
            --height=40% \
            --layout=reverse \
            --border \
            --preview='kubectl get pods -n {} --no-headers 2>/dev/null | head -10')

    if [[ -n "$selected" ]]; then
        kubectl config set-context --current --namespace="$selected"
        echo "Switched to namespace: $selected"
    else
        echo "No namespace selected."
    fi
}

# Fuzzy pod selector
kpod() {
    if ! command -v kubectl >/dev/null 2>&1; then
        echo "kubectl not found"
        return 1
    fi
    
    local namespace=""
    if [[ $1 == "-n" ]] && [[ -n $2 ]]; then
        namespace="-n $2"
        shift 2
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        kubectl get pods $namespace
        return 0
    fi
    
    local selected
    selected=$(kubectl get pods $namespace -o name | sed 's/pod\///' | \
        fzf --prompt="Select pod > " \
            --height=40% \
            --layout=reverse \
            --border \
            --preview="kubectl describe pod {} $namespace")

    if [[ -n "$selected" ]]; then
        if [[ $# -eq 0 ]]; then
            echo "Selected pod: $selected"
            echo "$selected"
        else
            kubectl "$@" "$selected" $namespace
        fi
    fi
}

# Quick pod logs with follow
klogs() {
    local pod=$(kpod)
    if [[ -n "$pod" ]]; then
        kubectl logs -f "$pod"
    fi
}

# Execute into pod
kexec() {
    local pod=$(kpod)
    if [[ -n "$pod" ]]; then
        local shell="${1:-bash}"
        kubectl exec -it "$pod" -- "$shell"
    fi
}

# Port forward to pod
kport() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: kport local_port [remote_port]"
        return 1
    fi
    
    local local_port="$1"
    local remote_port="${2:-$1}"
    local pod=$(kpod)
    
    if [[ -n "$pod" ]]; then
        echo "Port forwarding $local_port:$remote_port to $pod"
        kubectl port-forward "$pod" "$local_port:$remote_port"
    fi
}

# Get pod by label selector
kget() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: kget <resource> [label_selector]"
        echo "Example: kget pods app=nginx"
        return 1
    fi
    
    local resource="$1"
    shift
    
    if [[ $# -gt 0 ]]; then
        kubectl get "$resource" -l "$*"
    else
        kubectl get "$resource"
    fi
}

# Describe resource with fuzzy selection
kdesc() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: kdesc <resource_type>"
        echo "Example: kdesc pods"
        return 1
    fi
    
    local resource="$1"
    
    if ! command -v fzf >/dev/null 2>&1; then
        kubectl get "$resource"
        return 0
    fi
    
    local selected
    selected=$(kubectl get "$resource" -o name | \
        fzf --prompt="Select $resource > " \
            --height=40% \
            --layout=reverse \
            --border)

    if [[ -n "$selected" ]]; then
        kubectl describe "$selected"
    fi
}

# Watch resources
kwatch() {
    if [[ $# -eq 0 ]]; then
        kubectl get pods -w
    else
        kubectl get "$@" -w
    fi
}

# Top pods/nodes
ktop() {
    local resource="${1:-pods}"
    kubectl top "$resource"
}

# Current context and namespace info
kinfo() {
    echo "Context: $(kubectl config current-context 2>/dev/null || echo 'None')"
    echo "Namespace: $(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo 'default')"
    echo "Server: $(kubectl config view --minify --output 'jsonpath={.clusters[0].cluster.server}' 2>/dev/null || echo 'Unknown')"
}

# Delete resource with confirmation
kdel() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: kdel <resource_type>"
        return 1
    fi
    
    local resource="$1"
    
    if ! command -v fzf >/dev/null 2>&1; then
        kubectl get "$resource"
        return 0
    fi
    
    local selected
    selected=$(kubectl get "$resource" -o name | \
        fzf -m --prompt="Select $resource to delete > " \
            --height=40% \
            --layout=reverse \
            --border)

    if [[ -n "$selected" ]]; then
        echo "About to delete:"
        echo "$selected"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "$selected" | xargs kubectl delete
        fi
    fi
}

# Restart deployment
krestart() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: krestart <deployment_name>"
        return 1
    fi
    
    kubectl rollout restart deployment "$1"
}

# Scale deployment
kscale() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: kscale <deployment_name> <replicas>"
        return 1
    fi
    
    kubectl scale deployment "$1" --replicas="$2"
}

# Apply with validation
kapply() {
    kubectl apply --dry-run=client -f "$@" && kubectl apply -f "$@"
}

# Aliases
alias k='kubectl'
alias kc='kctx'
alias kn='kns'
alias kp='kpod'
alias kl='klogs'
alias ke='kexec'
alias kf='kport'
alias kg='kget'
alias kd='kdesc'
alias kw='kwatch'
alias kt='ktop'
alias ki='kinfo'
alias krm='kdel'
alias kr='krestart'
alias ks='kscale'
alias ka='kapply'