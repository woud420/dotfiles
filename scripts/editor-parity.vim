" Headless fixture for scripts/check-editor-parity.sh.

set nomore

let s:failures = []

function! s:Check(name, condition, detail) abort
  if !a:condition
    call add(s:failures, a:name . ': ' . a:detail)
  endif
endfunction

function! s:HasCommand(name) abort
  return exists(':' . a:name) == 2
endfunction

function! s:MapRhs(mode, lhs) abort
  return maparg(a:lhs, a:mode)
endfunction

function! s:CheckIndent(filetype, tabstop, shiftwidth, softtabstop, expandtab) abort
  execute 'setfiletype ' . a:filetype
  call s:Check(a:filetype . ' tabstop', &l:tabstop == a:tabstop, 'expected ' . a:tabstop . ', got ' . &l:tabstop)
  call s:Check(a:filetype . ' shiftwidth', &l:shiftwidth == a:shiftwidth, 'expected ' . a:shiftwidth . ', got ' . &l:shiftwidth)
  call s:Check(a:filetype . ' softtabstop', &l:softtabstop == a:softtabstop, 'expected ' . a:softtabstop . ', got ' . &l:softtabstop)
  call s:Check(a:filetype . ' expandtab', &l:expandtab == a:expandtab, 'expected ' . a:expandtab . ', got ' . &l:expandtab)
  setlocal filetype=
endfunction

call s:Check('colorscheme', get(g:, 'colors_name', '') ==# 'catppuccin_mocha', 'got ' . get(g:, 'colors_name', ''))

for s:command in ['CocList', 'Files', 'GFiles', 'RG', 'Format']
  call s:Check('command ' . s:command, s:HasCommand(s:command), 'missing')
endfor

call s:Check('insert jk', s:MapRhs('i', 'jk') ==# '<Esc>', 'unexpected rhs: ' . string(s:MapRhs('i', 'jk')))
call s:Check('visual jk', s:MapRhs('v', 'jk') ==# '<Esc>', 'unexpected rhs: ' . string(s:MapRhs('v', 'jk')))
call s:Check('normal tab', s:MapRhs('n', "\<Tab>") ==# '<C-W>w', 'unexpected rhs: ' . string(s:MapRhs('n', "\<Tab>")))
call s:Check('leader f', !empty(s:MapRhs('n', '<leader>f')), 'missing')
call s:Check('leader g', !empty(s:MapRhs('n', '<leader>g')), 'missing')
call s:Check('gd', !empty(s:MapRhs('n', 'gd')), 'missing')
call s:Check('gr', !empty(s:MapRhs('n', 'gr')), 'missing')
call s:Check('F', s:MapRhs('n', 'F') =~# 'CocAction', 'unexpected rhs: ' . string(s:MapRhs('n', 'F')))

syntax off
call s:CheckIndent('python', 2, 2, 2, 1)
call s:CheckIndent('javascript', 2, 2, 2, 1)
call s:CheckIndent('typescript', 2, 2, 2, 1)
call s:CheckIndent('sh', 2, 2, 2, 1)
call s:CheckIndent('yaml', 2, 2, 2, 1)
call s:CheckIndent('json', 2, 2, 2, 1)
call s:CheckIndent('make', 2, 2, 0, 0)
bwipeout!

if !empty(s:failures)
  for s:failure in s:failures
    echomsg 'PARITY FAIL: ' . s:failure
  endfor
  cquit 1
endif

quitall!
