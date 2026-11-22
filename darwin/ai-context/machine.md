# This machine: MacBook

- **OS:** macOS on Apple Silicon
- **Packages:** Homebrew (`brew install <formula>`, `brew install --cask <app>`);
  the dotfiles `darwin/Brewfile` lists what is installed
- **Shell:** zsh
- **Terminals:** Kitty and Ghostty
- **Dotfiles:** `~/workspace/projects/dotfiles`
- **Projects:** `~/workspace/projects/`

## Notes

- GNU tools from Homebrew replace the BSD ones through aliases (`ls`, `sed`, `grep`)
- Apple's `clang` and `clangd` are the defaults; Homebrew's llvm is last on
  PATH for `clang-format` and `clang-tidy`
- Catppuccin Mocha theme
