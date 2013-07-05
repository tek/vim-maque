function! maque#ft#tex#set_makeprg() "{{{
  let origin = bufnr('%')
  bufdo let b:main_tex_file = expand('%')
  exe 'buffer '.origin
  return 1
endfunction "}}}
