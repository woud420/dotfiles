# Customization

## Local overrides

Keep machine-specific settings in files outside the repository:

| Local file | Use |
| --- | --- |
| `~/.bashrc.local` | Bash-only exports, paths, aliases, and functions; sourced at the end |
| `~/.zshrc.local` | Zsh-only exports, paths, aliases, and functions; sourced at the end |
| `~/.gitconfig.local` | Git identity, credential helpers, and machine/tool policy; included last |
| `~/.ssh/config` | Machine host entries and identity-file paths |

Example Git identity in `~/.gitconfig.local`:

```gitconfig
[user]
    name = Your Name
    email = <your-email-address>
```

An include that appears later can override scalar Git settings; multivalued
settings such as credential helpers may need an explicit reset before a local
replacement. Keep credentials and machine socket paths out of shared config.

SSH has different precedence: the installer prepends
`Include ~/.ssh/config.dotfiles`, and OpenSSH keeps the first scalar value it
reads. A later local `Host` block cannot override a shared scalar already set
for that host. Change shared defaults in [`common/ssh/config`](../../common/ssh/config)
when that policy should change across machines.

## Shared shell behavior

Edit shell startup and prompts in [`common/shell/`](../../common/shell/) and
modules in [`common/shell-functions/`](../../common/shell-functions/README.md).
Several modules are intentionally disabled stubs; adding an implementation
requires checking both Bash and Zsh rather than assuming every filename is active.

## Editors

Edit shared mappings, plugins, and settings under [`.vim/`](../../.vim/).
[`common/nvim/init.vim`](../../common/nvim/init.vim) loads that configuration
instead of maintaining a separate mapping set. The installer copies CoC settings
to both editors. Follow the [editor validation procedure](validation.md#editor-changes)
after changing behavior.

## Personal Git hooks

The shared `.gitconfig` sets `core.hooksPath = ~/.config/git/hooks`.
The hooks delegate to supported repo hooks first. Pre-commit then checks likely
secrets, conflict markers, oversized files, and generated-looking files; common
lockfiles are allowlisted. Pre-push can run a configured repository check.

```bash
git config jm.hooks.prePushCommand "make check"
git config jm.hooks.runRepoHooks false
JM_GIT_HOOKS=0 git commit ...
JM_ALLOW_GENERATED_EDITS=1 git commit ...
```

The second command disables repo-controlled hook delegation in an untrusted clone.
The last two are one-command overrides. See the
[hook reference](../../common/git/hooks/README.md) for delegated hook paths,
size limits, and other switches.

`make install-git-hooks` copies only the hooks and sets the global hooks path.
That direct Make target does not use the installer's backup/audit workflow;
use the regular installer when that protection is needed.

## Themes and platform configuration

macOS Kitty configuration lives in [`darwin/kitty.conf`](../../darwin/kitty.conf);
Linux uses [`linux/common/kitty.conf`](../../linux/common/kitty.conf).
Shared named themes live in [`common/themes/`](../../common/themes/).
Arch's selected theme is an overlay under
[`linux/arch/.config/kitty/`](../../linux/arch/.config/kitty/).

Make shared changes in `common/` and platform changes in `darwin/` or `linux/`.
Live files are copies: edit repository sources when a change should survive
reinstallation, preview the relevant mode, and validate before applying it.
Use local overrides for differences that should stay on one machine.
