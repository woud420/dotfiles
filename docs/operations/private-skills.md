# Private skills

`private/skills` is a Git submodule pinned to a commit in the private
`woud420/skills` repository. The parent repository tracks its SSH URL and commit
ID, not the private contents or credentials.

## Initialize the pinned revision

GitHub SSH access and Python 3 are required to install skills.

```bash
git submodule update --init --checkout -- private/skills
git submodule status -- private/skills
```

If access is unavailable and skills should be skipped explicitly:

```bash
DOTFILES_SKIP_PRIVATE_SKILLS=1 ./install.sh --dry-run
DOTFILES_SKIP_PRIVATE_SKILLS=1 ./install.sh
```

Public CI sets the same variable and never requests private credentials.

## Selection and destinations

| Installation | Selected skills | Destinations |
| --- | --- | --- |
| Full, including `--no-packages` | Manifest `active` and `maintenance` entries | `~/.agents/skills/`, plus Claude's `skills/` directory when `claude` is on `PATH` |
| `--preserve-existing` | Active and maintenance, plus registered candidates already installed at each destination | `~/.agents/skills/` and both assistants' `skills/` directories, regardless of CLI availability |
| Minimal | Skipped | None |

Claude's skills directory defaults to `~/.claude/skills/` and moves to
`$CLAUDE_CONFIG_DIR/skills/` when configured. A full install uses one copy
when Claude's skills directory already resolves to `~/.agents/skills/`.
The Codex-specific directory defaults to `~/.codex/skills/` and moves to
`$CODEX_HOME/skills/` when configured.

Only Git-tracked files in selected skill directories are copied. Untracked files
and repository metadata are excluded. Target-only files and unrelated installed
skills remain. Changed managed files are backed up. Invalid manifests, missing
tracked sources, and unsafe destination parents prevent skill copying.

The installer uses the checked-out revision, without fetching a newer remote
commit. Initialize before previewing to see the actual selected file set.

## Update intentionally

Advance the submodule separately from installing into live skill directories:

```bash
git submodule update --remote --checkout -- private/skills
git diff --submodule=log -- private/skills
```

Review the skillpack changes and run its own validation, then run the dotfiles
[repository checks](validation.md). Preview the chosen installation mode before
applying it. Stage `private/skills` only when intentionally recording that new
pin in a parent-repository commit.

`--check` compares the destinations selected for a full install against the
checked-out skillpack. A Codex-specific copy from a preserving install is
outside that check.
