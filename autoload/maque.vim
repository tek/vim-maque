function! maque#make(...) "{{{
  let command = 'main'
  if a:0 && len(a:1)
    if has_key(maque#commands(), a:1)
      let command = a:1
    else
      let g:maqueprg = a:1
    endif
  endif
  return maque#run_command(command)
endfunction "}}}

function! maque#make_aux(cmd, ...) "{{{
  let handler = get(a:000, 0, g:maque_handler)
  let Handler = maque#util#handler_function('make_aux', '', handler)
  if type(Handler) == 2
    return Handler(a:cmd)
  else
    call maque#util#warn('no handler for aux cmds!')
  endif
endfunction "}}}

function! maque#make_auto(...) "{{{
  if maque#set_makeprg()
    call maque#dispatch#focus()
    return maque#make()
  endif
endfunction "}}}

function! maque#make_pane(pane, cmd, ...) "{{{
  let handler = get(a:000, 0, g:maque_handler)
  let Handler = maque#util#handler_function('make_pane', '', handler)
  if type(Handler) == 2
    call Handler(a:pane, a:cmd)
  else
    call maque#util#warn('no handler for executing commands in a pane!')
  endif
endfunction "}}}

function! maque#set_makeprg() "{{{
  let Setter = maque#util#lookup(
        \ 'b:maque_makeprg_setter',
        \ 'g:maque_makeprg_setter',
        \ 'maque#ft#'.maque#filetype().'#set_makeprg',
        \ 'maque#set_generic_makeprg'
        \ )
  return Setter()
endfunction "}}}

function! maque#set_generic_makeprg() "{{{
  if &makeprg != 'make' || g:maque_use_make_fallback
    call maque#util#warn('no makeprg setter found! Using generic settings.')
    return maque#set_params()
  else
    call maque#util#warn('no makeprg setter found! Aborting.')
  end
endfunction "}}}

function! maque#remove_errorfile() "{{{
  exe 'silent !'.'rm -f '.&ef
  redraw!
endfunction "}}}

function! maque#query() "{{{
  let fname = input('File name: ', '', 'file')
  call maque#set_params(fname)
endfunction "}}}

function! maque#handle_errors() abort "{{{
  if empty(getqflist())
    call maque#util#warn('no errors!')
  else
    if g:maque_errors_in_status
      call g:maque_status.execute('copen')
    else
      copen
    endif
    call maque#jump_to_error()
  endif
endfunction "}}}

function! maque#parse(...) "{{{
  if call('maque#'.g:maque_handler.'#parse', a:000)
    return maque#handle_errors()
  endif
endfunction "}}}

function! maque#cycle() "{{{
  let h_index = index(g:maque_handlers, g:maque_handler)
  let h_index = (h_index + 1) % len(g:maque_handlers)
  let g:maque_handler = g:maque_handlers[h_index]
  echo 'selected maque handler "'.g:maque_handler.'".'
endfunction "}}}

function! maque#cwd_error_index() "{{{
  let last = g:maque_jump_to_error == 'last'
  let error_list = getqflist()
  if last
    call reverse(error_list)
  endif
  for error in error_list
    if maque#util#buffer_is_in_project(error.bufnr)
      return index(getqflist(), error) + 1
    endif
  endfor
  return last ? len(error_list) : 1
endfunction "}}}

function! maque#jump_to_error() "{{{
  if len(g:maque_jump_to_error)
    if g:maque_seek_cwd_error
      let index = maque#cwd_error_index()
      execute 'cc! '.index
    else
      execute 'c'.g:maque_jump_to_error
    endif
    normal! zv
  endif
endfunction "}}}

function! maque#set_params(...) "{{{
  let cmdline = maque#prefix(&makeprg) . &makeprg . ' ' . maque#args()
        \ . ' ' . get(a:000, 0, '')
  let g:maqueprg = substitute(cmdline, '\v^\s+|\s+$|\s\zs\s+', '', 'g')
  return 1
endfunction "}}}

