function! maque#ft#zsh#set_cursor_function() "{{{
  let found = searchpair('^\(\w\+()\|function \w\+\)\_s*{', '', '^}', 'bcsW')
  if found
    let g:maque_zsh_function = expand('<cword>')
    normal! g``
    return 1
  endif
endfunction "}}}

let g:maque_zsh_args = ''

function! maque#ft#zsh#set_makeprg() "{{{
  if maque#ft#zsh#set_cursor_function()
    call maque#set_params(g:maque_zsh_function.' '.g:maque_zsh_args)
    let g:maque_zsh_makeprg_set = 1
  endif
  return exists('g:maque_zsh_makeprg_set')
endfunction "}}}
