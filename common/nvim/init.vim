" Neovim compatibility bridge.
" Keep editor behavior in the existing Vimscript config and load it from Neovim.

set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
let &packpath = &runtimepath

let g:coc_config_home = expand('~/.config/nvim')

source ~/.vim/vimrc
