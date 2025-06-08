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

## Homebrew packages

If you're on macOS with [Homebrew](https://brew.sh) installed, you can
install all of the command line tools I use with:

```bash
brew bundle --file Brewfile
```

You can also run `make brew` which executes the same command.
