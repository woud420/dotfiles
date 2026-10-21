# Machine convergence

Status: accepted; the outcomes below describe the current repository structure.
They do not certify installation or behavior on any particular live machine.

## Context

The macOS laptop and Arch desktop evolved on separate branches. They needed
shared command-line behavior without losing platform-specific packages or
the desktop's visual identity. Earlier proposals included a Python installer,
per-machine directories, and an automatic restore command.

## Decision and consequences

| Choice | Reason and consequence |
| --- | --- |
| Shared behavior in `common/`, with `darwin/` and `linux/` adapters | Shell/editor/Git behavior can evolve together while platform configuration remains explicit |
| `install.sh` as the main installer | One entry point owns OS selection, copying, backups, drift checks, and dependency checks; the former Python workflow is retired |
| Copied configuration, with path-preserving backups and an audit log | Live files are independent of checkout paths; updates require installation and live edits can drift |
| Neovim loads the shared Vimscript configuration | Mappings, settings, and plugins share a source rather than requiring two independent editor configurations |
| Arch-specific Kitty and desktop styling | The personal-pink overlay stays in the Arch layer; shared themes remain available elsewhere |
| Local shell/Git overrides and local SSH host entries | Machine identity and runtime details stay outside shared files; SSH's first-value precedence still applies |
| Manual file restoration | Backups and the audit log support recovery; there is no automatic restore target or full package/schedule rollback |

The old `machines/<hostname>/` model and `scripts/dotfiles.py` are not part of
the current layout. Later preserving-mode behavior is documented in the
[installer contract](../contracts/installer.md#preserving-an-existing-setup).

## Historical context

These records retain the exploration and superseded proposals:

- [Initial scope](machine-convergence/initial-scope.md).
- [Research brief](machine-convergence/research-brief.md).
- [Merge proposal](machine-convergence/merge-proposal.md).
- [Planning discussion](machine-convergence/planning-discussion.md).
- [Negotiated merge plan](machine-convergence/merge-plan.md).
- [Terminal background proposal](machine-convergence/terminal-background-proposal.md).

For current structure, see [architecture](../architecture/README.md). For
installation and recovery, use [operations](../operations/README.md).
