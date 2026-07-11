#!/usr/bin/env bash
# ===== Universal Dotfiles Installer =====
# Works on macOS, Linux (Ubuntu/Debian, Arch, RHEL/CentOS, Alpine)
# Usage: ./install.sh [--minimal] [--no-packages] [--dry-run] [--copy]
#
# Installation Order:
# 1. OS Detection & Environment Setup
# 2. Package Installation (optional)
# 3. Configuration Installation:
#    - Shell configs (foundation)
#    - Git configuration + personal git hooks
#    - Shared SSH defaults (via Include)
#    - Shell functions & sudo-askpass helper
#    - Terminal configs (kitty, htop)
#    - Linux desktop configs (sway/waybar/gtk, arch only)
#    - Vim/Neovim setup (plugins, CoC compilation)
#    - Optional tools (fzf, etc.)
#    - AI context files (CLAUDE.md, AGENTS.md, MACHINE.md)
#
# Features:
# - Auto-detects OS and environment (local/remote/container)
# - Creates backups before changes (path-preserving, with an audit log)
# - Installs regular file copies, not symlinks
# - Compiles CoC.nvim automatically

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
BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)}"
AUDIT_LOG=""
INSTALL_ARGS="$*"
MINIMAL_MODE=false
INSTALL_PACKAGES=true
DRY_RUN=false
CHECK_MODE=false
BACKUP_ONLY=false
DOCTOR_MODE=false
CHECKED_FILES=0
CHECK_FAILURES=0
BACKED_UP_FILES=0
DOCTOR_FAILURES=0
SUDO_CMD=(sudo)
if [[ -n "${SUDO_ASKPASS:-}" && -x "${SUDO_ASKPASS}" ]]; then
    SUDO_CMD=(sudo -A)
fi

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
        --check)
            CHECK_MODE=true
            INSTALL_PACKAGES=false
            shift
            ;;
        --backup-only)
            BACKUP_ONLY=true
            INSTALL_PACKAGES=false
            shift
            ;;
        --doctor)
            DOCTOR_MODE=true
            INSTALL_PACKAGES=false
            shift
            ;;
        --copy)
            # Historical no-op: copied files are now the only install mode.
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "  --minimal       Install minimal config (no fancy tools)"
            echo "  --no-packages   Skip package installation"
            echo "  --dry-run       Show what would be done without doing it"
            echo "  --check         Compare managed live files with the repo"
            echo "  --backup-only   Back up managed live files without installing"
            echo "  --doctor        Check runtime dependencies for this machine"
            echo "  --copy          No-op; files are always copied"
            echo "  -h, --help      Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

mode_count=0
[[ "$CHECK_MODE" == "true" ]] && mode_count=$((mode_count + 1))
[[ "$BACKUP_ONLY" == "true" ]] && mode_count=$((mode_count + 1))
[[ "$DOCTOR_MODE" == "true" ]] && mode_count=$((mode_count + 1))
if [[ "$mode_count" -gt 1 ]]; then
    echo "Choose only one of --check, --backup-only, or --doctor"
    exit 1
fi

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

state_only_mode() {
    [[ "$CHECK_MODE" == "true" || "$BACKUP_ONLY" == "true" ]]
}

init_audit() {
    if [[ "$DRY_RUN" == "true" ]] || [[ "$CHECK_MODE" == "true" ]] || [[ -n "$AUDIT_LOG" ]]; then
        return
    fi

    mkdir -p "$BACKUP_DIR"
    AUDIT_LOG="$BACKUP_DIR/install-audit.tsv"
    {
        printf '# dotfiles install audit\n'
        printf '# started_at\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        printf '# dotfiles_dir\t%s\n' "$DOTFILES_DIR"
        printf '# args\t%s\n' "$INSTALL_ARGS"
        printf 'timestamp\taction\tsource\ttarget\tdetail\n'
    } > "$AUDIT_LOG"
}

audit_action() {
    local action="$1"
    local source="${2:-}"
    local target="${3:-}"
    local detail="${4:-}"

    if [[ "$DRY_RUN" == "true" ]] || [[ "$CHECK_MODE" == "true" ]]; then
        return
    fi

    init_audit
    printf '%s\t%s\t%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$action" "$source" "$target" "$detail" >> "$AUDIT_LOG"
}

