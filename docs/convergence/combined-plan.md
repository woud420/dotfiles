> **Status (2026-07):** historical/archived. This is the negotiated two-agent
> plan that the convergence executed; the decisions that superseded parts of it
> are listed in the status header of `docs/machine-convergence-plan.md`. The
> planned backup-restore deliverable was descoped - restores are manual from
> the path-preserving `~/.dotfiles-backup-*` directories using the audit log.

# Combined Dotfiles Convergence Plan

## Agreement

Codex and Claude agree on the convergence model:

> Shared tooling behavior should converge in common config. Platform and machine
> presentation should remain intentionally different.

The merged dotfiles repo should work for the macOS MacBook Pro, the Linux
`jm-home-box`, and future machines without forcing one machine's visual identity
onto another.

## Source Branches

- `feature/personal-laptop-combined`: current macOS laptop branch. Treat as
  authoritative for recent macOS package state, copy-only installer behavior,
  Neovim defaulting, shell updates, and test additions.
- `origin/fix/jm-home-box`: current Linux `jm-home-box` branch. Treat as
  authoritative for Arch/Linux package state, Sway/SwayFX visuals, Linux machine
  state, and Linux convergence tooling.
- `feature/ai-context`: inspect as an input for machine-state and AI-context
  infrastructure. Bring forward useful structure if it fits the final
  `machines/` model.
- `feature/add-linux-box`: historical Linux input only. Use for context if a
  file exists there that explains a current Linux choice.

## Core Rules

1. Shared behavior lives in `common/`.
2. macOS-specific configuration lives in `darwin/`.
3. Linux-specific configuration lives in `linux/`.
4. Machine facts and selected profiles live in `machines/<machine>/`.
5. Visual identity remains platform or machine specific.
6. Installer behavior must use regular copied files, not symlinks.
7. Installer behavior must preserve path-aware backups and an audit log.
8. Neovim is the target editor when available.
9. `vi`, `vim`, and `vimdiff` should use Neovim when available.
10. `EDITOR` and `VISUAL` should prefer `nvim` when available.
11. `which` should be shell-aware and should see aliases. Do not alias `which`
    to `gwhich`.
12. Do not copy local daemon sockets, local runtime state, or installer comments
    into shared dotfiles.
13. Do not create a MacBook machine profile unless there are true machine facts
    that cannot live in `darwin/` or `common/`.
14. Current installed state on the MacBook Pro and `jm-home-box` is part of the
    source of truth. Capture and classify that state before merging branches or
    applying installs.

## Proposed Final Layout

