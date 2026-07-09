# Git Hooks

These are personal, global Git hooks installed through `core.hooksPath`.

## Behavior

- `pre-commit`
  - preserves repo-local `.husky/pre-commit`, `.githooks/pre-commit`, and `.git/hooks/pre-commit.local`;
  - blocks likely secret files;
  - blocks large staged files over 10 MiB by default;
  - blocks conflict markers;
  - blocks generated-looking files unless `JM_ALLOW_GENERATED_EDITS=1`.

- `pre-push`
  - preserves repo-local `.husky/pre-push`, `.githooks/pre-push`, and `.git/hooks/pre-push.local`;
  - runs `git config jm.hooks.prePushCommand` when set;
  - runs `scripts/pre-push-check` when executable;
  - can auto-run `make check`, package `ci`, package `check`, or package `test` when `JM_GIT_HOOKS_AUTO_PRE_PUSH=1`.

## Escapes

- Disable all personal hooks for one command: `JM_GIT_HOOKS=0 git commit ...`
- Alternate skip flag: `SKIP_JM_HOOKS=1 git commit ...`
- Allow intentional generated output: `JM_ALLOW_GENERATED_EDITS=1 git commit ...`
- Adjust large file limit: `JM_GIT_HOOKS_MAX_BYTES=20971520 git commit ...`

## Repo-specific checks

Prefer an explicit local command:

```bash
git config jm.hooks.prePushCommand "make check"
```

Or add an executable script:

```bash
scripts/pre-push-check
```
