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
nnoremap <silent> <leader>g  :RG<CR>
nnoremap <silent> <leader>G  :RG <C-R><C-W><CR>
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

" Binary file extensions to exclude from search
let g:rg_binary_extensions = 'jpg,jpeg,png,gif,bmp,svg,ico,pdf,zip,tar,gz,7z,rar,exe,dll,so,dylib,bin,dat,db,sqlite'

" Interactive ripgrep with live search
" Features:
"   - Shows empty results initially (no file spam)
"   - Updates results live as you type
"   - Excludes binary files using g:rg_binary_extensions
"   - Shortens long paths to [..]/parent/file format for readability
"   - Hides the file count info for cleaner UI
function! RipgrepFzf(query, fullscreen)
  " Build the ripgrep command with:
  " - Binary file exclusions from g:rg_binary_extensions
  " - Pipe through awk to shorten paths (keep last 2 components)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case --binary -g "!*.{' . g:rg_binary_extensions . '}" -- %s | awk -F: ''{split($1,a,"/"); if(length(a)>2) $1="[..]/"a[length(a)-1]"/"a[length(a)]; else $1=$1; printf "%%s:%%s:%%s:%%s\n", $1, $2, $3, substr($0,index($0,$4))}'' || true'
  
  " Start with empty results
  let initial_command = 'echo ""'
  
  " Only run ripgrep when query is non-empty
  let reload_command = 'if [ -n "{q}" ]; then ' . printf(command_fmt, '{q}') . '; else echo ""; fi'
  
  " FZF options:
  " --phony: Don't run initial command on every keystroke
  " --bind change:reload: Re-run command when input changes
  " --info=hidden: Hide the match counter
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command, '--prompt', '🔍 ', '--info=hidden']}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

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