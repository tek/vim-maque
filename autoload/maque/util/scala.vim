function! maque#util#scala#package() abort "{{{
  let pkgline = getline(1)
  let package = substitute(pkgline, 'package \(.*\)', '\1', '')
  return package == pkgline ? '' : package
endfunction "}}}

function! maque#util#scala#test_class() abort "{{{
  let lineno = search('\<class \w\+Test', 'bcnw')
  return lineno == 0 ? '' :
        \ substitute(getline(lineno), '.*\<class \(\w\+Test\).*', '\1', '')
endfunction "}}}

function! maque#util#scala#current_function() abort "{{{
  let lineno = search('\<def \w\+', 'bcn')
  return lineno == 0 ? '' :
        \ substitute(getline(lineno), '.*\<def \(\w\+\).*', '\1', '')
endfunction "}}}

function! maque#util#scala#set_file(callback) "{{{
  let package = maque#util#scala#package()
  if len(package) == 0
    call maque#util#warn('Invalid package line')
  else
    let class = maque#util#scala#test_class()
    if len(class) == 0
      call maque#util#warn('No test class found')
    else
      call call(a:callback, [package, class] + a:000)
      return 1
    endif
  endif
endfunction "}}}
