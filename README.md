# Dotfiles

Personal dotfiles for macOS and Linux with modular shell functions, git workflows, and kubectl shortcuts.

## 🚀 Quick Install

```bash
# Clone and install
git clone https://github.com/yourusername/dotfiles.git ~/workspace/projects/dotfiles
cd ~/workspace/projects/dotfiles
./install.sh

# Or use make
make install
```

### Installation Options

```bash
./install.sh --minimal      # Minimal config for servers/containers
./install.sh --no-packages  # Skip package installation
./install.sh --dry-run      # Preview what will be installed

# Make targets
make install              # Full installation
make install-minimal      # Minimal config
make install-no-packages  # Config files only
make install-dry-run      # Preview changes
```

### Remote Installation

```bash
# One-liner for remote servers
curl -fsSL https://raw.githubusercontent.com/yourusername/dotfiles/main/install.sh | bash -s -- --minimal

# SSH with dotfiles
ssh user@host 'bash -s' < install.sh --minimal
```

## 📁 Directory Structure

```
dotfiles/
├── common/                  # Cross-platform configurations
│   ├── shell/              # Shell configs (.bashrc, .zshrc)
│   ├── git/                # Git configuration
│   ├── shell-functions/    # Modular functions & aliases
│   └── themes/             # Color themes (Catppuccin)
├── darwin/                 # macOS specific
│   ├── Brewfile           # Homebrew packages
│   └── kitty.conf         # macOS kitty config
├── linux/                  # Linux specific
│   ├── debian/            # Ubuntu/Debian packages
│   ├── arch/              # Arch Linux packages
│   ├── fedora/            # Fedora/RHEL packages
│   └── alpine/            # Alpine Linux packages
└── install.sh             # Universal installer
```

## 🔧 What Gets Installed

### Configuration Files

| File | Installed Location | Description |
|------|-------------------|-------------|
| `.bashrc` | `~/.bashrc` | Bash configuration with prompt, colors, functions |
| `.zshrc` | `~/.zshrc` | Zsh configuration with Catppuccin theme |
| `.bash_profile` | `~/.bash_profile` | Bash profile (sources .bashrc) |
| `.bashrc.server` | `~/.bashrc` | Conservative bash config for servers (minimal mode) |
| `.gitconfig` | `~/.gitconfig` | Git aliases and fuzzy commands |
| `commit-template.md` | `~/.config/git/commit-template.md` | Default structured git commit template |
| `.gitignore_global` | `~/.config/git/ignore` | Global git ignores |
| `.gnu_aliases` | `~/.gnu_aliases` | GNU coreutils aliases for macOS |
| `.dircolors` | `~/.dircolors` | Directory colors |
| `kitty.conf` | `~/.config/kitty/kitty.conf` | Kitty terminal config |
| `htoprc` | `~/.config/htop/htoprc` | htop configuration |

### Shell Functions

All shell functions are installed to `~/.config/shell-functions/`:

| File | Purpose | Key Commands |
|------|---------|--------------|
| `kubectl-aliases.sh` | Kubernetes shortcuts | `k get p`, `kgpw`, `kdp`, `kshp` |
| `git-aliases.sh` | Git shortcuts | `g`, `gs`, `gaa`, `gcm`, `gp` |
| `git.sh` | Git workflow functions | `git-ch()`, `git-log()`, `git-add()` |
| `ssh.sh` | SSH helpers | `sshdot`, `sshconf`, `ssht` |
| `docker.sh` | Docker helpers | `dex`, `dlog`, `dclean` |
| `utils.sh` | Utilities | `mkcd`, `extract`, `backup` |
| `fuzzy-vim.sh` | Vim/Neovim with fzf | `v` (fuzzy file open) |
| `editor.sh` | Editor defaults | `vi`, `vim`, `vimdiff` use Neovim when available |
| `which.sh` | Command lookup | Includes shell aliases and functions |

### Git Aliases (in .gitconfig)

```bash
git ch          # Fuzzy branch checkout with preview
git flog        # Interactive commit browser
git fadd        # Fuzzy file staging with diff preview
git llog        # Fuzzy search through commit history
git st          # status
git cm          # commit -m
git lg          # Pretty log with graph
```

