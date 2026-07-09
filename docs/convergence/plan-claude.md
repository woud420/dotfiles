# Dotfiles Unification Research Prompt

You are analyzing a dotfiles repository (~/workspace/dotfiles) to produce a
concrete merge plan. The goal: one coherent dotfiles setup that works across
two machine classes — a Linux Arch desktop (jm-home-box, pinkish/swayfx
aesthetic) and a macOS MBP (personal-laptop-combined, its own visual identity)
— while sharing everything that should be shared.

## Branches to analyze (in rough chronological order, newest = ground truth)

- master                           — baseline
- feature/add-linux-box            — early Arch config attempt
- feature/ai-context               — AI context file infra
- feature/personal-laptop          — MBP snapshot (older)
- feature/personal-laptop-combined — MBP current state (ground truth for mac)
- fix/jm-home-box                  — Linux box current state (ground truth for linux)

For each branch, read the following files if they exist and note what's in them:
  - common/shell/.zshrc, common/shell/.bashrc
  - common/shell-functions/*.sh  (all of them)
  - common/nvim/init.vim, .vim/vimrc
  - .vim/settings/keybindings.vim, .vim/mappings.vim
  - .vim/plugins.vim
  - config/kitty.conf, darwin/kitty.conf, linux/common/kitty.conf
  - linux/arch/.config/sway/config
  - darwin/Brewfile
  - linux/arch/packages.list
  - machines/jm-home-box/machine.toml
  - install.sh
  - Makefile
  - scripts/*.sh, scripts/*.py
  - .agents/skills/ or .claude/skills/ (if present)
  - common/git/.gitconfig

## What to extract per file category

**Shell (aliases + functions)**
- List every alias and function defined in each branch's shell-functions/
- Flag: exists on both? Linux-only? Mac-only? Diverged (same name, different impl)?

**Editor (vim → nvim migration)**
- The user wants to move fully to nvim. Compare .vim/vimrc vs common/nvim/init.vim
  across branches. What plugins, keybindings, and settings exist in vim that
  are NOT yet in nvim? What's already been ported?
- Identify the full keybinding set from .vim/settings/keybindings.vim and
  .vim/mappings.vim on both branches. The goal is these must be identical in nvim
  across both machines.

**Terminal / visual**
- Note what theme/colors each branch uses for kitty. Do NOT propose changing them.
- Note what's sway-specific (Linux only) vs what's kitty config that could be shared.

**Scripts**
- List every script in scripts/ across branches. Classify: shared-safe, linux-only,
  mac-only, or obsolete/superseded.

**Skills**
- List any agent skills found. Classify: machine-agnostic, linux-only, mac-only.

**Package management**
- darwin/Brewfile (mac), linux/arch/packages.list and machines/jm-home-box/machine.toml (linux)
- Identify tools present on both that should be kept in sync (same version
  expectations, same purpose — e.g. fzf, ripgrep, git, nvim, kitty).

**Install script**
- Compare install.sh across branches. What does it do on each? Does it handle
  both platforms or is it platform-specific?

## Constraints to respect

1. Do not touch visual/color config (kitty themes, sway colors, pink aesthetic on linux).
2. nvim is the target editor. vim config should be read for what needs porting, not preserved.
3. Keybindings in nvim must be identical on both machines.
4. Aliases must be identical where the underlying tool exists on both platforms.
   Where a tool is platform-specific (e.g. brew, pacman, sway), the alias is
   machine-scoped — note it but don't try to unify it.
5. The common/ directory is the right place for shared config.
   darwin/ and linux/ are the right place for platform-specific config.

## Output format

Produce a structured merge plan with these sections:

### 1. Branch timeline summary
What changed when, which branch is newest/authoritative per area.

### 2. Shared config inventory
Table: file/category | linux state | mac state | diverged? | merge action

### 3. vim → nvim porting gaps
Exact list of keybindings, plugins, and settings in vim that aren't in nvim yet.

### 4. File layout proposal
Proposed final directory structure showing where each config lives
(common/ vs darwin/ vs linux/arch/ vs machines/).

### 5. Ordered merge steps
Concrete sequence: what to merge first (low-risk shared shell functions),
what to do last (install.sh unification). Flag anything that needs a human
decision before proceeding.

### 6. Open questions for the user
Anything ambiguous — tools that exist on one machine but not the other,
diverged aliases with different semantics, skills that could go either way.
