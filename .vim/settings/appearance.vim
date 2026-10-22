syntax on
filetype plugin indent on

" Always show status line
set laststatus=2

" Catppuccin theme settings
let g:catppuccin_flavour = 'mocha' " latte, frappe, macchiato, mocha
silent! colorscheme catppuccin_mocha
let g:airline_theme = 'catppuccin_mocha' " airline palette shipped by catppuccin/vim

" catppuccin/vim predates tree-sitter captures. Neovim links most @captures to
" the classic groups, but @variable (and the .parameter/.member captures that
" inherit from it) keep Neovim's stock grey; use the theme's text colour instead.
if has('nvim')
  function! s:TreesitterVariableColor() abort
    let fg = synIDattr(hlID('Normal'), 'fg#')
    if !empty(fg)
      execute 'highlight @variable guifg=' . fg
    endif
  endfunction
  augroup CatppuccinTreesitter
    autocmd!
    autocmd ColorScheme * call s:TreesitterVariableColor()
  augroup END
  call s:TreesitterVariableColor()
endif

" let g:airline_extensions = ['branch']
" let g:airline_extensions = ['branch', 'hunks', 'whitespace']
" let g:airline#extensions#default#enabled = 1
" let g:airline#extensions#branch#enabled = 1
" let g:airline_section_b = '%{airline#extensions#branch#get_head()}'
" let g:airline_section_b = '%{&fileencoding}[unix]'
let g:airline_section_x = '' " I just don't need to know the executable
let g:airline_section_z = '%p%% ln: %l/%L ~> %c'

" Global defaults
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set ruler
set number
set backspace=indent,eol,start

" Language-specific overrides
augroup LanguageIndentation
  autocmd!
  autocmd FileType python,vim setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
  autocmd FileType javascript,typescript,html,css,scss,sass,json,yaml,lua,vue,svelte setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
  autocmd FileType sh,bash,zsh setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
  " Special for Makefiles:
  autocmd FileType make setlocal noexpandtab tabstop=2 shiftwidth=2 softtabstop=0
augroup END

set cursorline

set incsearch
set hlsearch
set showmatch

set relativenumber
set termguicolors

" Hide ~ characters at end of buffer
set fillchars=eob:\ 

" Hide mode indicator (airline already shows it)
set noshowmode
