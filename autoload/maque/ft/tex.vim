function! maque#ft#tex#set_makeprg() "{{{
  call maque#ft#common#set_file()
  let g:maque_main_tex_file = expand('%')
  return 1
endfunction "}}}
