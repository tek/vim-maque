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
  call maque#util#silent('doautocmd User MaqueTmuxMake')
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
    call maque#util#warn(
          \ 'layout "' . a:name . '" doesn''t exist(adding pane ' .
          \ a:pane.name . ')')
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
    call maque#tmux#call_pane(
      \ { 'name': name, 'action': a:action, 'args': a:000[1:] }
      \ )
  endif
endfunction "}}}

function! maque#tmux#layout_action(action, nargs, args) abort "{{{
  call maque#tmux#pane#enable_cache()
  try
    let fargs = maque#util#fargs(a:action, a:nargs, a:args)
    let name = get(fargs, 0, '')
    let layout = get(g:maque_tmux_layouts, name, s:layout())
    call call(layout[a:action], fargs[1:], layout)
  catch /wrong argument count/
    call maque#util#error(v:exception)
  endtry
  call maque#tmux#pane#disable_cache()
endfunction "}}}

function! maque#tmux#toggle_layout(args) abort "{{{
  return maque#tmux#layout_action('toggle', [0, 1], a:args)
endfunction "}}}

function! maque#tmux#minimize_layout(args) abort "{{{
  return maque#tmux#layout_action('minimize', [0, 1], a:args)
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

function! maque#tmux#set_layout_size(args) abort "{{{
  return maque#tmux#layout_action('set_size', [2], a:args)
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
  let async = g:maque_async
  let g:maque_async = 0
  let g:maque_tmux_exiting = 1
  if exists('g:maque_tmux_panes')
    for pane in values(g:maque_tmux_panes)
      call pane.close()
    endfor
  endif
  let g:maque_tmux_exiting = 0
  let g:maque_async = async
endfunction "}}}

function! maque#tmux#error_pane() "{{{
  return g:maque_tmux_error_pane == 'main' ? s:pane() :
        \ maque#tmux#pane(g:maque_tmux_error_pane)
endfunction "}}}

function! maque#tmux#set_vim_id() abort "{{{
  let pid = getpid()
  call maque#util#debug('Vim pid: ' . pid)
  let panes = maque#tmux#pane#all(1)
  for pane in values(panes)
    let children = maque#util#child_pids(pane.pid)
    if len(children) && children[0][0] == pid
      let g:maque_vim_pane_id = pane.id
      return 1
    endif
  endfor
endfunction "}}}

function! maque#tmux#wait_for_vim_id() abort "{{{
  call maque#util#wait_until('maque#tmux#set_vim_id()', 2)
  if !exists('g:maque_vim_pane_id') ||
        \ !maque#tmux#is_valid_id(g:maque_vim_pane_id)
    throw 'could not determine vim''s pane id'
  endif
  return g:maque_vim_pane_id
endfunction "}}}

" called by autocmd MaqueTmuxPanesCreated, after
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
  return 'buffer' . bufnr('%')
endfunction "}}}

function! s:tmux(cmd) abort "{{{
  return maque#tmux#command_output(a:cmd)
endfunction "}}}

function! s:parse_tmux_output(line, vars, prefix) abort "{{{
  let values = split(a:line)
  let res = {}
  for i in range(len(a:vars))
    let key = substitute(a:vars[i], a:prefix, '', '')
    let res[key] = get(values, i)
  endfor
  return res
endfunction "}}}

function! maque#tmux#info(cmd, vars, prefix) abort "{{{
  let format = join(map(copy(a:vars), '''#{'' . v:val . ''}'''), ' ')
  let output = split(s:tmux(a:cmd . ' -F ''' . format . ''''), "\n")
  let values =
        \ map(copy(output), 's:parse_tmux_output(v:val, a:vars, a:prefix)')
  return values
endfunction "}}}

function! maque#tmux#window_info(vars) abort "{{{
  return maque#tmux#info('list-windows -t ' . g:maque_tmux_window,
        \ a:vars, 'window_')
endfunction "}}}

function! maque#tmux#vim_window_info(vars) abort "{{{
  return maque#tmux#window_info(a:vars)[g:maque_tmux_window]
endfunction "}}}

function! maque#tmux#window_size() abort "{{{
  let info = maque#tmux#vim_window_info(
        \ ['window_id', 'window_width', 'window_height'])
  return [info.width, info.height]
endfunction "}}}

function! maque#tmux#window_width() abort "{{{
  return maque#tmux#window_size()[0]
endfunction "}}}

function! maque#tmux#setup_metadata() abort "{{{
  let panes = maque#tmux#pane#all(1)
  let pane = panes[g:maque_vim.id]
  let g:maque_tmux_window = pane.window_id
endfunction "}}}

function! maque#tmux#quit() abort "{{{
  call maque#tmux#close_all()
  let g:maque_tmux_panes = {}
  let g:maque_tmux_layouts = {}
  let g:maque_tmux_panes_created = 0
endfunction "}}}

function! maque#tmux#initialized() abort "{{{
  return maque#util#want('tmux_panes_created')
endfunction "}}}

function! maque#tmux#panes_created_autocmd() abort "{{{
  let cmd = 'doautocmd User MaqueTmuxPanesCreated'
  try
    if maque#util#want_debug()
      execute cmd
    else
      execute 'silent ' . cmd
    endif
  catch //
    call maque#util#error(v:throwpoint . ': ' . v:exception)
  endtry
endfunction "}}}

function! maque#tmux#init() abort "{{{
  if !maque#tmux#initialized()
    call maque#tmux#create_basic_layout()
    if maque#util#want('tmux_default_panes')
      call maque#tmux#create_default_panes()
    endif
    call maque#tmux#setup_metadata()
    let g:maque_tmux_panes_created = 1
    call maque#tmux#panes_created_autocmd()
  endif
endfunction "}}}

function! maque#tmux#create_basic_layout() abort "{{{
  let g:maque_main_layout = maque#tmux#add_layout('main', {
        \ 'direction': 'horizontal',
        \ }
        \ )
  let g:maque_vim_layout = maque#tmux#add_layout('vim', {
        \ 'direction': 'vertical',
        \ }
        \ )
  let g:maque_vim = maque#tmux#add_vim_pane({
        \ '_splitter': '',
        \ 'capture': 0,
        \ }
        \ )
  call g:maque_vim_layout.add(g:maque_vim)
  call g:maque_vim.open()
endfunction "}}}

function! maque#tmux#create_default_panes() abort "{{{
  let make_layout = maque#tmux#add_layout('make', {
        \ 'direction': 'vertical',
        \ }
        \ )
  call g:maque_main_layout.add(g:maque_vim_layout)
  call g:maque_main_layout.add(make_layout)
  let main = maque#tmux#_add_pane_in_layout('main', 'make', {
        \ 'eval_splitter': 1,
        \ '_splitter': 'g:maque_tmux_main_split_cmd',
        \ 'capture': 1,
        \ 'autoclose': 0,
        \ }
        \ )
  call maque#tmux#add_pane('bg', {
        \ 'eval_splitter': 1,
        \ '_splitter': 'g:maque_tmux_bg_split_cmd',
        \ 'capture': 0,
        \ 'autoclose': 1,
        \ 'minimal_shell': 1,
        \ }
        \ )
  let status = maque#tmux#_add_pane_in_layout('status', 'make', {
        \ '_splitter': 'tmux split-window -v -d',
        \ 'capture': 0,
        \ 'autoclose': 0,
        \ 'size': 15,
        \ 'minimal_shell': 1,
        \ }
        \ )
  let g:maque_tmux_current_pane = 'main'
endfunction "}}}
endfunction "}}}
