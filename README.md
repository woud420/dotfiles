dotfiles
========

My dotfiles so I can carry them around ^^ ^^

## Python Environment

Create a project-specific virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Bootstrapping packages

Run the helper script to install common tools. It detects the available
package manager (Homebrew, pacman or apt) and installs the packages listed in
`packages/brew.txt`, `packages/pacman.txt` or `packages/apt.txt`.
These lists contain best-effort package names for each manager—they may not
match perfectly across operating systems so feel free to tweak them for your
setup:

```bash
./install-packages.sh
```