function! maque#add_command(name, cmd, ...) "{{{
  let args = a:0 ? a:1 : {}
  if has_key(maque#commands(), a:name)
    call maque#util#warn('command "'.a:name.'" already created!')
  else
    let commands = maque#commands()
    let commands[a:name] = maque#command#new(a:cmd, a:name, args)
  endif
  return maque#command(a:name)
endfunction "}}}

function! maque#add_vim_command(name, cmd, ...) abort "{{{
  let args = a:0 ? a:1 : {}
  if has_key(maque#commands(), a:name)
    call maque#util#warn('command "'.a:name.'" already created!')
  else
    let commands = maque#commands()
    let commands[a:name] = maque#command#new_vim_command(a:cmd, a:name, args)
  endif
  return maque#command(a:name)
endfunction "}}}

function! maque#run_command(name) "{{{
  if has_key(maque#commands(), a:name)
    call maque#command(a:name).make()
  else
    call maque#util#warn('no such command: '.a:name)
  endif
endfunction "}}}

function! maque#toggle_command(name) abort "{{{
  if has_key(maque#commands(), a:name)
    call maque#command(a:name).toggle()
  else
    call maque#util#warn('no such command: '.a:name)
  endif
endfunction "}}}

function! maque#set_main_command(command) abort "{{{
    let g:maqueprg = a:command.command()
endfunction "}}}

function! maque#set_main_command_name(name) "{{{
  if has_key(maque#commands(), a:name)
    return maque#set_main_command(maque#commands()[a:name])
  else
    call maque#util#warn('no such command: '.a:name)
  endif
endfunction "}}}

function! maque#add_service_pane(name, layout, params) abort "{{{
  let Handler = maque#util#handler_function('add_service_pane_in_layout', '')
  if type(Handler) == 2
    call Handler(a:name, a:layout, a:params)
  else
    call maque#util#warn('no handler for executing service in a pane!')
  endif
endfunction "}}}

function! s:pop(dict, key, ...) abort "{{{
  let value = get(a:dict, a:key, get(a:000, 0))
  if has_key(a:dict, a:key)
    unlet a:dict[a:key]
  endif
  return value
endfunction "}}}

function! maque#process_service_args(args) abort "{{{
  let pane = get(a:args, 1, {})
  let generic = {
        \ 'command': a:args[0],
        \ 'start': s:pop(pane, 'start'),
        \ 'layout': s:pop(pane, 'layout', 'make'),
        \ }
  let generic.name = s:pop(pane, 'name', split(generic['command'], ' ')[0])
  let cmd = {
        \ 'compiler': s:pop(pane, 'compiler', ''),
        \ 'name': generic['name'],
        \ 'pane': generic['name'],
        \ }
  return [generic, pane, cmd]
endfunction "}}}

function! maque#create_service(generic, pane, cmd) abort "{{{
  call maque#add_service_pane(a:generic.name, a:generic.layout, a:pane)
  call maque#add_command(a:generic.name, a:generic.command, a:cmd)
  if a:generic.start && maque#autostart_ok()
    call maque#run_command(a:generic.name)
  endif
endfunction "}}}

function! maque#_add_service(args) abort "{{{
  let [success, args] = maque#util#parse_args(a:args, 1, 2)
  if success
    return call('maque#create_service', maque#process_service_args(args))
  endif
endfunction "}}}

function! maque#add_service(args) abort "{{{
  return maque#util#schedule('maque#_add_service', [a:args])
endfunction "}}}

function! maque#_add_captured_service(args) abort "{{{
  let [success, args] = maque#util#parse_args(a:args, 1, 2)
  if success
    let [generic, pane, cmd] = maque#process_service_args(args)
    let override = {
          \ 'manual_termination': 1,
          \ 'capture': 1,
          \ }
    augroup maque_services
      execute 'autocmd User MaqueTmuxMake MaqueTmuxResetCapture ' .
            \ generic.name
    augroup END
    let pane = extend(override, pane)
    return maque#create_service(generic, pane, cmd)
  end
endfunction "}}}

function! maque#add_captured_service(args) abort "{{{
  return maque#util#schedule('maque#_add_captured_service', [a:args])
endfunction "}}}

function! maque#process_command_args(args) abort "{{{
  let cmd = a:args[0]
  let params = get(a:args, 1, {})
  let name = s:pop(params, 'name', split(cmd, ' ')[0])
  if !has_key(params, 'pane')
    let params['pane'] = 'main'
  endif
  return [name, cmd, params]
endfunction "}}}

function! maque#add_command_cmd(args) abort "{{{
  let [success, args] = maque#util#parse_args(a:args, 1, 2)
  if success
    let [name, cmd, params] = maque#process_command_args(args)
    call maque#add_command(name, cmd, params)
  endif
endfunction "}}}

function! maque#initialized() abort "{{{
  let Handler = maque#util#handler_function('initialized', 'maque#util#true')
  return Handler()
endfunction "}}}

function! maque#dummy_pane(...) "{{{
  let pane = { 'name': g:maque_handler }

  function! pane.description() dict "{{{
    return 'dummy pane ('.self.name .')'
  endfunction "}}}

  function! pane.create() dict "{{{
  endfunction "}}}

  function! pane.make(...) dict "{{{
    call call('maque#make', a:000)
  endfunction "}}}

  function! pane.toggle(...) abort dict "{{{
  endfunction "}}}

  return pane
endfunction "}}}

function! maque#commands() "{{{
  if !exists('g:maque_commands')
    let g:maque_commands = {}
  endif
  return g:maque_commands
endfunction "}}}

function! maque#command(name) "{{{
  return maque#commands()[a:name]
endfunction "}}}

function! maque#pane(name, ...) "{{{
  let handler = get(a:000, 0, g:maque_handler)
  let Pane = maque#util#handler_function('pane', 'maque#dummy_pane', handler)
  return Pane(a:name)
endfunction "}}}

" TODO dummy_layout
function! maque#layout(name, ...) "{{{
  let handler = get(a:000, 0, g:maque_handler)
  let Layout = maque#util#handler_function('layout', 'maque#dummy_layout',
        \ handler)
  return Layout(a:name)
endfunction "}}}

function! maque#current_pane(...) "{{{
  let handler = get(a:000, 0, g:maque_handler)
  let Pane = maque#util#handler_function('current_pane', 'maque#dummy_pane', handler)
  return Pane()
endfunction "}}}

function! maque#args() "{{{
  return maque#util#variable('maque_args_'.&makeprg)
endfunction "}}}

function! maque#prefix(cmd) abort "{{{
  return get(g:, 'maque_prefix_' . a:cmd, '')
endfunction "}}}

function! maque#prg() "{{{
  if !exists('g:maqueprg')
    call maque#set_params('')
  endif
  return g:maqueprg
endfunction "}}}

function! maque#filetype() "{{{
  return exists('b:maque_filetype') ? b:maque_filetype : &filetype
endfunction "}}}

function! maque#restart_command(name) "{{{
  if has_key(maque#commands(), a:name)
    call maque#command(a:name).restart()
  else
    call maque#util#warn('no such command: '.a:name)
  endif
endfunction "}}}

function! maque#kill_command(name) "{{{
  if has_key(maque#commands(), a:name)
    call maque#command(a:name).kill()
  else
    call maque#util#warn('no such command: '.a:name)
  endif
endfunction "}}}

function! maque#save_maqueprg() abort "{{{
  if exists('g:maqueprg')
    let g:Maque_maqueprg_save = g:maqueprg
  endif
  silent! doautocmd VimLeavePre obsession
endfunction "}}}

function! maque#load_maqueprg() abort "{{{
  if exists('g:Maque_maqueprg_save')
    if !exists('g:maqueprg')
      let g:maqueprg = g:Maque_maqueprg_save
    endif
    unlet g:Maque_maqueprg_save
  endif
endfunction "}}}

function! maque#make_line(...) abort "{{{
  call maque#ft#common#set_line()
  return maque#make()
endfunction "}}}

function! maque#make_file(...) abort "{{{
  call maque#ft#common#set_file()
  return maque#make()
endfunction "}}}

function! maque#make_all(...) abort "{{{
  call maque#set_params()
  return maque#make()
endfunction "}}}

function! maque#autostart_ok() abort "{{{
  return !argc()
endfunction "}}}
