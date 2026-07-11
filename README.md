# Dotfiles

Personal dotfiles for macOS and Linux with modular shell functions, git workflows, and kubectl shortcuts.

## 🚀 Quick Install

```bash
# Clone and install
git clone https://github.com/woud420/dotfiles.git ~/workspace/projects/dotfiles
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
./install.sh --check        # Compare managed live files with the repo
./install.sh --backup-only  # Snapshot managed files without installing
./install.sh --doctor       # Check runtime dependencies

# Make targets
make install              # Full installation
make install-minimal      # Minimal config
make install-no-packages  # Config files only
make install-dry-run      # Preview changes
make check-live           # Detect missing or changed managed files
make backup               # Create a path-preserving live backup
make doctor               # Check commands, portals, fonts, and themes
```

### Remote Installation

```bash
# Minimal quick-install (shallow-clones the repo and copies server configs)
curl -sSL https://raw.githubusercontent.com/woud420/dotfiles/master/scripts/quick-install.sh | bash

# Or clone and run the full installer
git clone https://github.com/woud420/dotfiles.git && cd dotfiles && ./install.sh --minimal
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
| `common/git/hooks/*` | `~/.config/git/hooks/*` | Personal global Git hooks |
| `common/ssh/config` | `~/.ssh/config.dotfiles` | Shared SSH defaults (Include'd from `~/.ssh/config`) |
| `kitty.conf` | `~/.config/kitty/kitty.conf` | Kitty terminal config |
| `htoprc` | `~/.config/htop/htoprc` | htop configuration |
| `.vim/*` | `~/.vim/` | Vim config, settings, and CoC settings |
| `common/nvim/init.vim` | `~/.config/nvim/init.vim` | Neovim bridge to the Vim config |
| `.vim/coc-settings.json` | `~/.vim/` and `~/.config/nvim/` | CoC LSP settings (both editors) |
| `scripts/sudo-askpass.sh` | `~/.local/bin/sudo-askpass` | GUI sudo prompt helper |
| `linux/arch/firefox/*` | Active Firefox profile | Desktop-matched browser chrome and settings pages |

### Shell Functions

All shell functions are installed to `~/.config/shell-functions/`:

| File | Purpose | Key Commands |
|------|---------|--------------|
| `editor.sh` | Editor defaults | `vi`, `vim`, `vimdiff` use Neovim when available |
| `which.sh` | Command lookup | Includes shell aliases and functions |
| `sudo.sh` | GUI sudo prompts | Exports `SUDO_ASKPASS` (use `sudo -A`) |
| `macos-clipboard.sh` | Clipboard parity | `pbcopy`/`pbpaste` on Linux (wl-clipboard) |
| `kubectl-aliases.sh` | Kubernetes | `k` (kubectl); `kctx` lives in the shell rc files |

The remaining function files (`git.sh`, `git-aliases.sh`, `docker.sh`,
`docker-aliases.sh`, `k8s.sh`, `ssh.sh`, `utils.sh`, `fuzzy-vim.sh`,
`modern-tools-aliases.sh`, `secrets.sh`, `system-aliases.sh`) are currently
**disabled stubs** - kept in place so they can be restored incrementally
without breaking installs.

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
k               # kubectl
kctx            # Switch context with fzf
```

## 📦 Packages

### macOS (Homebrew)

Core tools: `awscli`, `bash`, `coreutils`, `git`, `fzf`, `fd`, `ripgrep`, `htop`, `neovim`, `tree`, `wget`
Development: `node`, `python`, `rust`, `poetry`, `virtualenv`
Kubernetes: `kubernetes-cli`, `helm`, `k9s`, `eksctl`, `minikube`
Infrastructure: `terraformer`, `tflint`
Apps: `docker-desktop` (bundles the docker CLI), `slack`, `spotify`

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
- **Git branches**: `git ch` for interactive checkout
- **Git commits**: `git flog` to browse history
- **Git staging**: `git fadd` to stage files
- **Kubernetes**: `kctx` for context switching

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

Backups mirror home-directory paths under `files/` and include an
`install-audit.tsv`. Create a snapshot without changing live files with:

```bash
make backup
```

Restore one file after inspecting a backup:

```bash
cp -a ~/.dotfiles-backup-YYYYMMDD_HHMMSS/files/.config/waybar/config \
  ~/.config/waybar/config
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
an audit log. Preview any run with `./install.sh --dry-run`, then use
`./install.sh --check` to prove every managed live copy matches the repo.

On Arch, the installer also discovers the active profile from Firefox's
`profiles.ini` and installs the tracked `userChrome.css`, `userContent.css`,
and `user.js`. Launch Firefox once before the first install so the profile
exists, and restart Firefox after those files change.

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
Machine-specific config lives outside the repo and survives reinstalls:

- `~/.bashrc.local` / `~/.zshrc.local` - sourced at the end of the shell configs
- `~/.gitconfig.local` - included last by `.gitconfig`, so identity or
  tool-appended blocks (e.g. git-ai) win over the shared config
- `~/.ssh/config` - your own host entries stay first; the shared defaults are
  pulled in via `Include ~/.ssh/config.dotfiles`. Note the shared defaults set
  `ForwardAgent yes` globally - convenient across personal machines, but scope
  it per-host in a local block if you ssh to hosts you don't control.

### Personal Git Hooks

The installed `.gitconfig` sets `core.hooksPath = ~/.config/git/hooks`.
Installed hooks are intentionally general and local-only:

- `pre-commit` runs repo hooks like `.husky/pre-commit` first, then blocks
  likely secrets, conflict markers, oversized files, and generated-looking
  files (lockfiles allowlisted; override with `JM_ALLOW_GENERATED_EDITS=1`).
- `pre-push` runs repo hooks first, then an explicit repo check when configured.

```bash
JM_GIT_HOOKS=0 git commit ...              # Skip personal hooks once
git config jm.hooks.runRepoHooks false     # Don't run repo-controlled hooks in an untrusted clone
git config jm.hooks.prePushCommand "make check"
make install-git-hooks                     # Install only the hooks
```

### Minimal mode
`--minimal` (auto-enabled in containers) installs the server bashrc and core
configs only: it skips packages, vim/nvim plugins, desktop configs, the
sudo-askpass helper, and AI context files, but still installs terminal
(kitty/htop) configs.

### AI Context
The installer copies `common/ai-context/` files into place:
`~/AGENTS.md` and an OS-specific `~/MACHINE.md`; `~/.claude/CLAUDE.md` is
only seeded when absent (an existing customized one is left alone).
Machine state snapshots are generated on demand with
`scripts/refresh-machine-state.sh`.

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
