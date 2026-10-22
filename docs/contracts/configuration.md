# Configuration

These paths describe regular installation. Some are skipped in minimal mode;
preserving mode has its own limited [scope](installer.md#preserving-an-existing-setup).
[`install.sh`](../../install.sh) is the source of truth for selection.

## Managed paths

| Repository source | Destination | Notes |
| --- | --- | --- |
| `common/shell/.bashrc`, `.zshrc`, `.bash_profile` | `~/.bashrc`, `~/.zshrc`, `~/.bash_profile` | Interactive shell setup |
| `common/shell/.bashrc.server` | `~/.bashrc` | Server Bash in minimal mode |
| `common/shell/.gnu_aliases`, `.dircolors` | `~/.gnu_aliases`, `~/.dircolors` | GNU aliases and colors |
| `common/shell-functions/*.sh` | `~/.config/shell-functions/` | Shared modules, including disabled stubs |
| `common/git/.gitconfig` | `~/.gitconfig` | Aliases, hooks path, commit template, local include, and shared Git policy |
| `common/git/.gitignore_global` | `~/.config/git/ignore` | Global ignores |
| `common/git/commit-template.md` | `~/.config/git/commit-template.md` | Commit template |
| `common/git/hooks/*`, excluding its README | `~/.config/git/hooks/` | Global pre-commit/pre-push hooks |
| `common/ssh/config` | `~/.ssh/config.dotfiles` | Included from local `~/.ssh/config` |
| `darwin/kitty.conf` or `linux/common/kitty.conf` | `~/.config/kitty/kitty.conf` | Selected by OS |
| `common/themes/*.conf` | `~/.config/kitty/` | Shared themes |
| `linux/arch/.config/kitty/*.conf` | `~/.config/kitty/` | Arch theme overrides |
| `common/htop/htoprc` | `~/.config/htop/htoprc` | htop settings |
| `.vim/` configuration files and `settings/*.vim` | `~/.vim/` | Vimscript, mappings, plugins, and CoC JSON |
| (none) | `~/.vimrc` | Backed up and removed: Vim ignores `~/.vim/vimrc` while any `~/.vimrc` exists |
| `common/nvim/init.vim` | `~/.config/nvim/init.vim` | Loads `~/.vim/vimrc` |
| `.vim/coc-settings.json` | `~/.config/nvim/coc-settings.json` | CoC settings shared with Vim |
| `scripts/sudo-askpass.sh`, `scripts/vim-plug-update.sh` | `~/.local/bin/sudo-askpass`, `~/.local/bin/vim-plug-update` | GUI sudo helper and plugin updater |
| `darwin/launchd/com.woud420.vim-plug-update.plist` | `~/Library/LaunchAgents/` | macOS weekly plugin schedule |
| `linux/common/systemd/vim-plug-update.{service,timer}` | `~/.config/systemd/user/` | Linux schedule when systemctl is available |
| Tracked files in `linux/arch/.config/` | Matching paths under `~/.config/` | Arch desktop, full mode only |
| `linux/arch/firefox/` theme/settings files | Selected Firefox profile | Arch, with an existing profile |
| `common/ai-context/AGENTS.md` | `~/AGENTS.md` | Shared agent instructions |
| Platform `ai-context/machine.md` | `~/MACHINE.md` | Platform machine context |
| `common/ai-context/CLAUDE.md` | `~/.claude/CLAUDE.md` | Seeds a missing file; retains customized content |
| Selected Git-tracked files in `private/skills/` | `~/.agents/skills/` | See [private skills](../operations/private-skills.md) for preserving-mode destinations |

## Shell commands

The interactive shell configs source `~/.config/shell-functions/*.sh` and then
their local overrides. The [module index](../../common/shell-functions/README.md)
distinguishes active modules from deliberately disabled stubs.

| Command | Behavior | Dependency |
| --- | --- | --- |
| `vi`, `vim`, `vimdiff` | Prefer Neovim; `vimdiff` uses `nvim -d` | Neovim, with Vim fallback |
| `which` | Reports shell aliases/functions as well as executables | Shared lookup module |
| `git ch` | Fuzzy branch checkout with preview | Git and fzf |
| `git flog` | Interactive commit browser | Git and fzf |
| `git fadd` | Interactive staging with diff preview | Git and fzf |
| `git llog` | Fuzzy history search | Git and fzf |
| `git st`, `git cm`, `git lg` | Status, commit, and graph log shortcuts | Git |
| `k`, `kctx` | kubectl shortcut and fuzzy context selection | kubectl; fzf for `kctx` |
| `pbcopy`, `pbpaste` on Linux | Clipboard parity through wl-clipboard | `wl-copy`, `wl-paste` |
| `Ctrl-R`, `Ctrl-T`, `Alt-C` | fzf history search, file picker, and directory jump in Bash and Zsh | fzf 0.48+ (`fzf --zsh`, `fzf --bash`) or `~/.fzf.*` from the git installer |
| `ls`, `grep` | Colored output with the shared dircolors palette in both shells | GNU coreutils; `gls`/`gdircolors` on macOS |
| `sudo -A` | Uses the installed askpass helper when configured | Helper and a supported GUI prompt tool |

`EDITOR` and `VISUAL` prefer Neovim when it is available. Both editors use
shared Vimscript settings and `~/.vim/plugged`; Neovim reads its CoC JSON from
`~/.config/nvim/`. Neovim adds tree-sitter highlighting and indentation through
nvim-treesitter's `main` branch, which needs `tree-sitter-cli` plus a C
compiler to build parsers under `~/.local/share/nvim/site/`; without the CLI the
regex syntax files keep highlighting. CoC format-on-save for Python calls
`black`, and linting calls `ruff`; both come from the platform package lists.

## Local ownership

`.bashrc.local`, `.zshrc.local`, and `.gitconfig.local` are local extension points.
The local SSH file retains machine host entries and identity paths, but its
prepended shared Include affects precedence. See
[customization](../operations/customization.md) before changing defaults.

Package inventories remain in [`darwin/Brewfile`](../../darwin/Brewfile) and
`linux/<distro>/packages.list`; Arch also has
[`packages-aur.list`](../../linux/arch/packages-aur.list). These files define
requested packages without duplicating their inventories in the README.
