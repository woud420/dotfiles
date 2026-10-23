# Validation

Run commands from the repository root. Select checks for the files and behavior
being changed; local results do not establish that another machine or hosted CI
has passed.

## Installer changes

```bash
DOTFILES_SKIP_PRIVATE_SKILLS=1 make check
```

[`make check`](../../Makefile) runs both installer test programs and syntax-checks
the installer, editor-check script, shell smoke test, and plugin updater.
[`scripts/test-install.sh`](../../scripts/test-install.sh) uses temporary home
directories to exercise copying, backups, drift detection, and legacy symlink
handling. [`scripts/test-preserve-existing.py`](../../scripts/test-preserve-existing.py)
covers the preserving mode with temporary-home fixtures.

The skip variable keeps public validation independent of private credentials.
It does not validate the real private skillpack's contents. If skill selection or
syncing changes, also validate the checked-out skillpack and relevant destination
cases without changing the real home directory.

Use the system interpreter on macOS when checking Bash 3.2 compatibility:

```bash
DOTFILES_SKIP_PRIVATE_SKILLS=1 /bin/bash scripts/test-install.sh
```

## Shell changes

```bash
bash -n common/shell/.bashrc
bash -n common/shell/.bashrc.server
zsh -n common/shell/.zshrc
```

For a changed shared module, syntax-check that file under both Bash and Zsh.
CI also runs ShellCheck at error severity over `common/shell-functions/`.
Syntax checks do not prove an alias or function's runtime behavior; exercise the
changed command in an isolated shell when its behavior changes.

## Editor changes

```bash
make check-editor
```

This requires both Vim and Neovim plus installed configuration under the selected
`HOME`. The [script](../../scripts/check-editor-parity.sh) loads both editors
against `scripts/editor-parity.vim` and compares their CoC settings, and fails
when a `~/.vimrc` exists because Vim would skip `~/.vim/vimrc`.
For plugin and language-server health in Neovim, use
`:checkhealth nvim-treesitter coc`.
Use a prepared temporary home when validating without a live installation;
the check does not create the editor configuration for you.

## Documentation changes

- Resolve relative file links and heading anchors, including platform README links.
- Check documented installer options against `./install.sh --help`, and Make
  commands against `make help` and the actual target definitions.
- Check behavior against implementation; help text alone does not establish the
  side effects of a mode.
- Keep current guidance in architecture/contracts/operations and mark historical
  records clearly. Update incoming links when moving a document.
- Run `git diff --check` and review the documentation diff.

## CI coverage

The [install workflow](../../.github/workflows/test-install.yml) runs shell syntax,
ShellCheck, Git-config/JSON parsing, and temporary-home installer tests. It also
has Arch and Debian container jobs and a macOS job, checking deployed copies and
platform/editor configuration. The macOS job also installs Neovim, fzf and
tree-sitter-cli with Homebrew, loads the Neovim config with its plugins, builds
two tree-sitter parsers, runs the editor parity script, and checks the zsh fzf
fallback under a pty.

Use an actual CI run for the tested revision before claiming hosted coverage.
These jobs validate fixtures and runner environments; visual checks and real
machine behavior still need direct verification on the target machine.
