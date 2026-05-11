" Neovim phase-1 entrypoint.
" Keep the existing Vim configuration as the source of truth while Neovim
" support is introduced incrementally.

set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
let &packpath = &runtimepath

source ~/.vim/vimrc
