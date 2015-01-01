function! maque#ft#scalatest#set_makeprg() "{{{
  return maque#ft#scalatest#set_file()
endfunction "}}}

function! maque#ft#scalatest#set_file() "{{{
  let pkgline = getline(1)
  let package = substitute(pkgline, 'package \(.*\)', '\1', '')
  echom package
  if package == pkgline
    call maque#util#warn('Invalid package line')
  else
    let lineno = search('class \w\+Test', 'bcnw')
    if lineno == 0
      call maque#util#warn('No test class found')
    else
      let class = substitute(getline(lineno), 'class \(\w\+Test\)', '\1', '')
      let g:scalatest_class = package . '.' . class
      let g:maqueprg = 'test-only ' . g:scalatest_class
      return 1
    endif
  endif
endfunction "}}}