backup_path_for() {
    local file="$1"
    local relative

    case "$file" in
        "$HOME"/*)
            relative="${file#"$HOME"/}"
            ;;
        *)
            relative="absolute/${file#/}"
            ;;
    esac

    printf '%s/files/%s' "$BACKUP_DIR" "$relative"
}

# OS Detection
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
    elif [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
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
# shellcheck disable=SC2034
detect_environment() {
    if [[ -f /.dockerenv ]] || [[ -n "$CONTAINER" ]]; then
        ENVIRONMENT="container"
        if [[ -n "${DOTFILES_FULL_INSTALL:-}" ]]; then
            log_info "Container detected, but DOTFILES_FULL_INSTALL is set; keeping full install"
        else
            MINIMAL_MODE=true
            log_info "Container environment detected, enabling minimal mode"
        fi
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

install_arch_aur_packages() {
    local package_list="$DOTFILES_DIR/linux/arch/packages-aur.list"
    [[ -f "$package_list" ]] || return 0

    local helper=""
    local candidate
    for candidate in yay paru; do
        if command -v "$candidate" >/dev/null 2>&1; then
            helper="$candidate"
            break
        fi
    done

    if [[ -z "$helper" ]]; then
        log_warning "No AUR helper found; install packages from $package_list manually"
        return 0
    fi

    if [[ "$DRY_RUN" == "false" ]]; then
        log_step "Installing AUR packages from $package_list with $helper..."
        sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$package_list" \
            | xargs "$helper" -S --needed --noconfirm \
            || log_warning "Some AUR packages failed to install"
    else
        log_info "Would install packages from $package_list with $helper"
    fi
}

install_arch_packages() {
    local package_list="$1"
    local packages=()
    local package

    while IFS= read -r package; do
        [[ -n "$package" ]] || continue
        if pacman -Si "$package" >/dev/null 2>&1; then
            packages+=("$package")
        else
            log_warning "Skipping unavailable Arch package: $package"
        fi
    done < <(sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$package_list")

    if [[ "${#packages[@]}" -gt 0 ]]; then
        "${SUDO_CMD[@]}" pacman -S --needed --noconfirm "${packages[@]}" \
            || log_warning "Some Arch packages failed to install"
    fi
}

install_packages_linux() {
    local package_list=""

    case "$DISTRO" in
        ubuntu|debian)
            package_list="$DOTFILES_DIR/linux/debian/packages.list"
            if [[ "$DRY_RUN" == "false" ]]; then
                log_step "Updating package lists..."
                "${SUDO_CMD[@]}" apt-get update
                log_step "Installing packages from $package_list..."
                grep -v '^#' "$package_list" | grep -v '^$' | xargs "${SUDO_CMD[@]}" apt-get install -y
            else
                log_info "Would run: apt-get update && install packages from $package_list"
            fi
            ;;
        arch|manjaro)
            package_list="$DOTFILES_DIR/linux/arch/packages.list"
            if [[ "$DRY_RUN" == "false" ]]; then
                log_step "Installing packages from $package_list..."
                install_arch_packages "$package_list"
                install_arch_aur_packages
            else
                log_info "Would install packages from $package_list with pacman"
                install_arch_aur_packages
            fi
            ;;
        rhel|centos|fedora)
            package_list="$DOTFILES_DIR/linux/fedora/packages.list"
            if [[ "$DRY_RUN" == "false" ]]; then
                log_step "Installing packages from $package_list..."
                if command -v dnf >/dev/null 2>&1; then
                    grep -v '^#' "$package_list" | grep -v '^$' | xargs "${SUDO_CMD[@]}" dnf install -y
                else
                    grep -v '^#' "$package_list" | grep -v '^$' | xargs "${SUDO_CMD[@]}" yum install -y
                fi
            else
                log_info "Would install packages from $package_list with yum/dnf"
            fi
            ;;
        alpine)
            package_list="$DOTFILES_DIR/linux/alpine/packages.list"
            if [[ "$DRY_RUN" == "false" ]]; then
                log_step "Installing packages from $package_list..."
                grep -v '^#' "$package_list" | grep -v '^$' | xargs "${SUDO_CMD[@]}" apk add --no-cache
            else
                log_info "Would install packages from $package_list with apk"
            fi
            ;;
        *)
            log_warning "Unknown Linux distribution: $DISTRO. Skipping package installation."
            ;;
    esac
}

# Backup existing files (path-preserving: mirrors directory structure under BACKUP_DIR)
backup_file() {
    local file="$1"
    [[ "$CHECK_MODE" == "true" ]] && return 0
    if [[ -f "$file" ]] || [[ -L "$file" ]]; then
        if [[ "$DRY_RUN" == "false" ]]; then
            local backup_path
            backup_path="$(backup_path_for "$file")"
            mkdir -p "$(dirname "$backup_path")"
            if [[ -e "$backup_path" ]] || [[ -L "$backup_path" ]]; then
                audit_action "backup-skip" "$file" "$backup_path" "existing backup retained"
            else
                cp -a "$file" "$backup_path"
                BACKED_UP_FILES=$((BACKED_UP_FILES + 1))
                audit_action "backup" "$file" "$backup_path" "existing target preserved"
                log_info "Backed up $file to $backup_path"
            fi
        else
            log_info "Would backup: $file -> $(backup_path_for "$file")"
        fi
    fi
}

# Replace any symlinked ancestor of a target path that resolves into the
# repo checkout with a real directory. Without this, a legacy symlink like
# ~/.vim -> repo/.vim would make install_file delete the REPO's file and
# then copy the source onto itself.
materialize_target_dir() {
    local dir="$1"
    local ancestor="$dir"
    local chain=()
    while [[ "$ancestor" != "$HOME" && "$ancestor" != "/" && -n "$ancestor" ]]; do
        chain+=("$ancestor")
        ancestor="$(dirname "$ancestor")"
    done
    # Check from the top down so the outermost symlink is replaced first.
    # Compare physical paths: DOTFILES_DIR may itself contain symlinks.
    local i seg resolved repo_real
    repo_real="$(cd "$DOTFILES_DIR" 2>/dev/null && pwd -P || printf '%s' "$DOTFILES_DIR")"
    for (( i=${#chain[@]}-1; i>=0; i-- )); do
        seg="${chain[$i]}"
        if [[ -L "$seg" ]]; then
            resolved="$(cd "$seg" 2>/dev/null && pwd -P || true)"
            case "$resolved" in
                "$repo_real"|"$repo_real"/*)
                    log_warning "Replacing legacy symlink into the repo: $seg -> $resolved"
                    rm -f "$seg"
                    mkdir -p "$seg"
                    audit_action "unlink" "$resolved" "$seg" "replaced repo symlink with real directory"
                    ;;
            esac
        fi
    done
}

# Install a regular copied file
install_file() {
    local source="$1"
    local target="$2"
    local target_dir
    target_dir="$(dirname "$target")"

    if [[ "$CHECK_MODE" == "true" ]]; then
        CHECKED_FILES=$((CHECKED_FILES + 1))
        if [[ -L "$target" ]]; then
            log_error "Symlink where a regular copy is required: $target"
            CHECK_FAILURES=$((CHECK_FAILURES + 1))
        elif [[ ! -f "$target" ]]; then
            log_error "Missing: $target"
            CHECK_FAILURES=$((CHECK_FAILURES + 1))
        elif ! cmp -s "$source" "$target"; then
            log_error "Changed: $target"
            CHECK_FAILURES=$((CHECK_FAILURES + 1))
        elif [[ -x "$source" && ! -x "$target" ]]; then
            log_error "Not executable: $target"
            CHECK_FAILURES=$((CHECK_FAILURES + 1))
        fi
        return 0
    fi

    if [[ "$BACKUP_ONLY" == "true" ]]; then
        backup_file "$target"
        return 0
    fi

    if [[ "$DRY_RUN" == "false" ]]; then
        # Create target directory if it doesn't exist
        materialize_target_dir "$target_dir"
        mkdir -p "$target_dir"
        audit_action "mkdir" "" "$target_dir" "ensure target directory"

        # Remove existing file/link
        if [[ -e "$target" ]] || [[ -L "$target" ]]; then
            backup_file "$target"
            rm -f "$target"
            audit_action "remove" "" "$target" "replace existing target"
        fi

        cp -f "$source" "$target"
        audit_action "copy" "$source" "$target" "regular file copy"
        log_success "Copied $source -> $target"
    else
        log_info "Would copy: $source -> $target"
    fi
}

# Install shell configurations
install_shell_configs() {
    log_step "Installing shell configurations..."

    # Determine which shell config to use
    if [[ "$MINIMAL_MODE" == "true" ]]; then
        backup_file "$HOME/.bashrc"
        install_file "$DOTFILES_DIR/common/shell/.bashrc.server" "$HOME/.bashrc"
    else
        # Install both bash and zsh configs
        backup_file "$HOME/.bashrc"
        backup_file "$HOME/.zshrc"
        backup_file "$HOME/.bash_profile"
        
        install_file "$DOTFILES_DIR/common/shell/.bashrc" "$HOME/.bashrc"
        install_file "$DOTFILES_DIR/common/shell/.zshrc" "$HOME/.zshrc"
        install_file "$DOTFILES_DIR/common/shell/.bash_profile" "$HOME/.bash_profile"
    fi

    # GNU aliases and dircolors
    backup_file "$HOME/.gnu_aliases"
    backup_file "$HOME/.dircolors"
    install_file "$DOTFILES_DIR/common/shell/.gnu_aliases" "$HOME/.gnu_aliases"
    install_file "$DOTFILES_DIR/common/shell/.dircolors" "$HOME/.dircolors"
}

# Install git configuration
install_git_config() {
    log_step "Installing git configuration..."

    backup_file "$HOME/.gitconfig"
    install_file "$DOTFILES_DIR/common/git/.gitconfig" "$HOME/.gitconfig"
    
    # Global gitignore
    install_file "$DOTFILES_DIR/common/git/.gitignore_global" "$HOME/.config/git/ignore"
    install_file "$DOTFILES_DIR/common/git/commit-template.md" "$HOME/.config/git/commit-template.md"
}

# Install personal global Git hooks
install_git_hooks() {
    log_step "Installing personal git hooks..."

    local hooks_src="$DOTFILES_DIR/common/git/hooks"
    local hooks_dest="$HOME/.config/git/hooks"

    if [[ ! -d "$hooks_src" ]]; then
        log_warning "Git hooks source not found: $hooks_src"
        return
    fi

    if state_only_mode; then
        for hook_file in "$hooks_src"/*; do
            if [[ -f "$hook_file" && "$(basename "$hook_file")" != "README.md" ]]; then
                install_file "$hook_file" "$hooks_dest/$(basename "$hook_file")"
            fi
        done
    elif [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$hooks_dest"
        for hook_file in "$hooks_src"/*; do
            if [[ -f "$hook_file" && "$(basename "$hook_file")" != "README.md" ]]; then
                install_file "$hook_file" "$hooks_dest/$(basename "$hook_file")"
                chmod +x "$hooks_dest/$(basename "$hook_file")"
            fi
        done
        # core.hooksPath is set by the installed ~/.gitconfig
        log_success "Installed git hooks to $hooks_dest"
    else
        log_info "Would install hooks from $hooks_src to $hooks_dest"
    fi
}

# Install shared SSH config without clobbering machine-local host entries:
# the shared file lands at ~/.ssh/config.dotfiles and is Include'd from
# ~/.ssh/config, so per-machine hosts keep precedence.
install_ssh_config() {
    local src="$DOTFILES_DIR/common/ssh/config"
    [[ -f "$src" ]] || return 0

    log_step "Installing shared SSH config..."
    if [[ "$CHECK_MODE" == "true" ]]; then
        install_file "$src" "$HOME/.ssh/config.dotfiles"
        if [[ ! -f "$HOME/.ssh/config" ]] || ! grep -q '^[[:space:]]*Include[[:space:]].*config\.dotfiles' "$HOME/.ssh/config"; then
            log_error "Missing Include for ~/.ssh/config.dotfiles in ~/.ssh/config"
            CHECK_FAILURES=$((CHECK_FAILURES + 1))
        fi
    elif [[ "$BACKUP_ONLY" == "true" ]]; then
        backup_file "$HOME/.ssh/config"
        install_file "$src" "$HOME/.ssh/config.dotfiles"
    elif [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        install_file "$src" "$HOME/.ssh/config.dotfiles"
        chmod 600 "$HOME/.ssh/config.dotfiles"
        if [[ ! -f "$HOME/.ssh/config" ]] || ! grep -q 'config\.dotfiles' "$HOME/.ssh/config"; then
            backup_file "$HOME/.ssh/config"
            # Prepend: an Include after a Host block would only apply to that
            # host, and IgnoreUnknown must be parsed before any UseKeychain.
            {
                printf '# Shared dotfiles SSH defaults\nInclude ~/.ssh/config.dotfiles\n\n'
                [[ -f "$HOME/.ssh/config" ]] && cat "$HOME/.ssh/config"
            } > "$HOME/.ssh/config.tmp$$"
            mv "$HOME/.ssh/config.tmp$$" "$HOME/.ssh/config"
            chmod 600 "$HOME/.ssh/config"
            audit_action "prepend" "$src" "$HOME/.ssh/config" "Include directive"
        fi
    else
        log_info "Would copy: common/ssh/config -> ~/.ssh/config.dotfiles (Include'd from ~/.ssh/config)"
    fi
}

# Install shell functions
install_shell_functions() {
    log_step "Installing shell functions..."

    if state_only_mode; then
        for func_file in "$DOTFILES_DIR/common/shell-functions/"*.sh; do
            if [[ -f "$func_file" ]]; then
                install_file "$func_file" "$HOME/.config/shell-functions/$(basename "$func_file")"
            fi
        done
    elif [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$HOME/.config/shell-functions"
        for func_file in "$DOTFILES_DIR/common/shell-functions/"*.sh; do
            if [[ -f "$func_file" ]]; then
                install_file "$func_file" "$HOME/.config/shell-functions/$(basename "$func_file")"
            fi
        done
    else
        for func_file in "$DOTFILES_DIR/common/shell-functions/"*.sh; do
            if [[ -f "$func_file" ]]; then
                log_info "Would copy: $func_file -> ~/.config/shell-functions/$(basename "$func_file")"
            fi
        done
    fi

    # GUI sudo askpass helper at a stable path (sudo.sh points SUDO_ASKPASS here)
    if [[ "$MINIMAL_MODE" == "true" ]]; then
        log_info "Minimal mode: skipping sudo-askpass helper"
    elif state_only_mode; then
        install_file "$DOTFILES_DIR/scripts/sudo-askpass.sh" "$HOME/.local/bin/sudo-askpass"
    elif [[ "$DRY_RUN" == "false" ]]; then
        install_file "$DOTFILES_DIR/scripts/sudo-askpass.sh" "$HOME/.local/bin/sudo-askpass"
        chmod +x "$HOME/.local/bin/sudo-askpass"
    else
        log_info "Would copy: scripts/sudo-askpass.sh -> ~/.local/bin/sudo-askpass"
    fi
}

# Install terminal configuration
install_terminal_config() {
    log_step "Installing terminal configuration..."

    # Kitty config based on OS (using hard copies for kitty to work properly)
    if [[ "$DRY_RUN" == "false" ]] && ! state_only_mode; then
        audit_action "mkdir" "" "$HOME/.config/kitty" "ensure kitty config directory"
    fi
    
    if [[ "$DRY_RUN" == "false" ]] || state_only_mode; then
        if [[ "$OS" == "macos" ]]; then
            install_file "$DOTFILES_DIR/darwin/kitty.conf" "$HOME/.config/kitty/kitty.conf"
        else
            install_file "$DOTFILES_DIR/linux/common/kitty.conf" "$HOME/.config/kitty/kitty.conf"
        fi

        # Copy themes
        for theme_file in "$DOTFILES_DIR/common/themes/"*.conf; do
            if [[ -f "$theme_file" ]]; then
                if [[ ( "$DISTRO" == "arch" || "$DISTRO" == "manjaro" ) \
                    && -f "$DOTFILES_DIR/linux/arch/.config/kitty/$(basename "$theme_file")" ]]; then
                    continue
                fi
                install_file "$theme_file" "$HOME/.config/kitty/$(basename "$theme_file")"
            fi
        done

        # Arch-specific theme overrides (e.g. personal-pink plum background)
        if [[ "$DISTRO" == "arch" || "$DISTRO" == "manjaro" ]]; then
            for theme_file in "$DOTFILES_DIR/linux/arch/.config/kitty/"*.conf; do
                [[ -f "$theme_file" ]] || continue
                install_file "$theme_file" "$HOME/.config/kitty/$(basename "$theme_file")"
            done
        fi
    else
        if [[ "$OS" == "macos" ]]; then
            log_info "Would copy: darwin/kitty.conf -> ~/.config/kitty/kitty.conf"
        else
            log_info "Would copy: linux/common/kitty.conf -> ~/.config/kitty/kitty.conf"
        fi
        log_info "Would copy kitty themes to ~/.config/kitty/"
        if [[ "$DISTRO" == "arch" || "$DISTRO" == "manjaro" ]]; then
            log_info "Would apply Arch kitty overrides from linux/arch/.config/kitty/ to ~/.config/kitty/"
        fi
    fi

    # htop config
    install_file "$DOTFILES_DIR/common/htop/htoprc" "$HOME/.config/htop/htoprc"
}

# Install Linux desktop configurations (sway, waybar, gtk, rofi, mako, ...)
# Copies everything under linux/arch/.config/ into ~/.config/ preserving
# relative paths, so new tool configs are picked up without listing them here.
desktop_config_files() {
    local desktop_root="$DOTFILES_DIR/linux/arch/.config"
    local rel

    if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        while IFS= read -r -d '' rel; do
            printf '%s\0' "$DOTFILES_DIR/$rel"
        done < <(git -C "$DOTFILES_DIR" ls-files -z -- linux/arch/.config)
    else
        find "$desktop_root" -type f \
            ! -path '*/__pycache__/*' \
            ! -name '*.pyc' \
            -print0 \
            | sort -z
    fi
}

install_desktop_configs() {
    if [[ "$DISTRO" != "arch" && "$DISTRO" != "manjaro" ]] || [[ "$MINIMAL_MODE" == "true" ]]; then
        return 0
    fi

    log_step "Installing Arch desktop configurations..."

    local desktop_root="$DOTFILES_DIR/linux/arch/.config"
    local src rel
    while IFS= read -r -d '' src; do
        rel="${src#"$desktop_root"/}"
        # kitty files are applied as theme overlays by install_terminal_config
        [[ "$rel" == kitty/* ]] && continue
        install_file "$src" "$HOME/.config/$rel"
    done < <(desktop_config_files)
}

firefox_default_profile() {
    local firefox_root="$HOME/.mozilla/firefox"
    local profiles_ini="$firefox_root/profiles.ini"
    [[ -f "$profiles_ini" ]] || return 1

    local section=""
    local install_default=""
    local profile_path=""
    local profile_relative="1"
    local profile_default="0"
    local fallback_path=""
    local fallback_relative="1"
    local line=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%$'\r'}"
        if [[ "$line" == \[*\] ]]; then
            if [[ "$section" == Profile* && "$profile_default" == "1" && -n "$profile_path" && -z "$fallback_path" ]]; then
                fallback_path="$profile_path"
                fallback_relative="$profile_relative"
            fi
            section="${line#[}"
            section="${section%]}"
            profile_path=""
            profile_relative="1"
            profile_default="0"
            continue
        fi

        case "$section:$line" in
            Install*:Default=*)
                install_default="${line#*=}"
                ;;
            Profile*:Path=*)
                profile_path="${line#*=}"
                ;;
            Profile*:IsRelative=*)
                profile_relative="${line#*=}"
                ;;
            Profile*:Default=*)
                profile_default="${line#*=}"
                ;;
        esac
    done < "$profiles_ini"

    if [[ "$section" == Profile* && "$profile_default" == "1" && -n "$profile_path" && -z "$fallback_path" ]]; then
        fallback_path="$profile_path"
        fallback_relative="$profile_relative"
    fi

    local selected=""
    local relative="1"
    if [[ -n "$install_default" ]]; then
        selected="$install_default"
    elif [[ -n "$fallback_path" ]]; then
        selected="$fallback_path"
        relative="$fallback_relative"
    else
        return 1
    fi

    local resolved="$selected"
    if [[ "$relative" != "0" && "$selected" != /* ]]; then
        resolved="$firefox_root/$selected"
    fi

    if [[ ! -d "$resolved" && -n "$fallback_path" && "$selected" != "$fallback_path" ]]; then
        selected="$fallback_path"
        resolved="$selected"
        if [[ "$fallback_relative" != "0" && "$selected" != /* ]]; then
            resolved="$firefox_root/$selected"
        fi
    fi

    [[ -d "$resolved" ]] || return 1
    printf '%s\n' "$resolved"
}

install_firefox_config() {
    if [[ "$DISTRO" != "arch" && "$DISTRO" != "manjaro" ]] || [[ "$MINIMAL_MODE" == "true" ]]; then
        return 0
    fi

    local profile=""
    if ! profile="$(firefox_default_profile)"; then
        if [[ "$CHECK_MODE" == "true" ]]; then
            log_error "Firefox profile not found; launch Firefox once, then rerun the installer"
            CHECK_FAILURES=$((CHECK_FAILURES + 1))
        else
            log_warning "Firefox profile not found; launch Firefox once, then rerun the installer"
        fi
        return 0
    fi

    log_step "Installing Firefox profile theme..."
    local firefox_src="$DOTFILES_DIR/linux/arch/firefox"
    install_file "$firefox_src/user.js" "$profile/user.js"
    install_file "$firefox_src/chrome/userChrome.css" "$profile/chrome/userChrome.css"
    install_file "$firefox_src/chrome/userContent.css" "$profile/chrome/userContent.css"
}

# Compile CoC.nvim after plugin installation (shared by vim + nvim paths)
compile_coc_nvim() {
    if [[ ! -d "$HOME/.vim/plugged/coc.nvim" ]]; then
        if grep -q "coc.nvim" "$HOME/.vim/plugins.vim" 2>/dev/null; then
            log_warning "coc.nvim requested by plugins.vim but not installed; run :PlugInstall manually"
        fi
        return 0
    fi

    if [[ ! -f "$HOME/.vim/plugged/coc.nvim/package.json" ]]; then
        log_warning "coc.nvim present but incomplete (no package.json); rerun :PlugInstall"
        return 0
    fi

    log_step "Compiling CoC.nvim..."
    if ! command -v npm >/dev/null 2>&1; then
        log_warning "npm not found. CoC.nvim needs manual compilation: cd ~/.vim/plugged/coc.nvim && npm install"
        return 0
    fi

    # The subshell is the if-condition so a build failure cannot trip set -e
    if (
        cd "$HOME/.vim/plugged/coc.nvim" || exit 0

        if [[ -f package-lock.json || -f npm-shrinkwrap.json ]]; then
            npm ci
        else
            npm install
        fi
    ); then
        log_success "CoC.nvim compiled successfully"
    else
        log_warning "CoC.nvim compilation failed. Retry manually: cd ~/.vim/plugged/coc.nvim && npm install"
    fi
}

# Install vim + nvim configuration
install_vim_config() {
    log_step "Installing vim configuration..."

    if [[ "$DRY_RUN" == "false" ]] && ! state_only_mode; then
        mkdir -p "$HOME/.vim/settings"
    fi

    # install_file handles dry-run logging itself
    install_file "$DOTFILES_DIR/.vim/vimrc" "$HOME/.vim/vimrc"
    install_file "$DOTFILES_DIR/.vim/plugins.vim" "$HOME/.vim/plugins.vim"
    install_file "$DOTFILES_DIR/.vim/mappings.vim" "$HOME/.vim/mappings.vim"
    install_file "$DOTFILES_DIR/.vim/settings.vim" "$HOME/.vim/settings.vim"
    install_file "$DOTFILES_DIR/.vim/coc-settings.json" "$HOME/.vim/coc-settings.json"

    for settings_file in "$DOTFILES_DIR/.vim/settings/"*.vim; do
        if [[ -f "$settings_file" ]]; then
            install_file "$settings_file" "$HOME/.vim/settings/$(basename "$settings_file")"
        fi
    done

    if state_only_mode; then
        return 0
    fi

    if [[ "$MINIMAL_MODE" == "true" ]]; then
        log_info "Minimal mode: skipping vim plugin installation"
        return 0
    fi

    # Install vim plugins. When nvim is present the neovim step handles this
    # (same ~/.vim/plugged); headless plain vim needs a pty to run vim-plug.
    if command -v nvim >/dev/null 2>&1; then
        log_info "nvim present; plugins are installed by the neovim step"
    elif command -v vim >/dev/null 2>&1; then
        log_step "Installing vim plugins..."
        if [[ "$DRY_RUN" == "false" ]]; then
            seed_vim_plug
            # vim-plug needs a real terminal: ex mode (-e/-es) aborts with E31
            # and installs nothing, so allocate a pty via script(1).
            if command -v script >/dev/null 2>&1; then
                run_vim_in_pty vim -N -u "$HOME/.vim/vimrc" -c 'PlugInstall --sync' -c 'qa!' \
                    || log_warning "vim plugin install failed; run :PlugInstall manually"
            else
                vim -e -N -u "$HOME/.vim/vimrc" --not-a-term -c 'PlugInstall --sync' -c 'qa!' </dev/null \
                    || log_warning "vim plugin install failed; run :PlugInstall manually"
            fi
            report_plug_count
            compile_coc_nvim
        else
            log_info "Would install vim plugins and compile CoC.nvim"
        fi
    fi
}

# Download vim-plug atomically; a partial file would otherwise block both this
# pre-seed and the vimrc's own bootstrap forever.
seed_vim_plug() {
    if [[ ! -s "$HOME/.vim/autoload/plug.vim" ]]; then
        rm -f "$HOME/.vim/autoload/plug.vim"
        mkdir -p "$HOME/.vim/autoload"
        local tmp="$HOME/.vim/autoload/.plug.vim.tmp$$"
        if curl -fsLo "$tmp" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
            mv "$tmp" "$HOME/.vim/autoload/plug.vim"
        else
            rm -f "$tmp"
            log_warning "could not download vim-plug"
        fi
    fi
}

# Run an editor under a pty. BSD/macOS script(1) takes the command as args;
# util-linux script(1) needs -c with a single string.
run_vim_in_pty() {
    if script --version >/dev/null 2>&1; then
        local cmd
        printf -v cmd '%q ' "$@"
        script -qec "$cmd" /dev/null </dev/null >/dev/null 2>&1
    else
        script -q /dev/null "$@" </dev/null >/dev/null 2>&1
    fi
}

# Compare installed plugin dirs against what plugins.vim declares.
report_plug_count() {
    local expected installed
    expected="$(grep -c "^Plug '" "$HOME/.vim/plugins.vim" 2>/dev/null || echo 0)"
    # shellcheck disable=SC2012
    installed="$(ls -1 "$HOME/.vim/plugged" 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "$installed" -ge "$expected" && "$expected" -gt 0 ]]; then
        log_success "vim plugins installed ($installed/$expected)"
    else
        log_warning "only $installed of $expected vim plugins installed; run :PlugInstall manually"
    fi
}

# Install neovim configuration
install_neovim_config() {
    log_step "Installing neovim configuration..."

    if state_only_mode; then
        install_file "$DOTFILES_DIR/common/nvim/init.vim" "$HOME/.config/nvim/init.vim"
        install_file "$DOTFILES_DIR/.vim/coc-settings.json" "$HOME/.config/nvim/coc-settings.json"
        return 0
    elif [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$HOME/.config/nvim"

        backup_file "$HOME/.config/nvim/init.vim"
        backup_file "$HOME/.config/nvim/coc-settings.json"

        install_file "$DOTFILES_DIR/common/nvim/init.vim" "$HOME/.config/nvim/init.vim"
        install_file "$DOTFILES_DIR/.vim/coc-settings.json" "$HOME/.config/nvim/coc-settings.json"
    else
        log_info "Would copy: common/nvim/init.vim -> ~/.config/nvim/init.vim"
        log_info "Would copy: .vim/coc-settings.json -> ~/.config/nvim/coc-settings.json"
        if [[ "$MINIMAL_MODE" == "false" ]]; then
            log_info "Would install neovim plugins and compile CoC.nvim"
        fi
        return
    fi

    if [[ "$MINIMAL_MODE" == "true" ]]; then
        log_info "Minimal mode: skipping neovim plugin installation"
        return 0
    fi

    if command -v nvim >/dev/null 2>&1; then
        log_step "Installing neovim plugins..."
        seed_vim_plug
        nvim --headless +PlugInstall +qall </dev/null || log_warning "nvim plugin install failed; run :PlugInstall manually"
        report_plug_count

        compile_coc_nvim
    else
        log_warning "nvim not found. Skipping neovim plugin installation."
    fi
}

# Install optional tools
install_optional_tools() {
    if state_only_mode; then
        return 0
    fi

    if [[ "$MINIMAL_MODE" == "true" ]]; then
        log_info "Minimal mode: Skipping optional tools"
        return
    fi

    log_step "Installing optional tools..."

    # FZF
    if ! command -v fzf >/dev/null 2>&1 && [[ ! -d "$HOME/.fzf" ]]; then
        log_info "Installing fzf..."
        if [[ "$DRY_RUN" == "false" ]]; then
            if git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; then
                ~/.fzf/install --bin --no-update-rc --no-key-bindings --no-completion || log_warning "fzf install script failed"
            else
                log_warning "fzf clone failed; skipping"
            fi
        else
            log_info "Would install fzf"
        fi
    fi
}

# Install AI context files (CLAUDE.md, MACHINE.md, AGENTS.md)
install_ai_context() {
    if [[ "$MINIMAL_MODE" == "true" ]]; then
        log_info "Minimal mode: skipping AI context files"
        return 0
    fi

    log_step "Installing AI context files..."

    # ~/.claude/CLAUDE.md is often user-curated (e.g. custom includes);
    # only seed it when absent instead of clobbering it on every install.
    local claude_src="$DOTFILES_DIR/common/ai-context/CLAUDE.md"
    if [[ -f "$claude_src" ]]; then
        if [[ "$BACKUP_ONLY" == "true" ]]; then
            backup_file "$HOME/.claude/CLAUDE.md"
        elif [[ -f "$HOME/.claude/CLAUDE.md" ]] && ! cmp -s "$claude_src" "$HOME/.claude/CLAUDE.md"; then
            log_info "Keeping existing ~/.claude/CLAUDE.md (differs from repo version; merge manually if wanted)"
        else
            install_file "$claude_src" "$HOME/.claude/CLAUDE.md"
        fi
    fi

    # AGENTS.md -> ~/AGENTS.md (for Codex/Copilot compatibility)
    local agents_src="$DOTFILES_DIR/common/ai-context/AGENTS.md"
    if [[ -f "$agents_src" ]]; then
        install_file "$agents_src" "$HOME/AGENTS.md"
    fi

    # OS-specific machine.md -> ~/MACHINE.md
    local machine_src=""
    case "$DISTRO" in
        arch|manjaro)
            machine_src="$DOTFILES_DIR/linux/arch/ai-context/machine.md"
            ;;
        ubuntu|debian)
            machine_src="$DOTFILES_DIR/linux/debian/ai-context/machine.md"
            ;;
        rhel|centos|fedora)
            machine_src="$DOTFILES_DIR/linux/fedora/ai-context/machine.md"
            ;;
        alpine)
            machine_src="$DOTFILES_DIR/linux/alpine/ai-context/machine.md"
            ;;
        darwin|macos)
            machine_src="$DOTFILES_DIR/darwin/ai-context/machine.md"
            ;;
    esac

    if [[ -n "$machine_src" && -f "$machine_src" ]]; then
        install_file "$machine_src" "$HOME/MACHINE.md"
    fi

    # Machine state snapshots are generated on demand, not at install time:
    # DOTFILES_DIR=$DOTFILES_DIR scripts/refresh-machine-state.sh
}

backup_local_overrides() {
    [[ "$BACKUP_ONLY" == "true" ]] || return 0

    local file
    for file in \
        "$HOME/.bashrc.local" \
        "$HOME/.zshrc.local" \
        "$HOME/.gitconfig.local" \
        "$HOME/.ssh/config"; do
        backup_file "$file"
    done
}

doctor_require_command() {
    local command="$1"
    if command -v "$command" >/dev/null 2>&1; then
        log_success "$command"
    else
        log_error "Missing command: $command"
        DOCTOR_FAILURES=$((DOCTOR_FAILURES + 1))
    fi
}

doctor_require_path() {
    local path="$1"
    local description="$2"
    if [[ -e "$path" ]]; then
        log_success "$description"
    else
        log_error "Missing $description: $path"
        DOCTOR_FAILURES=$((DOCTOR_FAILURES + 1))
    fi
}

doctor_optional_command() {
    local command="$1"
    if command -v "$command" >/dev/null 2>&1; then
        log_success "$command (optional)"
    else
        log_warning "Optional command not found: $command"
    fi
}

run_doctor() {
    log_step "Checking runtime dependencies..."

    local command
    local common_commands=(bash git zsh kitty nvim rg fzf)
    for command in "${common_commands[@]}"; do
        doctor_require_command "$command"
    done

    if [[ "$DISTRO" == "arch" || "$DISTRO" == "manjaro" ]]; then
        local desktop_commands=(
            sway waybar rofi mako grim slurp wl-copy cliphist playerctl
            thunar ranger pavucontrol notify-send nmcli pactl firefox
            spotify slack steam
        )
        for command in "${desktop_commands[@]}"; do
            doctor_require_command "$command"
        done

        doctor_require_path "/usr/lib/xdg-desktop-portal" "desktop portal"
        doctor_require_path "/usr/lib/xdg-desktop-portal-gtk" "GTK portal backend"
        doctor_require_path "/usr/lib/xdg-desktop-portal-wlr" "wlroots portal backend"
        doctor_require_path "/usr/share/themes/Nordic-darker" "Nordic-darker GTK theme"

        if command -v fc-list >/dev/null 2>&1 && fc-list -q "FiraCode Nerd Font"; then
            log_success "FiraCode Nerd Font"
        else
            log_error "Missing FiraCode Nerd Font"
            DOCTOR_FAILURES=$((DOCTOR_FAILURES + 1))
        fi

        if command -v sway >/dev/null 2>&1 && sway --version 2>/dev/null | grep -qi swayfx; then
            log_success "SwayFX runtime"
        else
            log_error "SwayFX is required by the committed Sway effects"
            DOCTOR_FAILURES=$((DOCTOR_FAILURES + 1))
        fi

        doctor_optional_command docker
        doctor_optional_command kubectl
        if [[ ! -f "$HOME/.config/waybar/modules/mailsecrets.py" ]]; then
            log_warning "Waybar mail counter is disabled until mailsecrets.py exists"
        fi
    fi

    if [[ "$DOCTOR_FAILURES" -gt 0 ]]; then
        log_error "Doctor found $DOCTOR_FAILURES missing required component(s)"
        return 1
    fi

    log_success "Runtime dependencies are present"
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

    if [[ "$DOCTOR_MODE" == "true" ]]; then
        run_doctor
        return
    fi

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

    # Install configurations in dependency order
    install_shell_configs      # 1. Shell configs (.bashrc, .zshrc) - foundation
    install_git_config         # 2. Git configuration (.gitconfig)
    install_git_hooks           # 2b. Personal global Git hooks
    install_ssh_config          # 2c. Shared SSH defaults (via Include)
    install_shell_functions     # 3. Shell functions (depends on shell configs)
    install_terminal_config     # 4. Terminal configs (kitty, htop)
    install_desktop_configs     # 5. Linux desktop configs (sway/waybar/gtk) - arch only
    install_firefox_config      # 6. Firefox profile chrome/content theme - arch only
    install_vim_config          # 7. Vim setup (plugins, settings, CoC compilation)
    install_neovim_config       # 8. Neovim bridge to Vim config
    install_optional_tools      # 9. Optional tools (fzf, etc.) - last
    install_ai_context          # 10. AI context files (CLAUDE.md, AGENTS.md, MACHINE.md)
    backup_local_overrides

    if [[ "$CHECK_MODE" == "true" ]]; then
        if [[ "$CHECK_FAILURES" -gt 0 ]]; then
            log_error "$CHECK_FAILURES of $CHECKED_FILES managed files or requirements differ"
            return 1
        fi
        log_success "All $CHECKED_FILES managed files match the repo"
        return 0
    fi

    if [[ "$BACKUP_ONLY" == "true" ]]; then
        log_success "Backed up $BACKED_UP_FILES live files to $BACKUP_DIR"
        [[ -n "$AUDIT_LOG" ]] && log_info "Audit log: $AUDIT_LOG"
        return 0
    fi
    
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   Installation Complete!                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    if [[ -d "$BACKUP_DIR" ]]; then
        log_info "Backups saved to: $BACKUP_DIR"
        if [[ -n "$AUDIT_LOG" ]]; then
            log_info "Audit log: $AUDIT_LOG"
        fi
    fi

    log_info "Please run: source ~/.bashrc  (or source ~/.zshrc)"

    if [[ "$MINIMAL_MODE" == "false" ]]; then
        echo
        log_info "Try these new commands:"
        echo "  git ch          # Fuzzy branch checkout"
        echo "  git fadd        # Interactive file staging"
        echo "  git flog        # Browse commits"
        echo "  kctx            # Switch kubectl context with fzf"
    fi
}

# Run main function
main "$@"
