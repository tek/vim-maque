function! maque#util#path_is_in_project(path) "{{{
  return a:path =~ getcwd() && (filereadable(a:path) || isdirectory(a:path))
endfunction "}}}

function! maque#util#warn(msg) "{{{
  redraw
  echohl WarningMsg
  echom 'maque: '.a:msg
  echohl None
endfunction "}}}

function! maque#util#error(msg) "{{{
  redraw
  echohl ErrorMsg
  echom 'maque: '.a:msg
  echohl None
endfunction "}}}

function! maque#util#debug(msg) "{{{
  let stamped = strftime('%H:%M:%S') . ' | ' . a:msg
  if maque#util#want_debug()
    if maque#util#want('log_file')
      redir >> maque_log
      echo stamped
      redir END
    else
      echom 'maque: ' . stamped
    endif
  endif
endfunction "}}}

function! maque#util#want_debug() abort "{{{
  return exists('$MAQUE_DEBUG') || exists('g:maque_debug')
endfunction "}}}

" returns true if all of the arguments are existing, true variables
function! maque#util#want(...) abort "{{{
  for opt in a:000
    if !get(g:, 'maque_' . opt)
      return 0
    endif
  endfor
  return 1
endfunction "}}}

" returns true if all of the arguments are nonexisting or false variables
function! maque#util#not_want(...) abort "{{{
  for opt in a:000
    if get(g:, 'maque_' . opt)
      return 0
    endif
  endfor
  return 1
endfunction "}}}

" Determine if the argument is an existing function in an autoload/ directory:
" - It must have a # in it
" - If it doesn't exist, its runtime path is sourced.
" Warning: Do not use this from an autoload file with the same path as the
" target function if you're not sure that the function exists (e.g. as
" fallback for a lookup list)
function! maque#util#is_autoload(name) "{{{
  try
    if match(a:name, '#') > 0
      let fpath = substitute(a:name, '#', '/', 'g')
      let fpath = fnamemodify(fpath, ':h')
      if !exists('*'.a:name)
        exe 'runtime! autoload/'.fpath.'.vim'
      endif
      return exists('*'.a:name)
    endif
  catch /E127/
    " undefined function from the same autoload path
  endtry
endfunction "}}}

" Determine the first argument denoting an existing function and return a
" funcref, or -1 if unsuccessful.
" Several resolution methods are employed, a function is returned if:
" - the string refers to an existing and loaded function
" - the string refers to an unloaded autoload function
" - the string refers to an existing variable, which points to a function
function! maque#util#lookup(...) "{{{
  for name in a:000
    if !empty(name)
      if exists('*'.name) || maque#util#is_autoload(name)
        return function(name)
      elseif exists(name)
        if exists('*'.{name}) || maque#util#is_autoload({name})
          return function({name})
        endif
      endif
    endif
  endfor
  return -1
endfunction "}}}

function! maque#util#handler_function(name, default, ...) "{{{
  let handler = get(a:000, 0, g:maque_handler)
  return maque#util#lookup('maque#'.handler.'#'.a:name, a:default)
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
  try
    if blocking || !g:maque_async || !has('nvim')
      return system(a:cmd)
    else
      call jobstart(a:cmd)
    endif
  catch
    return 'error'
  endtry
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

function! maque#util#wait_until_dict(...) "{{{
  let counter = 0
  let timeout = get(a:000, 0, 10)
  while !call('call', a:000) && counter < timeout
    sleep 200m
    let counter += 1
  endwhile
endfunction "}}}

function! maque#util#parse_args(args, min_num, max_num) abort "{{{
  try
    sandbox let parsed = eval('[' . a:args . ']')
    if len(parsed) > a:max_num || len(parsed) < a:min_num
      throw 'error'
    end
    return [1, parsed]
  catch
    echom v:exception
    call maque#util#warn('Command argument parse error: ' . a:args)
    return [0, []]
  endtry
endfunction "}}}

" Schedule a function call for execution as soon as initialization is complete
function! maque#util#schedule(func, args) abort "{{{
  if maque#initialized()
    return call(a:func, a:args)
  else
    call add(g:_maque_scheduled_tasks, [a:func, a:args])
  endif
endfunction "}}}

function! maque#util#run_scheduled_tasks() abort "{{{
  for info in g:_maque_scheduled_tasks
    call call(info[0], info[1])
  endfor
  call maque#util#mautocmd('InitializedPre')
endfunction "}}}

function! maque#util#true() abort "{{{
  return 1
endfunction "}}}

function! maque#util#command_name(name) abort "{{{
  return substitute(a:name, '\v%(^|[-_])(\l)', '\u\1', 'g')
endfunction "}}}

function! maque#util#exec_handler(fun) abort "{{{
  let s:Handler = maque#util#handler_function(a:fun, '', g:maque_handler)
  if type(s:Handler) == 2
    call s:Handler()
  end
endfunction "}}}

function! maque#util#silent(cmd) abort "{{{
  try
    if maque#util#want_debug()
      execute a:cmd
    else
      execute 'silent ' . a:cmd
    endif
  catch //
    call maque#util#error(v:throwpoint . ': ' . v:exception)
  endtry
endfunction "}}}

function! maque#util#fargs(action, nargs, args) abort "{{{
  let fargs = split(a:args)
  if index(a:nargs, len(fargs)) >= 0
    return fargs
  else
    throw 'wrong argument count for ''' . a:action . ''': ' . len(fargs)
          \ . ', allowed: ' . string(a:nargs)
  end
endfunction "}}}

function! maque#util#doautocmd(event, ident) abort "{{{
  call maque#util#silent('doautocmd ' . a:event . ' ' . a:ident)
endfunction "}}}

function! maque#util#mautocmd(ident) abort "{{{
  call maque#util#doautocmd('User', 'Maque' . a:ident)
endfunction "}}}

function! maque#util#tautocmd(ident) abort "{{{
  call maque#util#mautocmd('Tmux' . a:ident)
endfunction "}}}
