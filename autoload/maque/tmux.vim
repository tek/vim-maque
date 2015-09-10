" public functions

" TODO always call determine_target_pane(a:000), refactor
" use abort

" execute a command in the active pane, creating it if necessary
function! maque#tmux#make(cmd) "{{{
  call maque#tmux#make_pane(s:pane(), a:cmd)
endfunction "}}}

" run the commandline 'a:cmd' in the pane named 'a:pane'
function! maque#tmux#make_in(pane, cmd) "{{{
  call maque#tmux#make_pane(g:maque_tmux_panes[a:pane], a:cmd)
endfunction "}}}

" run the commandline 'a:cmd' in the pane object 'a:pane'
" uses the tmux pane cache to avoid multiple invocations of `tmux list-panes`
" with identical results
function! maque#tmux#make_pane(pane, cmd, ...) "{{{
  let replace = a:0 ? a:1 : 1
  let g:maque_making_pane = a:pane.name
  let g:maque_making_cmdline = a:cmd
  silent doautocmd User MaqueTmuxMake
  call maque#tmux#pane#enable_cache()
  call a:pane.create_and_make(a:cmd, replace)
  call maque#tmux#pane#disable_cache()
  unlet g:maque_making_pane
  unlet g:maque_making_cmdline
endfunction "}}}

" parse the active pane's last command's output into the quickfix list
function! maque#tmux#parse(...) "{{{
  let pane = maque#tmux#pane(get(a:000, 0, ''), maque#tmux#error_pane())
  if filereadable(pane.errorfile)
    let override_compiler = len(pane.compiler) > 0
    if override_compiler
      let compiler_before = get(b:, 'current_compiler', '')
      execute 'compiler ' . pane.compiler
    endif
    execute 'cgetfile '.pane.errorfile
    if g:maque_errors_in_status
      call g:maque_status.execute('compiler ' . pane.compiler)
      call g:maque_status.execute('cgetfile ' . pane.errorfile)
    endif
    if override_compiler && len(compiler_before)
      execute 'compiler ' . compiler_before
    endif
    return 1
  endif
endfunction "}}}

" activate the next pane, alphabetically
function! maque#tmux#cycle_panes() "{{{
  let names = sort(keys(g:maque_tmux_panes))
  let current = index(names, g:maque_tmux_current_pane)
  let new_index = (current + 1) % len(g:maque_tmux_panes)
  let g:maque_tmux_current_pane = names[new_index]
  echo 'maque: selected pane "'.s:pane().name .'".'
endfunction "}}}

" create a pane and restrict interaction from the current buffer to it
function! maque#tmux#create_buffer_pane(...) "{{{
  if has_key(g:maque_tmux_panes, s:buffer())
    call maque#util#warn('buffer pane already created!')
  else
    let params = a:0 ? a:1 : {}
    call maque#tmux#add_pane(s:buffer(), params)
  endif
endfunction "}}}

" remove this buffer's pane association
function! maque#tmux#delete_buffer_pane() "{{{
  if has_key(g:maque_tmux_panes, s:buffer())
    unlet g:maque_tmux_panes[s:buffer()]
  endif
endfunction "}}}

" add a new named pane, pass additional args to pane constructor
function! maque#tmux#add_pane(name, ...) "{{{
  if has_key(g:maque_tmux_panes, a:name)
    call maque#util#warn('pane "'.a:name.'" already created!')
  else
    let params = a:0 ? a:1 : {}
    let g:maque_tmux_panes[a:name] = maque#tmux#pane#new(a:name, params)
  endif
  return maque#pane(a:name)
endfunction "}}}

" add new pane and attach to layout
function! maque#tmux#_add_pane_in_layout(name, layout, ...) abort "{{{
  let params = a:0 ? a:1 : {}
  let pane = maque#tmux#add_pane(a:name, params)
  return maque#tmux#add_pane_to_layout(a:layout, pane)
endfunction "}}}

function! maque#tmux#add_pane_in_layout(...) abort "{{{
  return maque#util#schedule('maque#tmux#_add_pane_in_layout', a:000)
endfunction "}}}

function! maque#tmux#_add_service_pane_in_layout(name, layout, ...) abort "{{{
  let params = a:0 ? a:1 : {}
  let params = extend({
        \ 'create_minimized': 1,
        \ 'minimized_size': 2,
        \ 'capture': 0,
        \ 'restore_on_make': 0,
        \ }, params)
  return maque#tmux#add_pane_in_layout(a:name, a:layout, params)
