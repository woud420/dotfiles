"" Make sure we have Plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" UI Enhancements
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'flazz/vim-colorschemes'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }

" Syntax & Language Support
Plug 'sheerun/vim-polyglot'
Plug 'vim-syntastic/syntastic'
" Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}

call plug#end()
