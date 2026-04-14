# Machine: Fedora Linux

## System

- **OS**: Fedora Linux
- **Package manager**: dnf
- **Shell**: zsh
- **Terminal**: Kitty

## Primary Use

- Development environment
- General development

## Package Installation

```bash
# System packages
sudo dnf install <package>

# Search for packages
dnf search <query>

# Remove packages
sudo dnf remove <package>

# Enable COPR repos (community packages)
sudo dnf copr enable <owner>/<repo>
```

## Paths

- Dotfiles: `~/workspace/dotfiles`
- Projects: `~/workspace/`

## Notes

- Uses systemd for service management
- SELinux enabled by default
- Rapid release cycle with recent upstream packages
- Modern CLI tools: ripgrep, fd-find, bat
