syntax on
filetype plugin indent on

" Always show status line
set laststatus=2

" Catppuccin theme settings
let g:catppuccin_flavour = 'mocha' " latte, frappe, macchiato, mocha
silent! colorscheme catppuccin_mocha

" Platform theme overlay, copied here by install.sh from the current platform's
" layer: linux/arch/.vim/settings/ (personal-pink) or darwin/.vim/settings/
" (stock Mocha). Other platforms have none and keep stock Mocha.
" Skipped over SSH: the overlay matches this machine's terminal, but an SSH
" session is drawn in the client's terminal, so stock Mocha is the safer guess.
if empty($SSH_CONNECTION) && filereadable(expand('~/.vim/settings/theme-overlay.vim'))
  source ~/.vim/settings/theme-overlay.vim
endif

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

" catppuccin/vim defines no float or CoC groups, so Neovim's near-black
" NormalFloat shows through. Give floats the theme's text on the menu
" background and reuse its Pmenu colours for CoC's completion menu.
function! s:FloatColors() abort
  let fg = synIDattr(synIDtrans(hlID('Normal')), 'fg#')
  let bg = synIDattr(synIDtrans(hlID('Pmenu')), 'bg#')
  if !empty(fg) && !empty(bg)
    execute 'highlight NormalFloat guifg=' . fg . ' guibg=' . bg
  endif
  highlight! link FloatBorder PmenuBorder
  highlight! link CocFloating NormalFloat
  highlight! link CocFloatBorder FloatBorder
  highlight! link CocMenuSel PmenuSel
  highlight! link CocPumSearch Function
  highlight! link CocPumMenu PmenuExtra
  highlight! link CocPumDetail PmenuExtra
endfunction
augroup CatppuccinFloats
  autocmd!
  autocmd ColorScheme * call s:FloatColors()
augroup END
call s:FloatColors()

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
