" ===== FZF Configuration =====
" Modern file navigation and fuzzy finding

" FZF default options - Catppuccin Mocha themed
let g:fzf_colors =
\ { 'fg':         ['fg', 'Normal'],
  \ 'bg':         ['bg', 'Normal'],
  \ 'hl':         ['fg', 'Comment'],
  \ 'fg+':        ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':        ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':        ['fg', 'Statement'],
  \ 'info':       ['fg', 'PreProc'],
  \ 'border':     ['fg', 'Ignore'],
  \ 'prompt':     ['fg', 'Conditional'],
  \ 'pointer':    ['fg', 'Exception'],
  \ 'marker':     ['fg', 'Keyword'],
  \ 'spinner':    ['fg', 'Label'],
  \ 'header':     ['fg', 'Comment'] }

" FZF layout - centered floating window
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6, 'relative': v:true } }

" FZF preview window
let g:fzf_preview_window = ['right:50%:hidden', 'ctrl-/']

" Use ripgrep for FZF if available
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
elseif executable('fd')
  let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
endif

" FZF default options
let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline --border --margin=1 --padding=1'

" ===== Key Mappings =====

" File operations
nnoremap <silent> <leader>f  :Files<CR>
nnoremap <silent> <leader>F  :Files ~<CR>
nnoremap <silent> <leader>b  :Buffers<CR>
nnoremap <silent> <leader>l  :BLines<CR>

" Search operations
nnoremap <silent> <leader>g  :Rg<CR>
nnoremap <silent> <leader>G  :Rg <C-R><C-W><CR>
nnoremap <silent> <leader>/  :Lines<CR>

" Vim operations
nnoremap <silent> <leader>c  :Commands<CR>
nnoremap <silent> <leader>h  :Helptags<CR>
nnoremap <silent> <leader>m  :Marks<CR>
nnoremap <silent> <leader>:  :History:<CR>
nnoremap <silent> <leader>"  :Registers<CR>

" File type specific
nnoremap <silent> <leader>t  :Filetypes<CR>

" ===== Custom Commands =====

" Files in git root (if in git repo, otherwise current directory)
command! -bang ProjectFiles call fzf#vim#files(FugitiveExtractGitDir(expand('%:p:h')) != '' ? FugitiveWorkTree() : '.', <bang>0)

" Enhanced ripgrep command with preview
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" Search in open buffers
command! -bang -nargs=* BRg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>).' '.join(map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'shellescape(bufname(v:val))')), 1,
  \   fzf#vim#with_preview(), <bang>0)

" MRU (Most Recently Used) files
command! -bang MRU call fzf#vim#history(fzf#vim#with_preview())

" ===== Advanced Functions =====

" Search for word under cursor in all files
function! s:RgWordUnderCursor()
  let word = expand('<cword>')
  if !empty(word)
    execute 'Rg' word
  endif
endfunction

" Quick file switching in current directory
function! s:QuickFiles()
  call fzf#vim#files('.', {'options': ['--prompt', 'Quick> ']})
endfunction

" Search in current file directory
function! s:FilesInCurrentDir()
  call fzf#vim#files(expand('%:p:h'), fzf#vim#with_preview())
endfunction

" Additional mappings for advanced functions
nnoremap <silent> <leader>fw :call <SID>RgWordUnderCursor()<CR>
nnoremap <silent> <leader>fd :call <SID>FilesInCurrentDir()<CR>
nnoremap <silent> <leader>fq :call <SID>QuickFiles()<CR>
nnoremap <silent> <leader>fr :MRU<CR>