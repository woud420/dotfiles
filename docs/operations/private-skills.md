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
| Full, including `--no-packages` | Manifest `active` and `maintenance` entries | `~/.agents/skills/` |
| `--preserve-existing` | Active and maintenance; registered candidates already installed at each destination | `~/.agents/skills/`, `~/.codex/skills/`, `~/.claude/skills/` |
| Minimal | Skipped | None |

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

`--preserve-existing` refreshes all three destinations above. A regular
`--check` checks managed skills in `~/.agents/skills`; it does not certify the
Codex/Claude copies or check that the pin is the latest remote revision.
