# Dotfiles

Shell, editor, Git and terminal configuration that behaves the same on macOS
and Linux. Shared files live in `common/`; `darwin/` and `linux/` add each
platform's packages and desktop.

```bash
git clone https://github.com/woud420/dotfiles.git
cd dotfiles
./install.sh --dry-run   # preview
./install.sh             # apply
./install.sh --check     # compare installed files with the repo
./install.sh --doctor    # check required tools
```

## Guides

- [Installation](docs/operations/installation.md): modes, prerequisites and platform notes
- [Customization](docs/operations/customization.md): local overrides, Git hooks and themes
- [Private skills](docs/operations/private-skills.md): the pinned agent skillpack
- [Maintenance](docs/operations/maintenance.md): drift, backups and recovery
- [Validation](docs/operations/validation.md): checks to run before a change
- [Arch desktop](docs/operations/arch-desktop.md): SwayFX, Waybar and Firefox

Everything else is indexed in [docs](docs/README.md).
