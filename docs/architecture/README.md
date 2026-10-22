# Architecture

The repository shares command-line behavior across macOS and Linux while
keeping package managers, desktop components, and visual style platform-specific.

## Source layout

| Path | Responsibility |
| --- | --- |
| [`install.sh`](../../install.sh) | Mode parsing, OS/environment detection, deployment, backups, and checks |
| [`Makefile`](../../Makefile) | Shortcuts for the installer, validation, and maintenance |
| [`common/shell/`](../../common/shell/) | Interactive Bash/Zsh, server Bash, GNU aliases, and directory colors |
| [`common/shell-functions/`](../../common/shell-functions/README.md) | Modules sourced by the shell configurations |
| [`common/git/`](../../common/git/) and [`common/ssh/`](../../common/ssh/) | Shared Git configuration, hooks, and SSH defaults |
| [`.vim/`](../../.vim/) and [`common/nvim/`](../../common/nvim/) | Shared Vimscript configuration and Neovim bridge |
| [`common/themes/`](../../common/themes/) | Shared Kitty themes |
| [`common/ai-context/`](../../common/ai-context/) | Shared agent instructions |
| [`darwin/`](../../darwin/README.md) | Homebrew bundle, macOS Kitty, launchd, and machine context |
| [`linux/`](../../linux/README.md) | Distro packages, shared Linux Kitty/systemd files, and machine context |
| [`linux/arch/`](../../linux/arch/README.md) | Desktop configuration, Firefox styling, and Kitty overlays |
| `private/skills/` | Pinned private skillpack submodule, maintained in its own repository |
| [`scripts/`](../../scripts/) | Installer tests, editor checks, update helpers, and machine-state capture |

## Installation flow

`install.sh` detects the OS, Linux distribution, and whether it runs locally,
over SSH, or in a container. It then chooses one of these paths:

1. `--doctor` checks runtime dependencies and returns.
2. `--preserve-existing` syncs selected skills and adds eligible unused helpers
   and themes, then returns.
3. The regular path installs packages when enabled, then visits shell, Git,
   SSH, shell functions, terminal, Arch desktop/Firefox, Vim/Neovim, the plugin
   update schedule, optional tools, agent context, and private skills.

On the regular path, `--dry-run`, `--check`, and `--backup-only` change how those
steps operate. See the [installer contract](../contracts/installer.md) for
their scope and exclusions.

Managed configuration is copied into the home directory. Live edits therefore
do not edit the repository. The installer can compare those copies with their
sources; backups retain home-relative paths and an audit log.

## Configuration boundaries

- Shared shell behavior belongs in `common/`. Neovim loads `~/.vim/vimrc`
  through `~/.config/nvim/init.vim`, sharing Vimscript settings and plugins.
- macOS uses `darwin/kitty.conf`; Linux uses `linux/common/kitty.conf`.
  Arch adds its own Kitty theme and desktop layer. Other platforms keep the
  shared Catppuccin theme.
- Machine-specific shell and Git settings belong in local override files.
  SSH host entries and identity paths stay in the local SSH configuration.
- Private skills come from the checked-out submodule revision. Normal installs
  target `~/.agents/skills`; preserving installs also target Codex and Claude.
- Machine-state snapshots are generated on demand and ignored by Git.

See [configuration paths](../contracts/configuration.md),
[local customization](../operations/customization.md), and the
[convergence decision](../decisions/machine-convergence.md).
