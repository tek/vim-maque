function! maque_zsh#set_cursor_function() "{{{
  let found = searchpair('^\(\w\+()\|function \w\+\)\_s*{', '', '^}', 'bcsW')
  if found
    let g:maque_zsh_function = expand('<cword>')
    normal! g``
    return 1
  endif
endfunction "}}}

let g:maque_zsh#zsh_args = ''

function! maque_zsh#set_makeprg() "{{{
  if maque_zsh#set_cursor_function()
    let &makeprg = 'zsh -ic '.g:maque_zsh_function.' '.g:maque_zsh#zsh_args
    let g:maque_zsh_makeprg_set = 1
  endif
  return exists('g:maque_zsh_makeprg_set')
endfunction "}}}
