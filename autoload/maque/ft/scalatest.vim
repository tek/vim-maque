function! maque#ft#scalatest#set_makeprg() "{{{
  return maque#ft#scalatest#set_file()
endfunction "}}}

function! maque#ft#scalatest#set_file() "{{{
  return maque#util#java#set_file('maque#ft#scalatest#set_class')
endfunction "}}}

function! maque#ft#scalatest#set_class(package, class) abort "{{{
  let scalatest_class = a:package . '.' . a:class
  " let g:maqueprg = 'test-only ' . scalatest_class
  call maque#set_params(scalatest_class)
endfunction "}}}
