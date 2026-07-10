# Dotfiles Unification Plan - Codex

## Purpose

Unify the macOS laptop branch and the Linux jm-home-box branch into one default
dotfiles repository that feels consistent to use everywhere, while preserving
machine-specific visuals and platform-specific system configuration.

Target branches:

- `feature/personal-laptop-combined`: current macOS laptop branch and current
  source of recent Neovim, copy-install, Brewfile, and shell updates.
- `fix/jm-home-box`: current Linux jm-home-box branch and current source of
  Arch, Sway, machine-state, and Linux visual configuration.

Core rule:

> Common tooling behavior belongs in shared config. Visual identity and
> platform/machine facts belong in platform or machine profiles.

## Desired Outcome

The default branch should work on:

- The MacBook Pro.
- The Linux jm-home-box.
- Future machines with minimal new machine-specific metadata.

The user experience should be consistent for:

- Editor commands: `vi`, `vim`, `vimdiff`, `EDITOR`, and `VISUAL`.
- Neovim behavior, plugins, and keybindings.
- Shell aliases and functions where the underlying tools exist.
- `rtk` command conventions.
- Git aliases and commit template.
- Installer behavior, especially regular copied files, no symlinks, backups,
  and audit logs.

The user experience may remain machine-specific for:

- Kitty theme choice and colors.
- Sway/SwayFX visuals.
- Linux desktop assets.
- macOS application/cask choices.
- Arch package choices.
- Machine role, hardware facts, and known local hazards.

## Non-Negotiable Constraints

1. Do not reintroduce symlink-based installation.
2. Installed dotfiles must be regular copied files.
3. Installer must create path-preserving backups before replacing files.
4. Installer must write an auditable install log.
5. Neovim is the target editor when available.
6. `vi`, `vim`, and `vimdiff` should use Neovim when available.
7. `which` must be shell-aware and must see aliases. Do not alias `which` to
   `gwhich`.
8. Do not copy local daemon/socket paths into shared config.
9. Do not flatten Linux and macOS visuals into one global theme.
10. Do not stage unrelated changes during the merge.

## Proposed Final Layout

```text
.
├── common/
│   ├── git/
│   │   ├── .gitconfig
│   │   ├── .gitignore_global
│   │   └── commit-template.md
│   ├── nvim/
│   │   └── init.vim
│   ├── shell/
│   │   ├── .bash_profile
│   │   ├── .bashrc
│   │   ├── .bashrc.server
│   │   ├── .gnu_aliases
│   │   └── .zshrc
│   ├── shell-functions/
│   │   ├── editor.sh
│   │   ├── which.sh
│   │   └── ...
│   ├── themes/
│   └── ssh/
├── darwin/
│   ├── Brewfile
│   ├── kitty.conf
│   └── README.md
├── linux/
│   ├── arch/
│   │   ├── packages.list
│   │   ├── ai-context/
│   │   └── .config/sway/
│   ├── common/
│   │   └── kitty.conf
│   └── README.md
├── machines/
│   └── jm-home-box/
│       └── machine.toml
├── scripts/
├── install.sh
├── Makefile
└── README.md
```

Potential future addition:

```text
.agents/
├── AGENTS.md
├── RTK.md
└── skills/
```

Do not add machine-specific `AGENTS.md` files unless a machine truly needs
different agent behavior. Machine files should describe facts and role, not
agent operating style.

## Merge Model

Use a three-layer model:

1. Shared behavior layer: `common/`, `.vim/`, `common/nvim/`, shared scripts,
   Git config, shell functions, Make targets, install logic.
2. Platform layer: `darwin/`, `linux/`, platform package files, platform
   terminal config.
3. Machine layer: `machines/<name>/`, hardware/state/role metadata and selected
   profile facts.

When branches conflict:

- Prefer `common/` only for behavior that should feel identical everywhere.
- Prefer `darwin/` for Homebrew, macOS Kitty config, and macOS-specific setup.
- Prefer `linux/` for Arch packages, Sway, Linux Kitty config, and Linux desktop
  setup.
- Prefer `machines/jm-home-box/` for jm-home-box state and inventory.
- Prefer the newest tested installer behavior from the laptop branch where it
  enforces copy-only installs, backups, and audit logs.
- Preserve jm-home-box visuals from the Linux branch.

## Area-by-Area Plan

### 1. Shell Entry Points

Files:

- `common/shell/.zshrc`
- `common/shell/.bashrc`
- `common/shell/.bash_profile`
- `common/shell/.bashrc.server`
- `common/shell/.gnu_aliases`

