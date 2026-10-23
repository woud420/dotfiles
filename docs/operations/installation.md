# Installation

## Prerequisites

- Git and Bash. macOS supports system Bash 3.2; Linux needs Bash 4+ for the
  distribution-detection code.
- macOS full package setup uses Homebrew, bootstrapping it if absent. Linux
  package installation needs the appropriate package manager and sudo access.
- Package, plugin, and optional-tool downloads need network access. Use the
  [package inventories](../contracts/configuration.md#local-ownership) to review
  what the selected platform requests.
- Private skills require Python 3 and GitHub SSH access to the private skillpack.
  Set `DOTFILES_SKIP_PRIVATE_SKILLS=1` explicitly when installing without it.
- Editor plugins are cloned anonymously over HTTPS with the global Git config
  bypassed, so the shared `url.insteadOf` SSH rewrite does not block a machine
  that has no GitHub key yet.

From the directory where you keep your projects:

```bash
git clone https://github.com/woud420/dotfiles.git
cd dotfiles
./install.sh --help
```

The checkout can live anywhere; the installer resolves its own directory.

## Choose a mode

Preview and apply the same mode. Full installation replaces managed configuration
and can change shell/editor behavior, Git hooks and policy, SSH defaults, and
the weekly plugin update schedule.

### Personal workstation

```bash
./install.sh --dry-run
./install.sh
```

This installs the shared configuration plus the current platform's package and
configuration layer. `make install` runs the same installer.

### Existing Mac workflow

```bash
./install.sh --preserve-existing --dry-run
./install.sh --preserve-existing
```

This keeps active configuration and tools, syncs selected skills, and adds only
eligible unused manual helpers and named Kitty themes. No shell reload is needed.
Read the [preserving-mode contract](../contracts/installer.md#preserving-an-existing-setup)
for selection rules, collision handling, and what a dry run can verify.

### Packages managed separately

```bash
./install.sh --no-packages --dry-run
./install.sh --no-packages
```

This keeps the rest of full installation, including plugin downloads/builds,
optional fzf installation, Git/SSH changes, and scheduling. It is not an offline
installation mode.

### Servers and containers

```bash
./install.sh --minimal --dry-run
./install.sh --minimal
```

Minimal mode uses server Bash and skips packages, desktop/Firefox, plugin
downloads, scheduling, optional tools, agent context, and private skills. It still
copies Git/SSH defaults, hooks, shell modules, terminal configs, and editor configs.

Containers select minimal mode automatically unless `DOTFILES_FULL_INSTALL` is
set. SSH sessions do not: select `--minimal` explicitly. For a remote machine,
clone there and use this workflow. The older `scripts/quick-install.sh` has
different copy/backup behavior and does not expose these modes.

## Platform notes

- **macOS:** packages and apps come from [`darwin/Brewfile`](../../darwin/Brewfile).
  Kitty uses the macOS config and shared theme. The full installer installs a
  launchd agent for weekly editor plugin updates.
- **Arch/Manjaro:** packages come from the native and AUR lists. The full install
  deploys the desktop and Firefox styling. Launch Firefox once to create a
  profile before installation; see the [Arch guide](arch-desktop.md).
- **Debian/Ubuntu, Fedora/RHEL/CentOS, Alpine:** packages come from the matching
  distro list. These platforms use Linux Kitty and shared themes without the
  Arch desktop layer. A systemd user timer is installed when systemctl exists.

## Verify the result

After a regular full installation:

```bash
./install.sh --check
./install.sh --doctor
```

`--check` compares selected managed files; `--doctor` checks workstation runtime
dependencies. Neither establishes that every visual or shortcut behaves as
intended. Review warnings, then open a new shell, Kitty, and editor to check the
workflow. Restart Firefox after profile CSS changes; on Arch, reload Sway with
`swaymsg reload`.

For a minimal installation, use `./install.sh --minimal --check` to select the
same file set. Doctor can report intentionally absent workstation tools.
After preserving installation, regular `--check` can report intentional local
differences; compare the result with the preview and check the retained workflow.

Use [maintenance and recovery](maintenance.md) to inspect the audit log or restore
files, and [customization](customization.md) to keep machine-specific settings local.
