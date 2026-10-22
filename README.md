# Dotfiles

Personal macOS and Linux configuration for a consistent shell, editor, and Git
workflow. Shared behavior lives in `common/`; macOS and Linux keep their own
packages, desktop configuration, and visual style.

- **Shell:** Zsh for interactive use, Bash for fallback and servers, with shared
  functions and fuzzy Git and Kubernetes commands.
- **Editor:** Neovim loads the shared Vim configuration, mappings, and plugins.
- **Terminal and desktop:** Kitty on both platforms; SwayFX, Waybar, Rofi, Mako,
  and Firefox styling on Arch.
- **Installation:** regular file copies, path-preserving backups, an audit log,
  and separate preview, drift-check, and dependency-check modes.
- **Agents:** shared context files and a pinned private skillpack.

## Get started

From the directory where you keep your projects, clone the repository, then
preview the mode that fits the machine:

```bash
git clone https://github.com/woud420/dotfiles.git
cd dotfiles
./install.sh --help
```

The checkout can live anywhere; the installer resolves its own directory.

| Goal | Preview | Apply |
| --- | --- | --- |
| Set up a personal workstation | `./install.sh --dry-run` | `./install.sh` |
| Keep an existing Mac workflow; refresh skills and add unused helpers | `./install.sh --preserve-existing --dry-run` | `./install.sh --preserve-existing` |
| Use repo configuration with packages managed separately | `./install.sh --no-packages --dry-run` | `./install.sh --no-packages` |
| Set up a server or container | `./install.sh --minimal --dry-run` | `./install.sh --minimal` |

Full installation replaces managed configuration and can install editor plugins,
change Git/SSH defaults, and schedule weekly plugin updates. `--no-packages`
only skips the package-manager step. Choose `--preserve-existing` explicitly
when keeping the current Mac setup.

Start with the [installation guide](docs/operations/installation.md) for
prerequisites, private-skill access, platform notes, and verification. Linux
requires Bash 4+; macOS supports the system Bash 3.2.

## Everyday commands

```bash
git ch          # Choose a branch with fzf
git flog        # Browse commits interactively
git fadd        # Stage files with a diff preview
kctx            # Choose a Kubernetes context with fzf
```

After a full install, `vi`, `vim`, and `vimdiff` prefer Neovim when available.
See the [configuration reference](docs/contracts/configuration.md) for installed
paths and the [customization guide](docs/operations/customization.md) for local
overrides, Git hooks, and themes.

## Documentation

The [documentation index](docs/README.md) follows the same five-category layout
as Kickstart:

| Category | Read it for |
| --- | --- |
| [Architecture](docs/architecture/README.md) | Repository layout, platform layers, and installation flow |
| [Contracts](docs/contracts/README.md) | Installer modes, managed paths, and compatibility boundaries |
| [Operations](docs/operations/README.md) | Installation, customization, skills, backup, recovery, and validation |
| [Decisions](docs/decisions/README.md) | Accepted choices and historical convergence context |
| [Ideas](docs/ideas/README.md) | Future proposals and their lifecycle |

For maintenance, use the [backup and recovery guide](docs/operations/maintenance.md).
For repository changes, use the [validation guide](docs/operations/validation.md).