Desired result:

- Shared prompt/tool behavior lives in `common/shell`.
- `rtk` is available through normal PATH behavior where installed.
- `~/.git-ai/bin` may be added through a guarded path check, not as a hardcoded
  installer comment.
- zsh `PROMPT_EOL_MARK=''` is okay as shared behavior.
- Homebrew PATH belongs in common shell only as guarded macOS-safe path logic.
- Platform-specific package manager aliases should either be guarded or moved
  to platform-specific shell snippets if they become numerous.

Conflict rule:

- Keep the shell setup that is guarded and portable.
- Remove local installer comments and absolute local daemon state.

### 2. Shell Functions and Aliases

Files:

- `common/shell-functions/*.sh`

Desired result:

- `editor.sh` sets `EDITOR` and `VISUAL` to `nvim` when available and aliases
  `vi`, `vim`, and `vimdiff` to Neovim.
- `which.sh` provides shell-aware lookup. It must report aliases in zsh/bash.
- Shared aliases should behave the same on both machines where possible.
- Platform-only aliases must be guarded by command availability or split later
  into platform snippets.

Conflict rule:

- If the same alias/function exists on both branches with different behavior,
  keep the version that is command-availability guarded and less destructive.
- Keep Linux-only workflow helpers only when guarded or clearly placed in Linux
  config.

### 3. Editor: Vim to Neovim

Files:

- `.vim/vimrc`
- `.vim/plugins.vim`
- `.vim/mappings.vim`
- `.vim/settings/*.vim`
- `.vim/coc-settings.json`
- `common/nvim/init.vim`
- `scripts/check-editor-parity.sh`
- `scripts/editor-parity.vim`

Desired result:

- Neovim is the default editor on both machines.
- `common/nvim/init.vim` bridges to existing Vim config where appropriate.
- Vim-only options are guarded so Neovim does not error.
- Keybindings must be identical across machines.
- Editor parity test must pass for both Vim and Neovim config load.

Conflict rule:

- Treat Vim config as source compatibility data, not as the long-term target.
- If Linux branch has editor improvements not in the laptop branch, port them
  into the shared Neovim/Vim-compatible layer.
- Do not create a Linux-only editor behavior unless it depends on Linux-only
  external tooling.

### 4. Git

Files:

- `common/git/.gitconfig`
- `common/git/.gitignore_global`
- `common/git/commit-template.md`

Desired result:

- Commit template is shared.
- Git aliases are shared.
- GitHub HTTPS-to-SSH rewrite can be shared if desired.
- Do not include machine-local Git trace2 socket config.

Conflict rule:

- Keep portable Git behavior in `common/git/.gitconfig`.
- Exclude local daemon endpoints and temporary experiments.

### 5. Terminal and Visual Identity

Files:

- `darwin/kitty.conf`
- `linux/common/kitty.conf`
- `common/themes/*.conf`
- `linux/arch/.config/sway/config`
- `linux/arch/.config/sway/assets/*`

Desired result:

- macOS keeps its own Kitty visual feel.
- jm-home-box keeps its pinkish Linux/Sway visual identity.
- Shared themes can remain in `common/themes`, but selection is platform or
  machine-specific.
- Do not force one visual theme onto all machines.

Conflict rule:

- Preserve Linux visual files from `fix/jm-home-box`.
- Preserve macOS visual files from `feature/personal-laptop-combined`.
- Only deduplicate purely identical theme assets.

### 6. Package Management

Files:

- `darwin/Brewfile`
- `linux/arch/packages.list`
- other Linux package lists
- `machines/jm-home-box/machine.toml`

Desired result:

- macOS packages stay in `darwin/Brewfile`.
- Arch packages stay in `linux/arch/packages.list`.
- Machine state stays in `machines/jm-home-box/machine.toml` or machine-state
  docs.
- Shared tool expectations are documented, not forced through one package file.

Tools that should exist on both where possible:

- `git`
- `nvim`
- `fzf`
- `ripgrep`
- `fd`
- `bat`
- `kitty`
- `rtk`
- `node`
- shellcheck-compatible shell scripts if available

Conflict rule:

- Do not remove Linux package changes from jm-home-box just because they do not
  appear in Brewfile.
- Do not add macOS casks to Linux package lists.

### 7. Installer

Files:

- `install.sh`
- `scripts/test-install.sh`
- `Makefile`

Desired result:

