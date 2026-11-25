" Arch (jm-home-box) override: personal-pink, matching the kitty overlay in
" linux/arch/.config/kitty/current-theme.conf. Only Catppuccin Mocha's base
" background changes, to a dark plum. install.sh copies this file to
" ~/.vim/settings/ on Arch only; appearance.vim sources it when present,
" except inside SSH sessions.

function! s:PersonalPinkBase() abort
  if get(g:, 'colors_name', '') !=# 'catppuccin_mocha'
    return
  endif
  " The only groups catppuccin_mocha paints with the base colour; the rest
  " (sign column, line numbers, FZF) inherit Normal's background.
  for group in ['Normal', 'TabLineSel', 'debugBreakpoint']
    execute 'highlight' group 'guibg=#2A1E2E'
  endfor
endfunction

augroup PersonalPinkBase
  autocmd!
  autocmd ColorScheme * call s:PersonalPinkBase()
augroup END
call s:PersonalPinkBase()
