#!/bin/bash
# Minimal kubectl aliases

# Check if kubectl is available
if ! command -v kubectl >/dev/null 2>&1; then
    return 0
fi

# Core kubectl alias
alias k='kubectl'