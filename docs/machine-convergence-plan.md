> **Status (2026-07):** historical. The convergence happened on
> `converge/jm-home-box-laptop`; decisions that supersede parts of this plan:
> `install.sh` is the single install tool (`scripts/dotfiles.py` and
> `machines/<hostname>/` were removed), per-machine visual identity is handled
> by the Arch-only overlay in `linux/arch/.config/kitty/`, and machine-local
> runtime state lives in `~/.bashrc.local` / `~/.zshrc.local` /
> `~/.gitconfig.local` rather than the repo. The negotiated two-agent plan this
> executed is archived in `docs/convergence/combined-plan.md`.

# Machine Convergence Plan

Goal: keep the same daily capabilities and muscle memory across `jm-home-box`,
the personal MBP, and the Charlie Labs MBP while preserving machine/style
differences where they are intentional.

## Branch Model

- `fix/jm-home-box`: capture and normalize this Arch machine first.
- `fix/personal-mbp`: capture the personal MacBook Pro state.
- `fix/charlie-mbp`: capture the Charlie Labs MacBook Pro state.
- `feat/converge-three-machines`: merge the three inventories into a durable
  shared model.

The `fix/<machine>` branches are inventory and cleanup branches. They should not
become permanent configuration silos.

## Configuration Model

- `common/`: shared behavior and source-of-truth configs.
- `darwin/`: macOS package lists and platform adapters.
- `linux/`: Linux package lists and platform adapters.
- `machines/<hostname>/`: machine identity, role, and explicit deltas.
- `common/bin/`: executable commands shared by every shell.

Interactive machines should converge on:

- Kitty for terminal behavior.
- Zsh for the rich interactive shell.
- Bash as a minimal fallback for servers, containers, and recovery.
- Neovim as the editor target, with Vim kept as fallback.
- 1Password CLI/app integration for secrets and SSH where possible.

## Copy Deployment

Managed dotfiles should be copied into place, not symlinked. The repository
remains the source of truth, and drift is detected by comparing live files with
repo sources.

Current workflow:

```bash
make dotfiles-doctor
make dotfiles-dry-run
make dotfiles-backup
make dotfiles-install
make dotfiles-diff-live
```

`scripts/dotfiles.py` owns the copy-based workflow:

- backs up managed live files before changes
- copies files into place
- writes `~/.local/share/dotfiles/install-manifest.json`
- reports changed, missing, or symlinked managed files
- checks expected local tools with `doctor`

## jm-home-box State

This machine is the first convergence branch.

Done:

- Added `machines/jm-home-box/machine.toml`.
- Converted managed live dotfiles from symlinks to real copied files.
- Added backup/install/diff/doctor tooling.
- Added Neovim phase-1 entrypoint that preserves the existing Vim config.
- Added guarded Tree-sitter config for Neovim.
- Fixed copied Linux Kitty theme include.
- Verified `dotfiles diff-live` is clean.

Still expected locally:

- Install `zsh`.
- Install `neovim`.
- Test Zsh before making it the login shell.
- Run Neovim plugin install and Tree-sitter setup after `nvim` exists.

## MBP Capture Plan

On each MBP:

1. Create the matching `fix/<machine>` branch.
2. Add `machines/<hostname>/machine.toml`.
3. Capture package state:
   `brew bundle dump --force --file machines/<hostname>/Brewfile.current`.
4. Capture current shell/editor/terminal state.
5. Run the copy workflow in dry-run mode first.
6. Compare differences against `fix/jm-home-box`.
7. Move shared behavior into `common/`; keep platform differences in `darwin/`
   or `linux/`; keep identity differences in `machines/<hostname>/`.

## Comparison Rules

Classify every difference as one of:

- shared behavior
- platform adapter
- machine identity
- style
- obsolete drift

Only shared behavior belongs in `common/`. Machine identity should be explicit,
small, and documented.

