# Arch desktop

The Arch/Manjaro layer adds a SwayFX desktop to the shared shell/editor setup.
Its configuration lives in [`linux/arch/`](../../linux/arch/).

## Components

| Component | Repository configuration |
| --- | --- |
| SwayFX | [`linux/arch/.config/sway/`](../../linux/arch/.config/sway/) |
| Waybar and custom monitoring modules | [`linux/arch/.config/waybar/`](../../linux/arch/.config/waybar/) |
| Rofi | [`linux/arch/.config/rofi/`](../../linux/arch/.config/rofi/) |
| Mako | [`linux/arch/.config/mako/`](../../linux/arch/.config/mako/) |
| GTK | [`gtk-3.0/`](../../linux/arch/.config/gtk-3.0/) and [`gtk-4.0/`](../../linux/arch/.config/gtk-4.0/) |
| Kitty | [`linux/common/kitty.conf`](../../linux/common/kitty.conf) plus the [Arch theme overlay](../../linux/arch/.config/kitty/) |
| Firefox | [`linux/arch/firefox/`](../../linux/arch/firefox/) |

The desktop uses a purple/pink palette and FiraCode Nerd Font. The Kitty overlay
uses the personal-pink plum background `#2A1E2E`; macOS and other Linux platforms
retain the shared theme. Package and runtime files are authoritative for versions
and exact visual settings.

## Install and verify

Review [`packages.list`](../../linux/arch/packages.list) and
[`packages-aur.list`](../../linux/arch/packages-aur.list). The installer uses
pacman for native packages and yay or paru for AUR packages when available.
AUR installation is unattended (`--noconfirm`); review the declared package set
before applying it.

Launch Firefox once if it has no profile yet, then run from the repository root:

```bash
./install.sh --dry-run
./install.sh
./install.sh --check
./install.sh --doctor
```

The installer copies tracked desktop files under `~/.config/` and discovers the
selected Firefox profile from `~/.mozilla/firefox/profiles.ini`. It installs
`user.js`, `chrome/userChrome.css`, and `chrome/userContent.css` there.
Restart Firefox after changing the profile CSS; reload Sway with:

```bash
swaymsg reload
```

Doctor checks the SwayFX runtime, desktop commands, portals, GTK theme, and font.
Waybar Docker/Kubernetes modules need their respective CLIs. The optional mail
counter stays disabled until its local `mailsecrets.py` is present; keep those
credentials outside version control.

## Optional machine-state refresh hook

The package-manager hook is opt-in because it writes a local machine-state
snapshot into this checkout. The installer does not enable it. To install it
after reviewing [`90-refresh-ai-context.hook`](../../linux/arch/hooks/90-refresh-ai-context.hook):

```bash
sudo install -d /etc/pacman.d/hooks
sed -e "s|__DOTFILES_DIR__|$PWD|" -e "s|__DOTFILES_USER__|$USER|" \
    linux/arch/hooks/90-refresh-ai-context.hook \
  | sudo tee /etc/pacman.d/hooks/90-refresh-ai-context.hook
```

For backups and recovery, use the [maintenance guide](maintenance.md).