endfunction "}}}

function! maque#tmux#add_service_pane_in_layout(...) abort "{{{
  return maque#util#schedule('maque#tmux#_add_service_pane_in_layout', a:000)
endfunction "}}}

" add a pane for the main vim
function! maque#tmux#add_vim_pane(...) "{{{
  let name = 'vim'
  if !has_key(g:maque_tmux_panes, name)
    let params = a:0 ? a:1 : {}
    let g:maque_tmux_panes[name] = maque#tmux#pane#new_vim(params)
  endif
  return maque#pane(name)
endfunction "}}}

function! maque#tmux#add_layout(name, ...) "{{{
  if has_key(g:maque_tmux_layouts, a:name)
    call maque#util#warn('layout "'.a:name.'" already created!')
  else
    let params = a:0 ? a:1 : {}
    let g:maque_tmux_layouts[a:name] = maque#tmux#layout#new(a:name, params)
  endif
  return maque#layout(a:name)
endfunction "}}}

function! maque#tmux#add_window(name, ...) "{{{
  if has_key(g:maque_tmux_layouts, a:name)
    call maque#util#warn('layout "'.a:name.'" already created!')
  else
    let params = a:0 ? a:1 : {}
    let g:maque_tmux_layouts[a:name] =
          \ maque#tmux#layout#new_window(a:name, params)
  endif
  return maque#layout(a:name)
endfunction "}}}

function! maque#tmux#add_pane_to_layout(name, pane) abort "{{{
  if !has_key(g:maque_tmux_layouts, a:name)
    call maque#util#warn('layout "'.a:name.'" doesn''t exist!')
  else
    call g:maque_tmux_layouts[a:name].add(a:pane)
  endif
  return a:pane
endfunction "}}}

function! maque#tmux#call_pane(params) abort "{{{
  let name = get(a:params, 'name', '')
  let action = get(a:params, 'action', 'open')
  let args = get(a:params, 'args', [])
  let pane = get(g:maque_tmux_panes, name, s:pane())
  call maque#tmux#pane#enable_cache()
  call call(pane[action], args, pane)
  call maque#tmux#pane#disable_cache()
endfunction "}}}

function! maque#tmux#pane_action(action, ...) abort "{{{
  if !a:0 || a:1 == '' || has_key(g:maque_tmux_panes, a:1)
    let name = get(a:000, 0, '')
    call maque#tmux#call_pane({'name': name, 'action': a:action})
  endif
endfunction "}}}

function! maque#tmux#layout_action(action, ...) abort "{{{
  call maque#tmux#pane#enable_cache()
  let name = get(a:000, 0, '')
  let layout = get(g:maque_tmux_layouts, name, s:layout())
  call call(layout[a:action], [], layout)
  call maque#tmux#pane#disable_cache()
endfunction "}}}

function! maque#tmux#toggle_layout(...) abort "{{{
  return call('maque#tmux#layout_action', ['toggle'] + a:000)
endfunction "}}}

function! maque#tmux#minimize_layout(...) abort "{{{
  return call('maque#tmux#layout_action', ['minimize'] + a:000)
endfunction "}}}

" kill the running process
function! maque#tmux#kill(...) "{{{
  return call('maque#tmux#pane_action', ['kill'] + a:000)
endfunction "}}}

" kill the running process and wait until it is dead
function! maque#tmux#kill_wait(...) "{{{
  return maque#tmux#pane_action('kill_wait')
endfunction "}}}

" minimize a pane
function! maque#tmux#minimize(...) "{{{
  return call('maque#tmux#pane_action', ['minimize'] + a:000)
endfunction "}}}

function! maque#tmux#minimize_pane(...) abort "{{{
  return call('maque#tmux#minimize', a:000)
endfunction "}}}

" kill the process running in the active pane with all available signals until
" it is dead
function! maque#tmux#kill_all(...) "{{{
  return call('maque#tmux#pane_action', ['kill_wait'] + a:000)
endfunction "}}}

" toggle the specified pane, default to active
function! maque#tmux#toggle_pane(...) "{{{
  return call('maque#tmux#pane_action', ['toggle'] + a:000)
endfunction "}}}

" open the specified pane, default to active
function! maque#tmux#open(...) "{{{
  return call('maque#tmux#pane_action', ['open'] + a:000)
endfunction "}}}

