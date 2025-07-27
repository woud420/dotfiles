set backspace=indent,eol,start

set incsearch
set hlsearch
set showmatch

set nomodeline

" Polyglot Settings
let g:polyglot_disabled = ['csv']

" COC Settings
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Some server have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2