- One installer supports macOS, Linux, remote, container, and minimal modes.
- Installer uses copies only.
- Installer backs up targets before replacing.
- Installer writes audit logs.
- Installer copies shared config from `common/`.
- Installer copies platform-specific config from `darwin/` or `linux/` based on
  OS.
- Installer can eventually read machine metadata, but should not require it for
  normal install.

Conflict rule:

- Prefer the copy-only audited installer.
- Preserve Linux-specific install functionality if it exists, but adapt it to
  copy-only semantics.
- Never reintroduce stow/symlink behavior as default.

### 8. Scripts

Files:

- `scripts/*.sh`
- `scripts/*.py`

Desired result:

- Shared verification scripts stay in `scripts/`.
- Linux-only machine convergence scripts can stay under `scripts/` if named
  clearly, or move later under `machines/jm-home-box/scripts/`.
- Script names should make scope obvious.

Conflict rule:

- Keep scripts needed for current verification.
- Do not delete jm-home-box convergence tooling unless it is superseded and the
  replacement is tested.

## Ordered Merge Steps

1. Start from a clean worktree.
2. Fetch all remotes.
3. Create or choose a convergence branch from the intended future default base.
4. Merge `feature/personal-laptop-combined`.
5. Merge `origin/fix/jm-home-box`.
6. Resolve conflicts in this order:
   - Git config and commit template.
   - Shell entry points.
   - Shell functions.
   - Vim/Neovim.
   - Package lists.
   - Terminal/visual config.
   - Installer and Makefile.
   - Scripts.
7. After each conflict category, run the narrow checks for that category.
8. Run full verification before commit.
9. Commit the convergence with a detailed message.
10. Push the convergence branch and compare against both source branches.

## Verification Checklist

Required checks on macOS:

```bash
make check
make check-editor
zsh -n common/shell/.zshrc
bash -n common/shell/.bashrc
bash -n install.sh
git diff --check
```

Required checks on Linux:

```bash
make check
make check-editor
zsh -n common/shell/.zshrc
bash -n common/shell/.bashrc
bash -n install.sh
git diff --check
```

If `make check` does not exist on a source branch, use the closest available
checks and add/port `make check` during convergence.

Manual behavior checks:

```bash
source ~/.zshrc
type vim
which vim
which -a vim
vim --version
nvim --version
echo "$EDITOR"
echo "$VISUAL"
```

Expected behavior:

- `vim` is an alias to `nvim` when Neovim exists.
- `which vim` reports `nvim`.
- `which -a vim` shows alias result and system fallback if present.
- `EDITOR` and `VISUAL` prefer `nvim`.

Install checks:

- Installed files are regular files, not symlinks.
- Existing files are backed up.
- Backup paths preserve target structure.
- Audit log records mkdir, backup, remove, and copy actions.

## Human Decisions Needed

1. Should GitHub HTTPS-to-SSH rewrite be global for all machines?
2. Should `git-ai` PATH support remain shared, or move to an optional tool
   snippet?
3. Should jm-home-box convergence scripts remain in top-level `scripts/`, or
   move under `machines/jm-home-box/` later?
4. Should `.agents/` be added in this merge, or handled as a separate follow-up?
5. Should common themes remain in `common/themes`, or should theme selection be
   explicitly profile-driven?

## Recommended First Merge Strategy

Use `feature/personal-laptop-combined` as the practical base because it already
has:

- Recent copy-only installer behavior.
- Audit log and backup behavior.
- Neovim defaulting and editor parity checks.
- Current MacBook Brewfile and shell updates.

Then merge `origin/fix/jm-home-box` into it and preserve Linux-specific files
where they belong.

Expected conflict hotspots:

- `Makefile`
- `install.sh`
- `common/nvim/init.vim`
- `common/shell/.zshrc`
- `common/shell/.bashrc`
- `common/git/.gitconfig`
- `darwin/Brewfile`
- Linux package/state files
- Kitty/Sway visual files

Resolution principle:

> Shared tool behavior should converge. Platform and machine presentation
> should remain intentionally different.

## Final Success Criteria

The merge is successful when:

- A clean branch contains both source branches' useful work.
- MacBook install behavior remains unchanged or improved.
- jm-home-box Linux visuals and Sway setup are preserved.
- Neovim behavior is shared.
- Shell aliases/functions are consistent where portable.
- Installer is copy-only, backed up, and audited.
- The branch passes verification on at least one Mac and one Linux machine.
- Any remaining platform-only differences are documented and intentional.