" close the specified pane, default to active
function! maque#tmux#close(...) "{{{
  return call('maque#tmux#pane_action', ['close'] + a:000)
endfunction "}}}

" reset the capture buffer for the specified pane, default to active
function! maque#tmux#reset_capture(...) "{{{
  let name = a:0 ? a:1 : ''
  let pane = get(g:maque_tmux_panes, name, s:pane())
  call pane.reset_capture()
endfunction "}}}

" focus the specified pane, default to active
function! maque#tmux#focus(...) "{{{
  return call('maque#tmux#pane_action', ['focus'] + a:000)
endfunction "}}}

" restore the specified pane, default to active
function! maque#tmux#restore(...) "{{{
  return call('maque#tmux#pane_action', ['restore'] + a:000)
endfunction "}}}

" clear the specified pane, default to active
function! maque#tmux#clear_log(...) "{{{
  return call('maque#tmux#pane_action', ['clear_log'] + a:000)
endfunction "}}}

" send input to the specified pane
function! maque#tmux#send(name, msg) "{{{
  return maque#tmux#call_pane({
        \ 'name': a:name, 'action': 'send', 'args': [a:msg]})
endfunction "}}}

function! maque#tmux#_send_cmd(args) abort "{{{
  let parts = split(a:args, '^\S\+\zs\s')
  if len(parts) > 1
    let [name, msg] = parts
    return maque#tmux#send(name, msg)
  else
    call maque#util#warn('Usage: MaqueTmuxSend <pane> <message>')
  endif
endfunction "}}}

function! maque#tmux#pane(name, ...) "{{{
  return get(g:maque_tmux_panes, a:name, get(a:000, 0))
endfunction "}}}

function! maque#tmux#layout(name) "{{{
  return get(g:maque_tmux_layouts, a:name)
endfunction "}}}

function! maque#tmux#current_pane() "{{{
  return s:pane()
endfunction "}}}

" internals

function! maque#tmux#command(cmd, ...) "{{{
  call maque#util#debug(a:cmd)
  let blocking = get(a:000, 0)
  return maque#util#system('tmux '.a:cmd, blocking)
endfunction "}}}

function! maque#tmux#command_output(cmd) "{{{
  return maque#tmux#command(a:cmd, 1)
endfunction "}}}

function! maque#tmux#close_all() "{{{
  let g:maque_async = 0
  let g:maque_tmux_exiting = 1
  if exists('g:maque_tmux_panes')
    for pane in values(g:maque_tmux_panes)
      if pane.name != 'vim'
        call pane.close()
      endif
    endfor
  endif
endfunction "}}}

function! maque#tmux#error_pane() "{{{
  return g:maque_tmux_error_pane == 'main' ? s:pane() :
        \ maque#tmux#pane(g:maque_tmux_error_pane)
endfunction "}}}

function! maque#tmux#vim_id() abort "{{{
  let pid = getpid()
  call maque#util#debug('Vim pid: ' . pid)
  let panes = maque#tmux#pane#all(1)
  for pane in values(panes)
    let children = maque#util#child_pids(pane.pid)
    if len(children) && children[0][0] == pid
      return pane.id
    endif
  endfor
endfunction "}}}

function! maque#tmux#wait_for_vim_id() abort "{{{
  call maque#util#wait_until("maque#tmux#is_valid_id(maque#tmux#vim_id())", 2)
  let id = maque#tmux#vim_id()
  if !maque#tmux#is_valid_id(id)
    throw 'could not determine vim''s pane id'
  endif
  return id
endfunction "}}}

function! maque#tmux#initialized() abort "{{{
  return exists('g:maque_tmux_layout_done')
endfunction "}}}

function! maque#tmux#finish_init() abort "{{{
  let g:maque_tmux_panes_created = 1
  call maque#util#run_scheduled_tasks()
endfunction "}}}

function! maque#tmux#is_valid_id(id) abort "{{{
  return a:id =~ '^%\d\+$'
endfunction "}}}

function! s:pane() "{{{
  let name = g:maque_tmux_current_pane
  if has_key(g:maque_tmux_panes, s:buffer())
    let name = s:buffer()
  endif
  return get(g:maque_tmux_panes, name, maque#dummy_pane())
endfunction "}}}

function! s:layout() abort "{{{
  return get(g:maque_tmux_layouts, 'make')
endfunction "}}}

function! s:buffer() "{{{
  return 'buffer'.bufnr('%')
endfunction "}}}
