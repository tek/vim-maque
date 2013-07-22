function! maque#util#buffer_is_in_project(num) "{{{
  let path = fnamemodify(expand('#'.a:num), ':p')
  try
    let path = system('realpath '.path)
  catch
  endtry
  return path =~ getcwd()
endfunction "}}}

function! maque#util#warn(msg) "{{{
  echohl WarningMsg
  echo 'maque: '.a:msg
  echohl None
endfunction "}}}

function! maque#util#is_autoload(name) "{{{
  if match(a:name, '#') > 0
    let fpath = substitute(a:name, '#', '/', 'g')
    let fpath = fnamemodify(fpath, ':h')
    exe 'runtime autoload/'.fpath.'.vim'
    return exists('*'.a:name)
  else
    return 0
  endif
endfunction "}}}
 
function! maque#util#lookup(...) "{{{
  for name in a:000
    if maque#util#is_autoload(name)
      return function(name)
    elseif exists('*'.name)
      return function(name)
    elseif exists(name)
      if exists('*'.{name}) || maque#util#is_autoload({name})
        return function({name})
      endif
    endif
  endfor
  return -1
endfunction "}}}

function! maque#util#handler_function(name, default) "{{{
  return maque#util#lookup('maque#'.g:maque_handler.'#'.a:name, a:default)
endfunction "}}}
