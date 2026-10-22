# Installer

[`install.sh`](../../install.sh) is the main installer. The
[`Makefile`](../../Makefile) exposes shortcuts; `./install.sh --help` lists
the supported options.

## Modes

| Option | Behavior |
| --- | --- |
| No option | Full installation: packages, managed configuration, plugins, optional tools, context, skills, and plugin update scheduling |
| `--no-packages` | Skips OS package installation; retains the other full-install steps, including plugin and optional fzf downloads |
| `--minimal` | Uses server Bash; skips packages, desktop/Firefox, plugin installation/scheduling, optional tools, askpass, agent context, and private skills |
| `--preserve-existing` | Keeps active configuration; syncs selected skills and adds eligible unused helpers and themes |
| `--dry-run` | Reports planned actions without applying them; combine with the mode being previewed |
| `--check` | Compares managed live files with repository sources and reports drift |
| `--backup-only` | Snapshots existing managed files and local overrides without installing configuration |
| `--doctor` | Checks runtime commands and platform dependencies without installing them |
| `--copy` | Historical no-op: managed configuration is always copied |

Minimal mode still copies Git/SSH defaults and hooks, shell modules, Kitty/htop,
and Vim/Neovim configuration. It skips editor plugin installation, not the
editor configuration files.

Only one of `--check`, `--backup-only`, and `--doctor` may be selected.
`--preserve-existing` may be combined with `--dry-run`, `--no-packages`, and
`--copy`; combining it with `--minimal` or a state-check/backup mode is rejected.

## Files, backups, and audit records

Managed configuration targets are regular file copies. Existing file or symlink
targets are backed up before replacement. Legacy parent-directory symlinks that
resolve into this checkout are materialized as real directories on the regular
install path so copying cannot overwrite the source through a link.

Backups default to `~/.dotfiles-backup-YYYYMMDD_HHMMSS/`. Set
`DOTFILES_BACKUP_DIR` to choose another backup directory. Each backup uses:

```text
.dotfiles-backup-YYYYMMDD_HHMMSS/
├── files/                 # Original targets, with home-relative paths
└── install-audit.tsv      # timestamp, action, source, target, detail
```

Backups retain the first saved copy of a target within that backup directory.
`--backup-only` also includes `.bashrc.local`, `.zshrc.local`,
`.gitconfig.local`, and `.ssh/config` when present. It snapshots files visited
by the selected platform/mode, not the entire home directory.

The systemd timer enablement link is scheduling metadata; configuration files
themselves are copied. Recovery is manual: there is no `--restore` option or
`make restore-backup` target. See [recovery](../operations/maintenance.md).

## Check and doctor scope

`--check` reports missing files, changed contents, symlink targets where copies
are expected, missing executable permissions for executable source files, and a
`~/.vimrc` that would shadow `~/.vim/vimrc`.
It also checks for legacy parent symlinks into the checkout and the shared SSH
Include directive. Missing source files are warned about and skipped.

The check covers files selected by the current platform, mode, and available
skillpack. It normally checks private skills under `~/.agents/skills`, not the
extra destinations used by preserving installation. An existing customized
`~/.claude/CLAUDE.md` is retained rather than required to match.

A nonzero exit status indicates reported drift. Intentional differences after
`--preserve-existing` can therefore fail a regular `--check`. Matching files
does not prove visual parity, keybinding behavior, plugin health, or compatibility
with a particular machine's workflow.

`--doctor` checks Bash, Git, Zsh, Kitty, Neovim, ripgrep, and fzf, and warns
about missing editor tooling (`tree-sitter`, `black`, `pylint`, `shellcheck`) or
a `~/.vimrc` that shadows `~/.vim/vimrc`. On Arch it
also checks desktop commands, portals, the GTK theme, FiraCode Nerd Font, and a
SwayFX runtime. Docker and kubectl are optional checks there. Missing required
components produce a nonzero exit status; minimal servers can intentionally
lack tools from this workstation-oriented check.

## Preserving an existing setup

This mode is intended for an existing Mac workflow. It skips package installation,
shell/editor configuration, plugins and builds, Git/SSH policy, agent context,
terminal reloads, and automatic update scheduling.

It can change:

- **Skills:** Git-tracked files in `active` and `maintenance` skills are synced
  to `~/.agents/skills`, `~/.codex/skills`, and `~/.claude/skills`. Registered
  `candidate` skills are refreshed only in destinations where that candidate
  is already installed. Changed files are backed up; target-only content remains.
- **Manual helpers:** `sudo-askpass` and `vim-plug-update` are added under
  `~/.local/bin` only when their command names and destination paths are unused.
  They are not invoked, added to shell startup, or scheduled.
- **Named Kitty themes:** missing non-selected theme files may be added on macOS
  only when the active Kitty config and selected theme exactly match the verified
  repository defaults and include layout. The selected theme is never replaced.
  Custom, missing, or unverified active configs receive no theme additions.

Existing helper/theme paths and unsafe parent directories are skipped. Skill
selection and all source files/destination parents are validated before skill
copying; directory symlinks, missing tracked files, and invalid manifests fail
that validation. This is not an atomic rollback mechanism for later I/O failures.

The checked-out skillpack revision is used. An unavailable source may be
initialized at its pinned revision; the installer does not advance it to the
latest remote commit. A real preserving install fails if private skills cannot
be prepared, unless explicitly skipped with `DOTFILES_SKIP_PRIVATE_SKILLS=1`
or unavailable in CI. A dry run with an uninitialized skillpack can describe
initialization but cannot enumerate its missing contents.

## Platform and environment selection

macOS uses Homebrew. Linux package branches cover Debian/Ubuntu, Arch/Manjaro,
Fedora/RHEL/CentOS, and Alpine. Desktop and Firefox configuration are restricted
to Arch/Manjaro; Firefox needs an existing profile discoverable through
`~/.mozilla/firefox/profiles.ini`.

Containers automatically select minimal mode unless `DOTFILES_FULL_INSTALL`
is nonempty. SSH is detected but does not automatically select minimal mode in
`install.sh`; pass `--minimal` explicitly for a server.

The older [`quick-install.sh`](../../scripts/quick-install.sh) is a separate
copy script with different behavior and limited backup handling. The supported
preview/check/backup workflow uses `install.sh`.
