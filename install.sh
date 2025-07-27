#!/usr/bin/env bash
# Universal dotfiles installer with OS detection
# Works on macOS, Linux (Ubuntu/Debian, Arch, RHEL/CentOS, Alpine)
# Usage: ./install.sh [--minimal] [--no-packages] [--dry-run]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
MINIMAL_MODE=false
INSTALL_PACKAGES=true
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --minimal)
            MINIMAL_MODE=true
            shift
            ;;
        --no-packages)
            INSTALL_PACKAGES=false
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "  --minimal       Install minimal config (no fancy tools)"
            echo "  --no-packages   Skip package installation"
            echo "  --dry-run       Show what would be done without doing it"
            echo "  -h, --help      Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# OS Detection
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
    elif [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS="linux"
        DISTRO="${ID,,}" # Convert to lowercase
    elif [[ -f /etc/redhat-release ]]; then
        OS="linux"
        DISTRO="rhel"
    elif [[ -f /etc/alpine-release ]]; then
        OS="linux"
        DISTRO="alpine"
    else
        OS="unknown"
        DISTRO="unknown"
    fi
    
    log_info "Detected OS: $OS, Distribution: $DISTRO"
}

# Container/Environment Detection
detect_environment() {
    if [[ -f /.dockerenv ]] || [[ -n "$CONTAINER" ]]; then
        ENVIRONMENT="container"
        MINIMAL_MODE=true
        log_info "Container environment detected, enabling minimal mode"
    elif [[ -n "$SSH_CONNECTION" ]] || [[ -n "$SSH_CLIENT" ]]; then
        ENVIRONMENT="remote"
        log_info "Remote SSH session detected"
    else
        ENVIRONMENT="local"
        log_info "Local environment detected"
    fi
}

# Package installation functions
install_packages_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        log_step "Installing Homebrew..."
        if [[ "$DRY_RUN" == "false" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            log_info "Would install Homebrew"
        fi
    fi
    
    log_step "Installing packages from Brewfile..."
    if [[ "$DRY_RUN" == "false" ]]; then
        brew bundle --file="$DOTFILES_DIR/darwin/Brewfile" || log_warning "Some packages failed to install"
    else
        log_info "Would run: brew bundle --file=$DOTFILES_DIR/darwin/Brewfile"
    fi
}

install_packages_linux() {
    local package_list=""
    
    case "$DISTRO" in
        ubuntu|debian)
            package_list="$DOTFILES_DIR/linux/debian/packages.list"
            if [[ "$DRY_RUN" == "false" ]]; then
                log_step "Updating package lists..."
                sudo apt-get update
                log_step "Installing packages from $package_list..."
                grep -v '^#' "$package_list" | grep -v '^$' | xargs sudo apt-get install -y
            else
                log_info "Would run: apt-get update && install packages from $package_list"
            fi
            ;;
        arch|manjaro)
            package_list="$DOTFILES_DIR/linux/arch/packages.list"
            if [[ "$DRY_RUN" == "false" ]]; then
                log_step "Installing packages from $package_list..."
                # Filter comments and empty lines, then install
                grep -v '^#' "$package_list" | grep -v '^$' | xargs sudo pacman -S --noconfirm
            else
                log_info "Would install packages from $package_list with pacman"
            fi
            ;;
        rhel|centos|fedora)
            package_list="$DOTFILES_DIR/linux/fedora/packages.list"
            if [[ "$DRY_RUN" == "false" ]]; then
                log_step "Installing packages from $package_list..."
                if command -v dnf >/dev/null 2>&1; then
                    grep -v '^#' "$package_list" | grep -v '^$' | xargs sudo dnf install -y
                else
                    grep -v '^#' "$package_list" | grep -v '^$' | xargs sudo yum install -y
                fi
            else
                log_info "Would install packages from $package_list with yum/dnf"
            fi
            ;;
        alpine)
            package_list="$DOTFILES_DIR/linux/alpine/packages.list"
            if [[ "$DRY_RUN" == "false" ]]; then
                log_step "Installing packages from $package_list..."
                grep -v '^#' "$package_list" | grep -v '^$' | xargs sudo apk add --no-cache
            else
                log_info "Would install packages from $package_list with apk"
            fi
            ;;
        *)
            log_warning "Unknown Linux distribution: $DISTRO. Skipping package installation."
            ;;
    esac
}

# Backup existing files
backup_file() {
    local file="$1"
    if [[ -f "$file" ]] || [[ -L "$file" ]]; then
        if [[ "$DRY_RUN" == "false" ]]; then
            mkdir -p "$BACKUP_DIR"
            cp -L "$file" "$BACKUP_DIR/$(basename "$file")" 2>/dev/null || true
            log_info "Backed up $file to $BACKUP_DIR"
        else
            log_info "Would backup: $file"
        fi
    fi
}

# Create symlinks
create_symlink() {
    local source="$1"
    local target="$2"
    local target_dir="$(dirname "$target")"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        # Create target directory if it doesn't exist
        mkdir -p "$target_dir"
        
        # Remove existing file/link
        [[ -e "$target" ]] || [[ -L "$target" ]] && rm -f "$target"
        
        # Create symlink
        ln -sf "$source" "$target"
        log_success "Linked $source -> $target"
    else
        log_info "Would link: $source -> $target"
    fi
}