### Kubectl Aliases

```bash
# Quick shortcuts
k               # kubectl
kgp             # kubectl get pods
kgpw            # kubectl get pods -o wide
kdp             # kubectl describe pod
klf             # kubectl logs -f

# Functions
kshp <pattern>  # Shell into first pod matching pattern
klp <pattern>   # Logs from first pod matching pattern
kctx            # Switch context with fzf
kns             # Switch namespace with fzf
```

## 📦 Packages

### macOS (Homebrew)

Core tools: `awscli`, `bash`, `coreutils`, `git`, `fzf`, `fd`, `ripgrep`, `htop`, `neovim`, `tree`, `wget`
Development: `node`, `python`, `rust`, `poetry`, `virtualenv`
Kubernetes: `kubernetes-cli`, `helm`, `k9s`, `eksctl`, `minikube`
Infrastructure: `terraform`, `terraformer`, `tflint`
Apps: `docker`, `docker-desktop`, `slack`, `spotify`

### Linux

Equivalent packages are automatically installed based on distribution:
- **Debian/Ubuntu**: Via apt from `linux/debian/packages.list`
- **Arch/Manjaro**: Via pacman from `linux/arch/packages.list`
- **Fedora/RHEL**: Via dnf/yum from `linux/fedora/packages.list`
- **Alpine**: Via apk from `linux/alpine/packages.list`

## 🎨 Features

### Shell Prompt
- **Catppuccin Mocha** color theme
- Git branch and status indicators
- Current directory with smart truncation
- Kubernetes context awareness
- Python virtual environment display

Example prompt:
```
⭐ [jm@~/projects/dotfiles] main ➔
```

### Fuzzy Everything
- **File search**: `v` to open files with vim-compatible editor config
- **Git branches**: `git ch` for interactive checkout
- **Git commits**: `git flog` to browse history
- **Git staging**: `git fadd` to stage files
- **Kubernetes**: `kctx`/`kns` for context/namespace switching

### GNU Tools on macOS
Automatically aliases GNU versions to replace BSD utilities:
- `ls` → `gls` with colors
- `grep` → `ggrep`
- `sed` → `gsed`
- And more...

## 🔒 Backup

The installer automatically backs up existing configs to:
```
~/.dotfiles-backup-YYYYMMDD_HHMMSS/
```

To clean old backups (30+ days):
```bash
make clean-backup
```

## 🧭 Machine Convergence

`install.sh` is the single entry point for every machine. It detects the OS
and distribution and installs the right layer on top of `common/`:

- macOS: `darwin/` (Brewfile, kitty)
- Linux: `linux/<distro>/` packages plus, on Arch, the full desktop
  configuration under `linux/arch/.config/` (Sway, Waybar, GTK, kitty theme
  overlays)

Installs are always copies (never symlinks) with path-preserving backups and
an audit log. Preview any run with `./install.sh --dry-run`.

This converges personal interactive machines on Zsh, Kitty, and Neovim while
keeping Bash available as a fallback. The history of this effort is recorded
in `docs/machine-convergence-plan.md`.

## 🐳 Container Usage

The installer auto-detects container environments and uses minimal mode:
```bash
# In a Docker container
./install.sh  # Automatically uses --minimal
```

## ⚙️ Environment Detection

The installer automatically detects:
- **OS**: macOS, Linux (Ubuntu, Debian, Arch, Fedora, Alpine, etc.)
- **Environment**: Local, SSH session, Docker container
- **Shell**: Bash, Zsh
- **Available tools**: Adjusts configs based on what's available

## 🔧 Customization

### Local Overrides
Create `~/.bashrc.local` or `~/.zshrc.local` for machine-specific configs.

### Memory Management
The installer respects `CLAUDE.md` files for project-specific context.

## 📚 Requirements

- **macOS**: Homebrew (auto-installed if missing)
- **Linux**: sudo access for package installation
- **All systems**: Git, Bash 4+

## 🚑 Troubleshooting

```bash
# Check what would be installed
./install.sh --dry-run

# Skip package installation
./install.sh --no-packages

# Force minimal mode
./install.sh --minimal

# View installer help
./install.sh --help
```
