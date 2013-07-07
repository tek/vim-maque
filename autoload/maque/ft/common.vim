function! maque#ft#common#set_file() "{{{
  call maque#set_params(expand('%'))
  let g:maque_makeprg_set = 1
  return 1
endfunction "}}}

function! maque#ft#common#set_line() "{{{
  call maque#ft#common#set_file()
  let g:maqueprg .= ':'.line('.')
  return 1
endfunction "}}}
