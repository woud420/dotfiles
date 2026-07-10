# Machine: Alpine Linux

## System

- **OS**: Alpine Linux
- **Package manager**: apk
- **Shell**: zsh
- **Terminal**: Kitty

## Primary Use

- Lightweight container and development environment
- General development

## Package Installation

```bash
# System packages
sudo apk add <package>

# Search for packages
apk search <query>

# Remove packages
sudo apk del <package>

# Update package index
sudo apk update
```

## Paths

- Dotfiles: `~/workspace/dotfiles`
- Projects: `~/workspace/`

## Notes

- Uses musl libc instead of glibc (some binaries may need static builds or compatibility layers)
- Uses OpenRC for service management (not systemd)
- Minimal base system; BusyBox provides core utilities by default
- Modern CLI tools: ripgrep, fd, bat
