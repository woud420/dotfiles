" pathogen
call pathogen#infect()

" commenting/uncommenting a block of text
" using ,c and ,u
au FileType haskell,vhdl,ada let b:comment_leader = '-- '
au FileType vim let b:comment_leader = '" '
au FileType c,cpp,java,javascript let b:comment_leader = '// '
au FileType sh,make,coffee,python let b:comment_leader = '# '
au FileType tex let b:comment_leader = '% '
noremap <silent> ,c :<C-B>sil <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:noh<CR>
noremap <silent> ,u :<C-B>sil <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:noh<CR>


:set tabstop=4 softtabstop=4 shiftwidth=4 expandtab

" coffee
filetype plugin indent on
au BufNewFile,BufReadPost *.coffee setl shiftwidth=4 expandtab tabstop=4 softtabstop=4
au BufWritePost *.coffee silent CoffeeMake! | cwindow | redraw!

" code completion?
filetype plugin on
set ofu=syntaxcomplete#Complete

set number
set gfn=Monaco:h14


" so I can remap cmd-S to :w
nmap <F2> :w<cr>

" back to normal mode and save (why not)
" this is simon's personal shortcut
imap jk <esc>:w<cr>

" bash like <tab>
set wildmode=longest,list
set wildmenu

if $TMUX == ''
    set clipboard+=unnamed
endif

set wildignore+=*.so,*.swp,*.zip,*.pyc,*~

" CTRL P
nmap <Leader>p :CtrlPBuffer<CR>
let g:ctrlp_custom_ignore = 'build'
let g:ctrlp_working_path_mode = ''


" NERD tree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" ctrl-N to toggle nerd tree
nmap <C-N> :NERDTreeToggle<CR>

" python-mode
" removing some annoying pep-8 errors
let g:pymode_lint_ignore = "E251,E401,E501,E231"
let g:pymode_lint_cwindow = 0

" solarized
syntax enable
set background=dark
let g:solarized_termtrans = 1
colorscheme solarized

" ====== from now on is a .vimrc I grabbed from the interne =============

"
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2008 Jul 02
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif
" For tmux
set ttymouse=xterm2

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

"""""""""""""""""""""
" call plug#begin('~/.vim/plugged')
" Initialize plugin system
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes' 
" Plug 'octol/vim-cpp-enhanced-highlight'
" Plug 'ctrlpvim/ctrlp.vim'
" Plug 'majutsushi/tagbar'
" Plug 'craigemery/vim-autotag'
" call plug#end()

" set encoding=utf-8

" syntax on
" filetype plugin indent on

"Information on the following setting can be found with
":help set
"set tabstop=4
"set expandtab
"set autoindent 
"set shiftwidth=4  "this is the level of autoindent, adjust to taste
"set ruler
"set number
"set backspace=indent,eol,start
" Uncomment below to make screen not flash on error
" set vb t_vb=""

"set cursorline
"set incsearch
"set hlsearch
"set showmatch

" Bash like tab
"set wildmode=longest,list,full
"set wildmenu

" Erase search results
"nnoremap <leader><space> :nohlsearch<CR>
" Open a terminal window in current buffer
"nnoremap :term :term<space>++curwin

" Shift-x for tags
" nnoremap <S-x> :TagbarToggle<CR>

" Remapping esc to `jk`
"inoremap jk <Esc>
"vnoremap jk <Esc>

" Tab moves to the next window within pane
"map <Tab> <C-w>w
"tnoremap <Tab> <C-W>w

" Set split to right and down by default
":set splitright
":set splitbelow
" | creates a vertical split and moves there
"nmap <Bar> :vnew<CR>
" - creates a horizontal split and moves there
"nmap - <C-w>:new<CR>

" Explorer on the right side

"let g:seoul256_background = 234
"colo seoul256
"set background=dark
"let g:airline_powerline_fonts = 1

" Switching between tabs
"nnoremap <silent> <C-Left> :tabprevious<CR>
"nnoremap <silent> <C-Right> :tabnext<CR>

" cpp highlight configs
"let g:cpp_class_scope_highlight = 1
"let g:cpp_member_variable_highlight = 1
"let g:cpp_class_decl_highlight = 1

"let g:airline#extensions#tabline#fnamemod = ':t'
