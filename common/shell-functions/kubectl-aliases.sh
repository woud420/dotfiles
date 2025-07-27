#!/bin/bash
# Kubectl short aliases - inspired by common k8s workflows

# Check if kubectl is available
if ! command -v kubectl >/dev/null 2>&1; then
    return 0
fi

# Core kubectl alias
alias k='kubectl'

# Get resources (most common)
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployment'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kgi='kubectl get ingress'
alias kgc='kubectl get configmap'
alias kgsec='kubectl get secrets'
alias kgpv='kubectl get pv'
alias kgpvc='kubectl get pvc'
alias kgsa='kubectl get serviceaccount'

# Get with output formats
alias kgpw='kubectl get pods -o wide'
alias kgsw='kubectl get svc -o wide'
alias kgdw='kubectl get deployment -o wide'
alias kgnw='kubectl get nodes -o wide'

# Get with YAML/JSON output
alias kgpy='kubectl get pods -o yaml'
alias kgsy='kubectl get svc -o yaml'
alias kgdy='kubectl get deployment -o yaml'
alias kgpj='kubectl get pods -o json'
alias kgsj='kubectl get svc -o json'
alias kgdj='kubectl get deployment -o json'

# Describe resources
alias kdp='kubectl describe pod'
alias kds='kubectl describe svc'
alias kdd='kubectl describe deployment'
alias kdn='kubectl describe node'
alias kdi='kubectl describe ingress'
alias kdc='kubectl describe configmap'
alias kdsec='kubectl describe secret'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias klp='kubectl logs --previous'

# Execute into pods
alias kex='kubectl exec -it'
alias ksh='kubectl exec -it'

# Delete resources
alias kdel='kubectl delete'
alias kdelp='kubectl delete pod'
alias kdels='kubectl delete svc'
alias kdeld='kubectl delete deployment'

# Edit resources
alias ked='kubectl edit'
alias kedp='kubectl edit pod'
alias keds='kubectl edit svc'
alias kedd='kubectl edit deployment'

# Apply and create
alias ka='kubectl apply -f'
alias kaf='kubectl apply -f'
alias kcr='kubectl create'
alias krun='kubectl run'

# Port forwarding
alias kpf='kubectl port-forward'

# Context and namespace
alias kctx='kubectl config current-context'
alias kns='kubectl config view --minify --output "jsonpath={..namespace}"'
alias kuc='kubectl config use-context'
alias kun='kubectl config set-context --current --namespace'

# Top commands
alias ktop='kubectl top'
alias ktopp='kubectl top pods'
alias ktopn='kubectl top nodes'

# Scale
alias kscale='kubectl scale'

# Rollout
alias kroll='kubectl rollout'
alias krollh='kubectl rollout history'
alias krolls='kubectl rollout status'
alias krollr='kubectl rollout restart'
alias krollu='kubectl rollout undo'

# Get all resources in namespace
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# Watch commands
alias kwp='kubectl get pods -w'
alias kws='kubectl get svc -w'
alias kwd='kubectl get deployment -w'

# Common combined operations
alias kgpan='kubectl get pods --all-namespaces'
alias kgsan='kubectl get svc --all-namespaces'
alias kgdan='kubectl get deployment --all-namespaces'

# Resource shortcuts with common flags
alias kgpsl='kubectl get pods --show-labels'
alias kgpsr='kubectl get pods --sort-by=.metadata.creationTimestamp'
alias kgpf='kubectl get pods --field-selector=status.phase=Failed'
alias kgpr='kubectl get pods --field-selector=status.phase=Running'

# Debug and troubleshooting
alias kdebug='kubectl run debug --rm -it --image=busybox -- sh'
alias knet='kubectl run netshoot --rm -it --image=nicolaka/netshoot -- bash'

# Events
alias kge='kubectl get events'
alias kges='kubectl get events --sort-by=.metadata.creationTimestamp'

# Common resource combinations
alias kgpd='kubectl get pods,deployment'
alias kgps='kubectl get pods,svc'
alias kgds='kubectl get deployment,svc'

# Namespace-specific gets (add -n namespace)
kgpn() { kubectl get pods -n "$1"; }
kgsn() { kubectl get svc -n "$1"; }
kgdn() { kubectl get deployment -n "$1"; }
kgan() { kubectl get all -n "$1"; }

# Quick pod shell (finds first running pod matching pattern)
kshp() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: kshp pod_pattern [namespace]"
        return 1
    fi
    
    local pattern="$1"
    local namespace_flag=""
    if [[ -n "$2" ]]; then
        namespace_flag="-n $2"
    fi
    
    local pod=$(kubectl get pods $namespace_flag | grep "$pattern" | grep Running | head -1 | awk '{print $1}')
    if [[ -n "$pod" ]]; then
        echo "Connecting to pod: $pod"
        kubectl exec -it $namespace_flag "$pod" -- bash || kubectl exec -it $namespace_flag "$pod" -- sh
    else
        echo "No running pod found matching pattern: $pattern"
    fi
}

# Quick logs (finds first pod matching pattern)
klp() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: klp pod_pattern [namespace]"
        return 1
    fi
    
    local pattern="$1"
    local namespace_flag=""
    if [[ -n "$2" ]]; then
        namespace_flag="-n $2"
    fi
    
    local pod=$(kubectl get pods $namespace_flag | grep "$pattern" | head -1 | awk '{print $1}')
    if [[ -n "$pod" ]]; then
        echo "Showing logs for pod: $pod"
        kubectl logs -f $namespace_flag "$pod"
    else
        echo "No pod found matching pattern: $pattern"
    fi
}

# Get pods by label
kgpl() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: kgpl label_selector"
        echo "Example: kgpl app=nginx"
        return 1
    fi
    kubectl get pods -l "$1"
}

# Get services by label  
kgsl() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: kgsl label_selector"
        return 1
    fi
    kubectl get svc -l "$1"
}

# Quick deployment restart
krestart() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: krestart deployment_name [namespace]"
        return 1
    fi
    
    local deployment="$1"
    local namespace_flag=""
    if [[ -n "$2" ]]; then
        namespace_flag="-n $2"
    fi
    
    kubectl rollout restart deployment $namespace_flag "$deployment"
}

# Pod resource usage
kusage() {
    kubectl top pods --sort-by=cpu
}

# Node resource usage
knusage() {
    kubectl top nodes --sort-by=cpu
}