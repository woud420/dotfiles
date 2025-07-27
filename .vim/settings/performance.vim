" ===== Performance Optimizations =====
" Low-risk, high-impact improvements for better vim responsiveness

" Display performance
set lazyredraw              " Don't redraw screen during macros/scripts
set ttyfast                 " Indicates fast terminal connection
set scrolljump=5            " Jump 5 lines when cursor moves off screen
set sidescroll=1            " Minimal horizontal scrolling

" Key response optimization
set timeout                 " Enable timeouts for key sequences
set timeoutlen=1000         " Wait 1000ms for key sequence completion
set ttimeoutlen=0           " No timeout for terminal key codes (instant ESC)

" Buffer management
set hidden                  " Allow switching buffers without saving
set confirm                 " Ask before closing unsaved files

" Memory and processing
set history=1000            " Remember more commands and searches
set undolevels=1000         " More undo levels

" File system performance
set noswapfile              " Disable swap files (use version control instead)
" Note: nobackup and nowritebackup are set in settings.vim for CoC

" CoC performance optimization
let g:coc_disable_startup_warning = 1  " Skip CoC startup warnings