#!/usr/bin/env bash
# Secrets management functions

# 1Password CLI integration (if available)
if command -v op &> /dev/null; then
    # Load AWS credentials from 1Password
    aws-login() {
        eval $(op item get "AWS" --fields label=access_key_id,secret_access_key --format=json | \
            jq -r '"export AWS_ACCESS_KEY_ID=\(.access_key_id)\nexport AWS_SECRET_ACCESS_KEY=\(.secret_access_key)"')
        echo "AWS credentials loaded from 1Password"
    }
    
    # Load API keys
    load-api-keys() {
        export OPENAI_API_KEY=$(op item get "OpenAI" --fields credential)
        export ANTHROPIC_API_KEY=$(op item get "Anthropic" --fields credential)
        echo "API keys loaded from 1Password"
    }
fi

# macOS Keychain integration
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Store secret in keychain
    keychain-set() {
        local service="$1"
        local account="$2"
        echo -n "Enter secret for $service/$account: "
        read -s secret
        echo
        security add-generic-password -a "$account" -s "$service" -w "$secret"
        echo "Secret stored in keychain"
    }
    
    # Retrieve from keychain
    keychain-get() {
        local service="$1"
        local account="$2"
        security find-generic-password -a "$account" -s "$service" -w
    }
    
    # Load AWS from keychain
    aws-keychain() {
        export AWS_ACCESS_KEY_ID=$(keychain-get "AWS" "access_key_id")
        export AWS_SECRET_ACCESS_KEY=$(keychain-get "AWS" "secret_access_key")
        echo "AWS credentials loaded from keychain"
    }
fi

# Simple encrypted file approach
secrets-edit() {
    local secrets_file="${SECRETS_FILE:-$HOME/.env.secrets.gpg}"
    
    if [[ -f "$secrets_file" ]]; then
        # Decrypt, edit, re-encrypt
        gpg --decrypt "$secrets_file" | ${EDITOR:-vim} - | gpg --encrypt --recipient $(git config user.email) > "$secrets_file.tmp"
        mv "$secrets_file.tmp" "$secrets_file"
    else
        # Create new encrypted file
        ${EDITOR:-vim} - | gpg --encrypt --recipient $(git config user.email) > "$secrets_file"
    fi
}

secrets-load() {
    local secrets_file="${SECRETS_FILE:-$HOME/.env.secrets.gpg}"
    
    if [[ -f "$secrets_file" ]]; then
        eval "$(gpg --decrypt "$secrets_file" 2>/dev/null)"
        echo "Secrets loaded"
    else
        echo "No secrets file found at $secrets_file"
    fi
}

# AWS SSO login helper
aws-sso() {
    local profile="${1:-default}"
    aws sso login --profile "$profile"
    eval $(aws configure export-credentials --profile "$profile" --format env)
    echo "AWS SSO session active for profile: $profile"
}

# Temporary environment variables (expire after session)
temp-env() {
    local var_name="$1"
    echo -n "Enter value for $var_name: "
    read -s var_value
    echo
    export "$var_name"="$var_value"
    echo "$var_name set for this session only"
}

# Check if required secrets are loaded
check-secrets() {
    local required_vars=(
        "AWS_ACCESS_KEY_ID"
        "AWS_SECRET_ACCESS_KEY"
        "OPENAI_API_KEY"
    )
    
    echo "Checking required secrets..."
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo "❌ $var is not set"
        else
            echo "✅ $var is set"
        fi
    done
}

# Create secure directory for secrets
init-secrets() {
    local secrets_dir="$HOME/.secrets"
    
    # Create directory with restricted permissions
    mkdir -p "$secrets_dir"
    chmod 700 "$secrets_dir"
    
    # Create template secrets file
    cat > "$secrets_dir/template.env" << 'EOF'
# AWS Credentials
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION="us-east-1"

# API Keys
export OPENAI_API_KEY=""
export ANTHROPIC_API_KEY=""

# Database
export DATABASE_URL=""

# Add more as needed...
EOF
    
    echo "Secrets directory initialized at $secrets_dir"
    echo "Edit $secrets_dir/template.env and save as .env.secrets"
}

# Helper to generate secure random strings
generate-secret() {
    local length="${1:-32}"
    if command -v openssl &> /dev/null; then
        openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length"
    else
        < /dev/urandom tr -dc A-Za-z0-9 | head -c"$length"
    fi
}