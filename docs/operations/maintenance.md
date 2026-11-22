# Maintenance and recovery

## Inspect drift and dependencies

```bash
make check-live          # Compare selected managed copies with repository files
make doctor              # Check workstation runtime dependencies
./install.sh --dry-run   # Preview a regular install
```

Use `./install.sh --minimal --check` when validating a minimal installation.
After preserving installation, a regular drift check may report deliberately
retained local differences. Read the [check scope](../contracts/installer.md#check-and-doctor-scope)
before treating those differences as errors to overwrite.

For a missing dependency, review the current platform's package inventory and
doctor output. `--no-packages` will not repair missing OS packages.

## Create a snapshot

```bash
make backup
```

This runs `./install.sh --backup-only`. Backups default to
`~/.dotfiles-backup-YYYYMMDD_HHMMSS/`, preserve target paths under `files/`,
and include `install-audit.tsv` when actions are recorded. Local shell/Git
overrides and the local SSH config are included when present.

For another destination:

```bash
DOTFILES_BACKUP_DIR="$HOME/dotfiles-snapshot" ./install.sh --backup-only
```

Choose a fresh directory for a new snapshot: an existing backup of the same
target is retained. A snapshot covers selected managed paths, not packages,
all plugins, or the whole home directory. `--minimal --backup-only` selects
the minimal file set.

## Restore a file

Select an actual backup directory, inspect its log and original file, and compare
before copying. For example, to restore Zsh configuration:

```bash
dotfiles_backup="$HOME/.dotfiles-backup-YYYYMMDD_HHMMSS"
less "$dotfiles_backup/install-audit.tsv"
ls -ld "$dotfiles_backup/files/.zshrc" "$HOME/.zshrc"
diff -u "$dotfiles_backup/files/.zshrc" "$HOME/.zshrc"
cp -a "$dotfiles_backup/files/.zshrc" "$HOME/.zshrc"
```

Replace the timestamp placeholder first. A diff exit status of 1 means the files
differ. Inspect symlink backups before restoring them, and preserve any newer
local edits separately. Open a new shell to check the result.

There is no automatic whole-install restore command. Newly created files have
no previous copy to restore; use the audit log to identify them. File restoration
does not uninstall packages or reverse active timers/agents. Handle those
separately when rolling back.

`make clean-backup` deletes matching home-directory backup directories older
than 30 days. Inspect them and retain needed snapshots before using it.

## Upgrading agent instructions

On a full install, including `--no-packages`, Codex and Claude receive the
shared instructions and platform notes whenever their respective CLIs are on
`PATH`. This replaces existing global instructions, including a customized
`CLAUDE.md` that older installers kept. Preview with `./install.sh --dry-run`.
Choose `--preserve-existing` to keep managing those files yourself.

For a default installation, recover previous rules and imports from
`files/.codex/AGENTS.md` or `files/.claude/CLAUDE.md` in the backup.
If you set `CODEX_HOME` or `CLAUDE_CONFIG_DIR`, look up the `backup` entry for
the instruction file in `install-audit.tsv`. Backups mirror paths under
`$HOME` in `files/` and paths outside it in `files/absolute/`. Compare the
original with the generated file and restore the rules you need. To include
rules on future full installs, put the ones you want to share in
`common/ai-context/AGENTS.md`.

Older installs may also have created `~/AGENTS.md` and `~/MACHINE.md`.
They remain on disk. Review them for local edits and references from other
tools before archiving unused copies. On Arch, retire the
[optional pacman hook](arch-desktop.md#retire-the-old-machine-state-hook)
if you installed it.

## Editor plugin updates

A regular full install deploys `~/.local/bin/vim-plug-update` and schedules
weekly updates through launchd on macOS or a systemd user timer when available
on Linux. Minimal and preserving installs do not activate that schedule.

The updater upgrades vim-plug, updates the plugins listed in `plugins.vim`,
removes plugin directories no longer listed there (`PlugClean!`), rebuilds
tree-sitter parsers when `tree-sitter-cli` is installed, and updates CoC
extensions. To run it manually after reviewing the
[updater](../../scripts/vim-plug-update.sh):

```bash
~/.local/bin/vim-plug-update
```

Inside Neovim, `:checkhealth nvim-treesitter coc` reports the parser toolchain
and the CoC service; `:TSUpdate` rebuilds parsers and `:CocUpdate` refreshes
extensions on demand.

To inspect scheduling:

```bash
# macOS
launchctl print "gui/$(id -u)/com.woud420.vim-plug-update"

# Linux with a running systemd user manager
systemctl --user status vim-plug-update.timer
```

For plugin-install warnings, open Vim/Neovim and run `:PlugInstall`, then retry
the [editor parity check](validation.md#editor-changes). CoC compilation also
depends on the build tools described in the installer output.

## Package inventories

`make brew-sync` overwrites `darwin/Brewfile` with a dump of the current Mac's
Homebrew bundle. Review the diff before treating local package state as shared
configuration.

For skillpack revision maintenance, use the [private-skills guide](private-skills.md).
