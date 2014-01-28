function! maque#util#buffer_is_in_project(num) "{{{
  let path = fnamemodify(expand('#'.a:num), ':p')
  if executable('realpath')
    let path = maque#util#system('realpath '.path, 1)
  endif
  return path =~ getcwd()
endfunction "}}}

function! maque#util#warn(msg) "{{{
  echohl WarningMsg
  echo 'maque: '.a:msg
  echohl None
endfunction "}}}

" Determine if the argument is an existing function in an autoload/ directory:
" - It must have a # in it
" - If it doesn't exist, its runtime path is sourced.
" Warning: Do not use this from an autoload file with the same path as the
" target function if you're not sure that the function exists (e.g. as
" fallback for a lookup list)
function! maque#util#is_autoload(name) "{{{
  if match(a:name, '#') > 0
    let fpath = substitute(a:name, '#', '/', 'g')
    let fpath = fnamemodify(fpath, ':h')
    if !exists('*'.a:name)
      exe 'runtime! autoload/'.fpath.'.vim'
    endif
    return exists('*'.a:name)
  else
    return 0
  endif
endfunction "}}}
 
" Determine the first argument denoting an existing function and return a
" funcref, or -1 if unsuccessful.
" Several resolution methods are employed, a function is returned if:
" - the string refers to an existing and loaded function
" - the string refers to an unloaded autoload function
" - the string refers to an existing variable, which points to a function
function! maque#util#lookup(...) "{{{
  for name in a:000
    if exists('*'.name) || maque#util#is_autoload(name)
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

function! maque#util#output_lines(cmd) "{{{
  let output = maque#util#system(a:cmd, 1)
  return split(output, "\n")
endfunction "}}}
  
function! maque#util#child_pids(pid) "{{{
  let rex = '^\s*\(\d\+\) \(\w\+\)\s*$'
  let lines = maque#util#output_lines('ps h -o pid,comm --ppid '.a:pid)
  let lines = filter(lines, 'match(v:val, rex) >= 0')
  return map(lines, 'matchlist(v:val, rex)[1:2]')
endfunction "}}}

" Find the first defined variable in a precendence sequence:
" buffer, then global, for each in {name}, {name}_default
function! maque#util#variable(name, ...) "{{{
  let default = a:0 ? a:1 : ''
  for src in ['', '_default']
    for scope in ['b', 'g']
      let var = scope.':'.a:name.src
      if exists(var)
        return {var}
      endif
    endfor
  endfor
  return ''
endfunction "}}}

function! maque#util#has_vimproc() abort "{{{
  return exists(':VimProcRead')
endfunction "}}}

function! maque#util#system(cmd, ...) abort "{{{
  let blocking = get(a:000, 0)
  if maque#util#has_vimproc()
    if blocking || !g:maque_async
      return vimproc#system(a:cmd)
    else
      call vimproc#system_bg(a:cmd)
    endif
  else
    return system(a:cmd)
  endif
endfunction "}}}

function! maque#util#server_alive(name) abort "{{{
  try
    return remote_expr(a:name, '1')
  catch
  endtry
endfunction "}}}

function! maque#util#wait_until(predicate, ...) "{{{
  let counter = 0
  let timeout = get(a:000, 0, 10)
  while !eval(a:predicate) && counter < timeout
    sleep 200m
    let counter += 1
  endwhile
endfunction "}}}
