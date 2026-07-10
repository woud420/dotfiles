# Machine: Debian Linux

## System

- **OS**: Debian GNU/Linux
- **Package manager**: apt
- **Shell**: zsh
- **Terminal**: Kitty

## Primary Use

- Server and development environment
- General development

## Package Installation

```bash
# System packages
sudo apt update && sudo apt install <package>

# Search for packages
apt search <query>

# Remove packages
sudo apt remove <package>
```

## Paths

- Dotfiles: `~/workspace/dotfiles`
- Projects: `~/workspace/`

## Notes

- Uses systemd for service management
- Stable release cycle; backports available for newer packages
- Modern CLI tools: ripgrep, fd-find, bat (binary names may differ from upstream: `fdfind`, `batcat`)
