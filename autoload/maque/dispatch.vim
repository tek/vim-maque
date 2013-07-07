function! maque#dispatch#make(cmd) "{{{
  exe g:maque_dispatch_command
endfunction "}}}

function! maque#dispatch#focus() "{{{
  if exists(':FocusDispatch')
    FocusDispatch maque#prg()
  endif
endfunction "}}}
