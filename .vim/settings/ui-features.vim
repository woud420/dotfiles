" ===== Custom UI Features =====
" Floating/popup views for registers, marks and buffers. Neovim uses a
" floating window (nvim_open_win); Vim 8.2+ uses popup_create.

" Highlight groups for the popups (Catppuccin Mocha inspired)
augroup PopupHighlights
  autocmd!
  autocmd ColorScheme * highlight RegisterPopup guibg=#1e1e2e guifg=#cdd6f4 ctermbg=234 ctermfg=252
  autocmd ColorScheme * highlight RegisterPopupBorder guibg=#313244 guifg=#89b4fa ctermbg=236 ctermfg=117
augroup END
highlight RegisterPopup guibg=#1e1e2e guifg=#cdd6f4 ctermbg=234 ctermfg=252
highlight RegisterPopupBorder guibg=#313244 guifg=#89b4fa ctermbg=236 ctermfg=117

" Show lines in a float. pos is 'topright', 'topleft' or 'center'.
function! s:ShowPopup(lines, title, pos) abort
  if has('nvim')
    call s:NvimFloat(a:lines, a:title, a:pos)
  elseif has('popupwin')
    call s:VimPopup(a:lines, a:title, a:pos)
  else
    echo 'Popups require Neovim or Vim 8.2+'
  endif
endfunction

function! s:NvimFloat(lines, title, pos) abort
  let width = min([max(map(copy(a:lines), 'strdisplaywidth(v:val)') + [30]) + 2, &columns - 4])
  let height = min([max([len(a:lines), 1]), 20, &lines - 4])
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:true, a:lines)
  call setbufvar(buf, '&bufhidden', 'wipe')
  let opts = {'relative': 'editor', 'width': width, 'height': height,
        \ 'style': 'minimal', 'border': 'rounded',
        \ 'title': a:title, 'title_pos': 'center'}
  if a:pos ==# 'topright'
    let opts.row = 1
    let opts.col = &columns - width - 2
  elseif a:pos ==# 'topleft'
    let opts.row = 1
    let opts.col = 2
  else
    let opts.row = max([(&lines - height) / 2 - 1, 0])
    let opts.col = max([(&columns - width) / 2, 0])
  endif
  let win = nvim_open_win(buf, v:true, opts)
  call nvim_set_option_value('winhighlight', 'Normal:RegisterPopup,FloatBorder:RegisterPopupBorder', {'win': win})
  nnoremap <buffer> <silent> q <Cmd>close<CR>
  nnoremap <buffer> <silent> <Esc> <Cmd>close<CR>
endfunction

function! s:VimPopup(lines, title, pos) abort
  let opts = {
    \ 'minwidth': 30,
    \ 'maxwidth': 60,
    \ 'maxheight': 20,
    \ 'border': [1, 1, 1, 1],
    \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
    \ 'title': a:title,
    \ 'close': 'click',
    \ 'padding': [0, 1, 0, 1],
    \ 'highlight': 'RegisterPopup',
    \ 'borderhighlight': ['RegisterPopupBorder'],
    \ 'scrollbar': 1,
    \ 'mapping': 0,
    \ 'time': 10000,
    \ 'moved': 'any'
    \ }
  if a:pos ==# 'topright'
    call extend(opts, {'pos': 'topright', 'line': 1, 'col': &columns - 2})
  elseif a:pos ==# 'topleft'
    call extend(opts, {'pos': 'topleft', 'line': 2, 'col': 5})
  else
    call extend(opts, {'pos': 'center'})
  endif
  let popup_id = popup_create(a:lines, opts)
  call popup_filter_menu(popup_id, 'ShowPopupFilter')
endfunction

" Vim popup filter: Esc closes
function! ShowPopupFilter(id, key) abort
  if a:key == "\<Esc>"
    call popup_close(a:id)
    return 1
  endif
  return 0
endfunction

function! ShowRegistersPopup() abort
  call s:ShowPopup(split(execute('registers'), '\n'), ' 📋 Registers ', 'topright')
endfunction

function! ShowMarksPopup() abort
  call s:ShowPopup(split(execute('marks'), '\n'), ' 🔖 Marks ', 'center')
endfunction

function! ShowBuffersPopup() abort
  call s:ShowPopup(split(execute('ls'), '\n'), ' 📁 Buffers ', 'topleft')
endfunction

" ===== Key Mappings =====
nnoremap <silent> <leader>r :call ShowRegistersPopup()<CR>