# Install shell configurations
install_shell_configs() {
    log_step "Installing shell configurations..."
    
    # Determine which shell config to use
    if [[ "$MINIMAL_MODE" == "true" ]]; then
        backup_file "$HOME/.bashrc"
        create_symlink "$DOTFILES_DIR/common/shell/.bashrc.server" "$HOME/.bashrc"
    else
        # Install both bash and zsh configs
        backup_file "$HOME/.bashrc"
        backup_file "$HOME/.zshrc"
        backup_file "$HOME/.bash_profile"
        
        create_symlink "$DOTFILES_DIR/common/shell/.bashrc" "$HOME/.bashrc"
        create_symlink "$DOTFILES_DIR/common/shell/.zshrc" "$HOME/.zshrc"
        create_symlink "$DOTFILES_DIR/common/shell/.bash_profile" "$HOME/.bash_profile"
    fi
    
    # GNU aliases and dircolors
    backup_file "$HOME/.gnu_aliases"
    backup_file "$HOME/.dircolors"
    create_symlink "$DOTFILES_DIR/common/shell/.gnu_aliases" "$HOME/.gnu_aliases"
    create_symlink "$DOTFILES_DIR/common/shell/.dircolors" "$HOME/.dircolors"
}

# Install git configuration
install_git_config() {
    log_step "Installing git configuration..."
    
    backup_file "$HOME/.gitconfig"
    create_symlink "$DOTFILES_DIR/common/git/.gitconfig" "$HOME/.gitconfig"
    
    # Global gitignore
    mkdir -p "$HOME/.config/git"
    create_symlink "$DOTFILES_DIR/common/git/.gitignore_global" "$HOME/.config/git/ignore"
}

# Install shell functions
install_shell_functions() {
    log_step "Installing shell functions..."
    
    if [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$HOME/.config/shell-functions"
        # Copy all shell function files
        for func_file in "$DOTFILES_DIR/common/shell-functions/"*.sh; do
            if [[ -f "$func_file" ]]; then
                create_symlink "$func_file" "$HOME/.config/shell-functions/$(basename "$func_file")"
            fi
        done
    else
        log_info "Would install shell functions to ~/.config/shell-functions/"
    fi
}

# Install terminal configuration
install_terminal_config() {
    log_step "Installing terminal configuration..."
    
    # Kitty config based on OS
    mkdir -p "$HOME/.config/kitty"
    
    if [[ "$OS" == "macos" ]]; then
        create_symlink "$DOTFILES_DIR/darwin/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    else
        create_symlink "$DOTFILES_DIR/linux/common/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    fi
    
    # Themes
    if [[ "$DRY_RUN" == "false" ]]; then
        for theme_file in "$DOTFILES_DIR/common/themes/"*.conf; do
            if [[ -f "$theme_file" ]]; then
                create_symlink "$theme_file" "$HOME/.config/kitty/$(basename "$theme_file")"
            fi
        done
    else
        log_info "Would install kitty themes"
    fi
    
    # htop config
    mkdir -p "$HOME/.config/htop"
    create_symlink "$DOTFILES_DIR/common/htop/htoprc" "$HOME/.config/htop/htoprc"
}

# Install optional tools
install_optional_tools() {
    if [[ "$MINIMAL_MODE" == "true" ]]; then
        log_info "Minimal mode: Skipping optional tools"
        return
    fi
    
    log_step "Installing optional tools..."
    
    # FZF
    if ! command -v fzf >/dev/null 2>&1; then
        log_info "Installing fzf..."
        if [[ "$DRY_RUN" == "false" ]]; then
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --bin --no-update-rc --no-key-bindings --no-completion
        else
            log_info "Would install fzf"
        fi
    fi
}

# Main installation function
main() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Dotfiles Installer                       ║"
    echo "║              Universal Unix/Linux/macOS                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    detect_os
    detect_environment
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi
    
    # Install packages if requested
    if [[ "$INSTALL_PACKAGES" == "true" ]] && [[ "$MINIMAL_MODE" == "false" ]]; then
        case "$OS" in
            macos)
                install_packages_macos
                ;;
            linux)
                install_packages_linux
                ;;
            *)
                log_warning "Unknown OS: $OS. Skipping package installation."
                ;;
        esac
    else
        log_info "Skipping package installation"
    fi
    
    # Install configurations
    install_shell_configs
    install_git_config
    install_shell_functions
    install_terminal_config
    install_optional_tools
    
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   Installation Complete!                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    if [[ -d "$BACKUP_DIR" ]]; then
        log_info "Backups saved to: $BACKUP_DIR"
    fi
    
    log_info "Please run: source ~/.bashrc  (or source ~/.zshrc)"
    
    if [[ "$MINIMAL_MODE" == "false" ]]; then
        echo
        log_info "Try these new commands:"
        echo "  git ch          # Fuzzy branch checkout"
        echo "  git fadd        # Interactive file staging"
        echo "  git flog        # Browse commits"
        echo "  k get p         # kubectl get pods"
        echo "  sshdot user@host # SSH with dotfiles"
    fi
}

# Run main function
main "$@"