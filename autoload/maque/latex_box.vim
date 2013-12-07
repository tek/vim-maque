function! maque#latex_box#make_pane(ignore, ignoretoo) "{{{
  if !exists('g:maque_main_tex_file')
    call maque#ft#tex#set_makeprg()
  endif
  let b:main_tex_file = g:maque_main_tex_file
  Latexmk
endfunction "}}}
