" ===== Custom UI Features =====
" This file contains custom UI enhancements like floating windows and popups

" Define custom highlight groups for popups (Catppuccin Mocha inspired)
augroup PopupHighlights
  autocmd!
  " Main popup background - darker for contrast
  autocmd ColorScheme * highlight RegisterPopup guibg=#1e1e2e guifg=#cdd6f4 ctermbg=234 ctermfg=252
  " Border - subtle blue accent
  autocmd ColorScheme * highlight RegisterPopupBorder guibg=#313244 guifg=#89b4fa ctermbg=236 ctermfg=117
  " Alternative styles you can try:
  " Darker with green accent:
  " autocmd ColorScheme * highlight RegisterPopup guibg=#11111b guifg=#a6e3a1 
  " autocmd ColorScheme * highlight RegisterPopupBorder guifg=#a6e3a1
  " Purple accent:
  " autocmd ColorScheme * highlight RegisterPopup guibg=#181825 guifg=#cba6f7
  " autocmd ColorScheme * highlight RegisterPopupBorder guifg=#cba6f7
augroup END

" Show registers in a floating window (upper right corner)
" Requires Vim 8.2+ with popup support
function! ShowRegistersPopup()
  " Check if popups are supported
  if !has('popupwin')
    echo "Popup windows require Vim 8.2+"
    return
  endif
  
  " Get register contents
  let reg_output = execute('registers')
  let reg_lines = split(reg_output, '\n')
  
  " Create custom highlight groups for the popup
  highlight RegisterPopup guibg=#1e1e2e guifg=#cdd6f4 ctermbg=234 ctermfg=252
  highlight RegisterPopupBorder guibg=#313244 guifg=#89b4fa ctermbg=236 ctermfg=117
  
  " Create popup in upper right corner
  let popup_id = popup_create(reg_lines, {
    \ 'pos': 'topright',
    \ 'line': 1,
    \ 'col': &columns - 2,
    \ 'minwidth': 30,
    \ 'maxwidth': 40,
    \ 'maxheight': 15,
    \ 'border': [1, 1, 1, 1],
    \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
    \ 'title': ' 📋 Registers ',
    \ 'close': 'click',
    \ 'padding': [1, 2, 1, 2],
    \ 'highlight': 'RegisterPopup',
    \ 'borderhighlight': ['RegisterPopupBorder'],
    \ 'scrollbar': 1,
    \ 'mapping': 0,
    \ 'time': 10000,
    \ 'moved': 'any'
    \ })
  
  " Allow closing with Esc
  call popup_filter_menu(popup_id, 'ShowRegistersFilter')
endfunction

" Filter function to handle Esc key
function! ShowRegistersFilter(id, key)
  if a:key == "\<Esc>"
    call popup_close(a:id)
    return 1
  endif
  return 0
endfunction

" Alternative: Show registers in a preview window (works in older Vim)
function! ShowRegistersPreview()
  " Save current window
  let curr_win = winnr()
  
  " Create small window in upper right
  topleft 10vnew
  wincmd L
  vertical resize 35
  
  " Set window properties
  setlocal previewwindow
  setlocal buftype=nofile
  setlocal bufhidden=delete
  setlocal noswapfile
  setlocal nowrap
  setlocal nonumber
  setlocal norelativenumber
  
  " Insert register content
  put =execute('registers')
  normal! gg
  
  " Map q and Esc to close
  nnoremap <buffer> q :close<CR>
  nnoremap <buffer> <Esc> :close<CR>
  
  " Return to original window
  execute curr_win . 'wincmd w'
endfunction

" ===== Key Mappings =====

" Show registers popup
nnoremap <silent> <leader>r :call ShowRegistersPopup()<CR>

" Quick register access with visual feedback
" Shows registers when pressing " in normal mode
" (uncomment if you want this behavior)
" nnoremap " :call ShowRegistersPopup()<CR>"

" ===== Additional UI Features =====

" Show marks in a floating window
function! ShowMarksPopup()
  if !has('popupwin')
    echo "Popup windows require Vim 8.2+"
    return
  endif
  
  let marks_output = execute('marks')
  let marks_lines = split(marks_output, '\n')
  
  call popup_create(marks_lines, {
    \ 'pos': 'center',
    \ 'minwidth': 40,
    \ 'maxheight': 20,
    \ 'border': [],
    \ 'title': ' 🔖 Marks ',
    \ 'close': 'click',
    \ 'padding': [0, 1, 0, 1],
    \ })
endfunction

" Show buffer list in a floating window
function! ShowBuffersPopup()
  if !has('popupwin')
    echo "Popup windows require Vim 8.2+"
    return
  endif
  
  let buffers_output = execute('ls')
  let buffer_lines = split(buffers_output, '\n')
  
  call popup_create(buffer_lines, {
    \ 'pos': 'topleft',
    \ 'line': 2,
    \ 'col': 5,
    \ 'minwidth': 50,
    \ 'maxheight': 15,
    \ 'border': [],
    \ 'title': ' 📁 Buffers ',
    \ 'close': 'click',
    \ 'padding': [0, 1, 0, 1],
    \ })
endfunction

" Optional: Auto-show registers on " press (commented out by default)
" augroup RegisterPreview
"   autocmd!
"   autocmd CmdlineEnter : if getcmdtype() == '"' | call ShowRegistersPopup() | endif
" augroup END