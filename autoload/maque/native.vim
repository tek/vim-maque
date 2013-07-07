function! maque#native#make(cmd) "{{{
  let save_makeprg = &makeprg
  let &makeprg = maque#prg()
  make!
  let &makeprg = save_makeprg
endfunction "}}}
