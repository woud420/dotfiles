" Leave g:airline_theme unset so Airline follows the active colorscheme.

" Airline Setup
" let g:airline_extensions = ['branch']
" let g:airline_extensions = ['branch', 'hunks', 'whitespace']
" let g:airline#extensions#default#enabled = 1
" let g:airline#extensions#branch#enabled = 1
" let g:airline_section_b = '%{airline#extensions#branch#get_head()}'
" let g:airline_section_b = '%{&fileencoding}[unix]'
let g:airline_section_x = '' " I just don't need to know the executable
let g:airline_section_z = '%p%% ln: %l/%L ~> %c'
