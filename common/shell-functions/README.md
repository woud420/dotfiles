# Shell Functions & Aliases

Sourced by both bash and zsh from `~/.config/shell-functions/` (the installer
copies every `*.sh` file here).

## Active

| File | Purpose |
|------|---------|
| `editor.sh` | `vi`/`vim`/`vimdiff` and `EDITOR`/`VISUAL` use Neovim when available |
| `which.sh` | Shell-aware `which` that also reports aliases and functions |
| `sudo.sh` | Exports `SUDO_ASKPASS` (rofi GUI prompt via `sudo -A`) when the helper is installed |
| `macos-clipboard.sh` | `pbcopy`/`pbpaste` parity on Linux (wl-clipboard) |
| `kubectl-aliases.sh` | `k` alias for kubectl (`kctx` lives in the shell rc files) |

## Disabled stubs

The remaining files are deliberately kept as ~90-byte disabled stubs so they
can be restored incrementally without breaking installs:

`git.sh`, `git-aliases.sh`, `docker.sh`, `docker-aliases.sh`, `k8s.sh`,
`ssh.sh`, `utils.sh`, `fuzzy-vim.sh`, `modern-tools-aliases.sh`,
`secrets.sh`, `system-aliases.sh`

Restoring one means replacing the stub's body and confirming `bash -n` and
`zsh -n` pass (CI runs ShellCheck at error severity over this directory).
