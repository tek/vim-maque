function! maque#ft#common#set_file() "{{{
  let &makeprg = maque#command().' '.expand('%')
  let g:maque_makeprg_set = 1
  return 1
endfunction "}}}

function! maque#ft#common#set_line() "{{{
  call maque#ft#common#set_file()
  let &makeprg .= ':'.line('.')
  return 1
endfunction "}}}
