# Terminal background proposal — jm-home-box

## Color recommendation

`#181420` — a deep pink-leaning mantle.

Why this over the current `#000000`:

- Pure black is harsh and flattens the `background_opacity 0.95` nuance in `linux/common/kitty.conf`.
- It clashes with the Catppuccin Mocha pastel accents already in `common/themes/current-theme.conf`:
  - rosewater cursor `#F5E0DC`
  - mauve active tab `#CBA6F7`
  - pink `#F5C2E7`
- `#181420` is essentially Catppuccin's `mantle` (`#181825`) nudged warm/rose to match the `style = "personal-pink"` identity declared in `machines/jm-home-box/machine.toml`.
- Stays clearly distinct from the `#11111B` tab bar so panel layering still reads.

## Alternatives

| Hex       | Feel                                                                |
| --------- | ------------------------------------------------------------------- |
| `#1E1825` | Warmer base, brighter — closest to original Mocha brightness        |
| `#15101A` | More dramatic, deeper warm-rose dark                                |
| `#11111B` | Catppuccin crust — official deepest, but merges into the tab bar    |

## Machine-only scope plan

The current installer (`scripts/dotfiles.py`) copies `common/themes/*.conf` to every machine — no override path exists.

Proposed change:

1. Add `machines/jm-home-box/themes/current-theme.conf` containing the warm-rose background override.
2. In `scripts/dotfiles.py`, after the existing `add_glob(entries, "common/themes/*.conf", "~/.config/kitty", "kitty")`, add a gated copy of `machines/<name>/themes/*.conf` so machine-specific themes win.
3. Revert the uncommitted `#000000` edit in:
   - `common/themes/current-theme.conf`
   - `config/current-theme.conf` (stale mirror, unused by current installer)
   so the upstream Mocha background is restored for any other machine.

## Tradeoff

Adds a small piece of machinery to the installer (one `add_glob` call gated on the directory existing) — minor scope creep, but it's the right hook for the per-machine deltas the convergence plan in `docs/machine-convergence-plan.md` already anticipates ("machine identity" classification).