```text
.
├── common/
│   ├── bin/
│   │   └── dotfiles
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
│   ├── ssh/
│   └── themes/
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

Potential later addition:

```text
.agents/
├── AGENTS.md
├── RTK.md
└── skills/
```

Agent behavior should be shared by default. Do not add machine-specific
`AGENTS.md` files unless a machine truly needs different agent operating rules.

## Merge Strategy

Use `feature/personal-laptop-combined` as the practical base because it already
contains the current copy-only installer, audit/test behavior, Neovim defaulting,
and macOS state.

Then merge `origin/fix/jm-home-box` and preserve Linux-specific files in their
proper layer.

### Phase 0: Capture Current Installed State

Before merging or applying anything, capture current reality on both machines in
read-only mode.

MacBook Pro snapshot:

- Current dotfiles repo branch, status, remotes, and recent log.
- Managed file checksums and file types.
- Symlink-vs-regular-file audit for managed targets.
- Current Homebrew bundle dump.
- Shell/editor behavior: `type vim`, `which vim`, `which -a vim`, `EDITOR`,
  `VISUAL`, `vim --version`, and `nvim --version`.
- Local-only drift such as `git-ai` PATH edits or Git trace2 sockets.

`jm-home-box` snapshot:

- Current dotfiles repo branch, status, remotes, and recent log.
- Managed file checksums and file types.
- Symlink-vs-regular-file audit for managed targets.
- Current Arch package state or package list.
- Shell/editor behavior: `type vim`, `which vim`, `which -a vim`, `EDITOR`,
  `VISUAL`, `vim --version`, and `nvim --version`.
- Machine-state files.
- Sway, SwayFX, Kitty, theme, and visual state.
- Local-only drift and generated/runtime state.

Save snapshots outside the repo working tree under timestamped paths, for
example:

```text
/private/tmp/dotfiles-state-<timestamp>/
~/convo/dotfiles/state-<timestamp>/
```

Classify every observed drift item before merge work:

- Shared behavior.
- Platform-specific config.
- Machine-specific facts or visuals.
- Local runtime state.
- Stale/generated artifact.
- Needs human decision.

Only after this classification should branch merging or installer testing begin.

Order of work:

1. Start from clean worktrees on both machines.
2. Capture current installed state on both machines.
3. Classify drift before editing.
4. Fetch all remotes.
5. Create a convergence branch from `feature/personal-laptop-combined`.
6. Inspect `feature/ai-context` for reusable machine-state structure.
7. Merge `origin/fix/jm-home-box`.
8. Resolve conflicts by category, not by blindly picking one side.
9. Run narrow verification after each category.
10. Run full verification on macOS and Linux.
11. Commit the convergence.
12. Push the convergence branch for review.

## Conflict Resolution Rules

### Shared Shell

Files:

- `common/shell/.zshrc`
- `common/shell/.bashrc`
- `common/shell/.bash_profile`
- `common/shell/.bashrc.server`
- `common/shell/.gnu_aliases`
- `common/shell-functions/*.sh`

Keep:

- Guarded portable PATH logic.
- `rtk` conventions where installed.
- `~/.git-ai/bin` only as guarded PATH support, not installer comments.
- `PROMPT_EOL_MARK=''`.
- Shared aliases/functions where the underlying tools exist on both platforms.
- `editor.sh` for `nvim` defaulting.
- `which.sh` for shell-aware lookup.

Avoid:

- Hardcoded local daemon paths.
- Platform package-manager aliases that are not guarded.
- Reintroducing `which -> gwhich`.

### Editor

Files:

- `.vim/vimrc`
- `.vim/plugins.vim`
- `.vim/mappings.vim`
- `.vim/settings/*.vim`
- `.vim/coc-settings.json`
- `common/nvim/init.vim`
- `scripts/check-editor-parity.sh`
- `scripts/editor-parity.vim`

Make Vim-to-Neovim audit a named step:

1. Compare Vim and Neovim config entry points.
2. Inventory plugins in `.vim/plugins.vim`.
3. Inventory mappings in `.vim/mappings.vim` and `.vim/settings/keybindings.vim`.
4. Inventory settings in `.vim/settings/*.vim`.
5. Guard Vim-only settings so Neovim loads cleanly.
6. Confirm keybindings and editor behavior are identical across machines.
7. Run editor parity checks.

Neovim is the target editor. Vim config may remain as compatibility/source
material, but new shared editor behavior should converge toward Neovim.

### Git

Files:

- `common/git/.gitconfig`
- `common/git/.gitignore_global`
- `common/git/commit-template.md`

Keep:

- Commit template.
- Shared Git aliases.
- Portable GitHub HTTPS-to-SSH rewrite if the user wants that globally.

Exclude:

- Local Git trace2 daemon socket paths.
- Machine-local Git runtime state.

### Terminal and Visuals

Files:

- `darwin/kitty.conf`
- `linux/common/kitty.conf`
- `common/themes/*.conf`
- `linux/arch/.config/sway/config`
- `linux/arch/.config/sway/assets/*`

Keep:

- macOS Kitty visual identity in `darwin/`.
- Linux pinkish Sway/SwayFX identity in `linux/` and `machines/jm-home-box/`.
- Shared themes only when they are genuinely reusable assets.

Avoid:

- Making Linux look like macOS.
- Making macOS look like Linux.
- Moving visual choices into global shared config.

### Package Management

Files:

- `darwin/Brewfile`
- `linux/arch/packages.list`
- other Linux package lists
- `machines/jm-home-box/machine.toml`

Keep package files platform specific.

Tools expected to be aligned where possible:

- `git`
- `nvim`
- `fzf`
- `ripgrep`
- `fd`
- `bat`
- `kitty`
- `rtk`
- `node`

Do not add macOS casks to Linux package lists. Do not remove Linux packages just
because they do not exist in the Brewfile.

### Installer

Files:

- `install.sh`
- `Makefile`
- `scripts/test-install.sh`

Keep:

- Copy-only install behavior.
- No symlink default.
- Path-preserving backups.
- Audit log.
- Platform detection.
- Minimal/container/remote modes where supported.
- Tests proving no symlink install behavior.

If jm-home-box has Linux-specific install logic, preserve the behavior but adapt
it to copy-only semantics.

### Scripts

Create a script classification table during the merge.

Categories:

- Shared-safe.
- macOS-only.
- Linux-only.
- `jm-home-box` specific.
- Obsolete/superseded.
- Needs review.

Do not move scripts solely for tidiness in the first convergence. Move scripts
only when needed to prevent wrong-machine execution or to make machine scope
explicit.

Include `common/bin/dotfiles` in the inventory and classify it as either a shared
helper or a machine-convergence helper.

### Skills and Agents

Inspect:

- `.agents/skills/`
- `.claude/skills/`
- any symlink or copy relationship between them

Classify skills as:

- Shared default behavior.
- Platform specific.
- Machine specific.
- Experimental.

Do not add machine-specific `AGENTS.md` files by default. Machine specs should
describe facts and roles, not agent behavior.

## Required Verification

Run on macOS:

```bash
make check
make check-editor
zsh -n common/shell/.zshrc
bash -n common/shell/.bashrc
bash -n install.sh
git diff --check
```

Run on Linux:

```bash
make check
make check-editor
zsh -n common/shell/.zshrc
bash -n common/shell/.bashrc
bash -n install.sh
git diff --check
```

If a source branch lacks `make check`, use the closest available checks and add
or port the shared `make check` target during convergence.

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

Expected:

- `vim` is an alias to `nvim` when Neovim exists.
- `which vim` reports `nvim`.
- `which -a vim` shows the alias result and system fallback if present.
- `EDITOR` and `VISUAL` prefer `nvim`.

Install checks:

- Installed files are regular files.
- Installed files are not symlinks.
- Existing files are backed up before replacement.
- Backup paths preserve target structure.
- Audit log records mkdir, backup, remove, and copy actions.

## Open Decisions

1. Should GitHub HTTPS-to-SSH rewrite be global for all machines?
2. Should `git-ai` PATH support remain shared or move to an optional tool
   snippet?
3. Should jm-home-box convergence scripts remain in top-level `scripts/`, or
   move under `machines/jm-home-box/` later?
4. Should `.agents/` be added as part of this convergence, or handled as a
   follow-up?
5. Should theme selection become explicitly profile-driven, while keeping
   current visual files in place?

## Success Criteria

The convergence is complete when:

- The convergence branch contains useful work from both source branches.
- Current installed state was captured on both machines before merge/install
  work.
- Observed drift was classified as shared behavior, platform config, machine
  facts/visuals, local runtime state, stale/generated artifact, or human
  decision.
- MacBook command-line behavior remains consistent with current laptop branch.
- jm-home-box Linux visuals and Sway/SwayFX setup are preserved.
- Neovim behavior is shared.
- Shell aliases/functions are consistent where portable.
- Installer remains copy-only, backed up, and audited.
- Scripts are classified by scope.
- Skills/agents are inventoried if present.
- Verification passes on macOS and Linux.
- Remaining platform-only differences are documented and intentional.
