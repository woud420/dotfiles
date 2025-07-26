# Dotfiles

My personal dotfiles organized by operating system for easy deployment.

## Structure

```
.
├── common/          # Universal configs that work on all platforms
│   ├── bash/        # Bash configurations for servers
│   ├── shell/       # Shell configs (.zshrc, .gnu_aliases, .dircolors)
│   ├── git/         # Git configuration and global gitignore
│   ├── themes/      # Color themes (Catppuccin)
│   ├── htop/        # htop configuration
│   └── shell-functions/  # Shell function scripts
│
├── darwin/          # macOS-specific configurations
│   ├── Brewfile     # Homebrew packages and casks
│   └── kitty.conf   # Kitty terminal with macOS keybindings
│
└── linux/           # Linux-specific configurations
    ├── common/      # Configs for all Linux distros
    ├── debian/      # Debian/Ubuntu specific
    ├── arch/        # Arch Linux specific
    └── fedora/      # Fedora/RHEL specific
```

## Installation

### Quick Start

```bash
# Clone the repository
git clone https://github.com/woud420/dotfiles.git ~/workspace/projects/dotfiles
cd ~/workspace/projects/dotfiles

# Install for your OS
make install
```

### macOS

```bash
# Install Homebrew packages and set up configs
make darwin
```

### Linux

```bash
# For Debian/Ubuntu
make linux

# The Makefile will detect your distro and use appropriate package manager
```

## Manual Installation

### Common files (all platforms)
```bash
make stow-common
```

### macOS specific
```bash
make stow-darwin
```

### Linux specific
```bash
make stow-linux
```

## Managing Packages

### macOS (Homebrew)
```bash
# Update Brewfile with currently installed packages
make brew-sync

# Install packages from Brewfile
make brew
```

### Linux
Package lists are maintained in `linux/<distro>/packages.list`

## Python Environment

Create a project-specific virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Key Features

- **OS-specific organization**: Configs are separated by platform
- **Common configs**: Shared configurations work everywhere
- **Theme consistency**: Catppuccin color scheme across all tools
- **Shell flexibility**: Both zsh (primary) and bash (for servers) configs
- **GNU tools**: Consistent command behavior across macOS and Linux