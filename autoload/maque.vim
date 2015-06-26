"
" This file was automatically generated by riml 0.4.0
" Modify with care!
"
function! maque#make(...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let cmd = remove(__splat_var_cpy, 0)
  else
    let cmd = ''
  endif
  let comm = g:maque_last_command
  if len(cmd)
    if has_key(maque#commands(), cmd)
      let comm = cmd
    else
      let comm = 'main'
      let g:maque_mainprg = cmd
    endif
  endif
  return maque#run_command(comm)
endfunction

function! maque#make_auto(...)
  if maque#set_makeprg()
    call maque#dispatch#focus()
    return maque#make('auto')
  endif
endfunction

function! maque#make_pane(pane, cmd, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let handler = remove(__splat_var_cpy, 0)
  else
    let handler = g:maque_handler
  endif
  let s:Handler = maque#util#handler_function('make_pane', '', handler)
  if type(s:Handler) ==# 2
    call s:Handler(a:pane, a:cmd)
  else
    call maque#util#warn('no handler for executing commands in a pane!')
  endif
endfunction

function! maque#set_makeprg()
  let s:Setter = maque#util#lookup('b:maque_makeprg_setter', 'g:maque_makeprg_setter', 'maque#ft#' . maque#filetype() . '#set_makeprg', 'maque#set_generic_makeprg')
  return s:Setter()
endfunction

function! maque#set_generic_makeprg()
  if &makeprg !=# 'make' || g:maque_use_make_fallback
    call maque#util#warn('no makeprg setter found! Using generic settings.')
    return maque#set_params()
  else
    call maque#util#warn('no makeprg setter found! Aborting.')
  endif
endfunction

function! maque#remove_errorfile()
  exe 'silent !'.'rm -f '.&ef
  redraw!
endfunction

function! maque#query()
  let fname = input('File name: ', '', 'file')
  call maque#set_params(fname)
endfunction

function! maque#handle_errors() abort
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
endfunction

function! maque#parse(...)
  if call('maque#' . g:maque_handler . '#parse', a:000)
    return maque#handle_errors()
  endif
endfunction

function! maque#cycle()
  let h_index = index(g:maque_handlers, g:maque_handler)
  let h_index = (h_index + 1) % len(g:maque_handlers)
  let g:maque_handler = g:maque_handlers[h_index]
  echo 'selected maque handler "' . g:maque_handler . '".'
endfunction

function! maque#qf_path_ignored(path) abort
  for pat in g:maque_qf_path_ignore
    if a:path =~# pat
      return 1
    endif
  endfor
endfunction

function! maque#ignore_qf_buffer(num) abort
  let path = fnamemodify(expand('#' . a:num), ':p')
  if executable('realpath')
    let path = split(maque#util#system('realpath ' . path, 1), "\n")[0]
  endif
  return !maque#util#path_is_in_project(path) || maque#qf_path_ignored(path)
endfunction

function! maque#cwd_error_index()
  let last = (g:maque_jump_to_error ==# 'last')
  let error_list = getqflist()
  if last
    call reverse(error_list)
  endif
  for error in error_list
    if !maque#ignore_qf_buffer(error.bufnr)
      return index(getqflist(), error) + 1
    endif
  endfor
  return last ? len(error_list) : 1
endfunction

function! maque#jump_to_error()
  if len(g:maque_jump_to_error)
    if g:maque_seek_cwd_error
      let index = maque#cwd_error_index()
      execute 'cc! ' . index
    else
      execute 'c' . g:maque_jump_to_error
    endif
    normal! zv
  endif
endfunction

function! maque#set_params(...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let args = remove(__splat_var_cpy, 0)
  else
    let args = ''
  endif
  let makeprg = maque#makeprg()
  let cmdline = maque#prefix(makeprg) . makeprg . ' ' . maque#args() . ' ' . args
  let g:maqueprg = substitute(cmdline, '\v^\s+|\s+$|\s\zs\s+', '', 'g')
  return 1
endfunction

function! maque#makeprg() abort
  let value = maque#util#variable('maque_makeprg')
  return len(value) ? value : &makeprg
endfunction

function! maque#apply_makeprg(makeprg) abort
  let b:maque_makeprg = a:makeprg
  let &l:makeprg = a:makeprg
endfunction

function! maque#insert_command(cmd, ...) abort
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let args = remove(__splat_var_cpy, 0)
  else
    let args = {}
  endif
  let name = a:cmd.name
  if has_key(maque#commands(), name)
    call maque#util#warn('command "' . name . '" already exists!')
  else
    let commands = maque#commands()
    let commands[name] = a:cmd
  endif
  return maque#command(name)
endfunction

function! maque#_create_command(name, cmd, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let args = remove(__splat_var_cpy, 0)
  else
    let args = {}
  endif
  return maque#insert_command(maque#command#new(a:cmd, a:name, args))
endfunction

function! maque#create_command(...) abort
  return maque#util#schedule('maque#_create_command', a:000)
endfunction

function! maque#init_command(generic, pane, command) abort
  call maque#add_service_pane(a:generic.name, a:generic.layout, a:pane)
  if a:generic.start && maque#autostart_ok()
    call maque#run_command(a:command.name)
  endif
endfunction

function! maque#add_vim_command(name, cmd, ...) abort
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let args = remove(__splat_var_cpy, 0)
  else
    let args = {}
  endif
  if has_key(maque#commands(), a:name)
    call maque#util#warn('command "' . a:name . '" already created!')
  else
    let commands = maque#commands()
    let commands[a:name] = maque#command#new_vim_command(a:cmd, a:name, args)
  endif
  return maque#command(a:name)
endfunction

function! maque#run_command(name)
  if has_key(maque#commands(), a:name)
    call maque#command(a:name).make()
  else
    call maque#util#warn('no such command: ' . a:name)
  endif
endfunction

function! maque#toggle_command(name) abort
  if has_key(maque#commands(), a:name)
    call maque#command(a:name).toggle()
  else
    call maque#util#warn('no such command: ' . a:name)
  endif
endfunction

function! maque#set_last_command(command) abort
  let g:maque_last_command = a:command.name
endfunction

function! maque#set_main_command_name(name)
  if has_key(maque#commands(), a:name)
    return maque#set_last_command(maque#commands()[a:name])
  else
    call maque#util#warn('no such command: ' . a:name)
  endif
endfunction

function! maque#add_service_pane(name, layout, params) abort
  let s:Handler = maque#util#handler_function('add_service_pane_in_layout', '')
  if type(s:Handler) ==# 2
    call s:Handler(a:name, a:layout, a:params)
  else
    call maque#util#warn('no handler for executing service in a pane!')
  endif
endfunction

function! s:pop(dic, key, ...) abort
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let default = remove(__splat_var_cpy, 0)
  else
    let default = 0
  endif
  let value = get(a:dic, a:key, default)
  if has_key(a:dic, a:key)
    unlet a:dic[a:key]
  endif
  return value
endfunction

function! maque#process_service_args(args) abort
  let pane = get(a:args, 1, {})
  let generic = {'command': a:args[0], 'start': s:pop(pane, 'start'), 'layout': s:pop(pane, 'layout', 'make')}
  let generic.name = s:pop(pane, 'name', split(generic['command'], ' ')[0])
  let cmd = {'compiler': s:pop(pane, 'compiler', ''), 'name': generic['name'], 'pane': generic['name']}
  return [generic, pane, cmd]
endfunction

function! maque#create_service(generic, pane, cmd) abort
  let comm = maque#_create_command(a:generic.name, a:generic.command, a:cmd)
  call maque#init_command(a:generic, a:pane, comm)
endfunction

function! maque#_add_service(args) abort
  let [success, new_args] = maque#util#parse_args(a:args, 1, 2)
  if success
    return call('maque#create_service', maque#process_service_args(new_args))
  endif
endfunction

function! maque#add_service(args) abort
  return maque#util#schedule('maque#_add_service', [a:args])
endfunction

function! maque#captured_service_params(generic, pane, cmd) abort
  let override = {'manual_termination': 1, 'capture': 1}
  augroup maque_services
  exe 'autocmd User MaqueTmuxMake MaqueTmuxResetCapture ' . a:generic.name
  augroup END
  let new_pane = extend(override, a:pane)
  return [a:generic, new_pane, a:cmd]
endfunction

function! maque#create_captured_service(generic, pane, cmd) abort
  return call('maque#create_service', maque#captured_service_params(a:generic, a:pane, a:cmd))
endfunction

function! maque#_add_captured_service(args) abort
  let [success, a:args] = maque#util#parse_args(a:args, 1, 2)
  if success
    return call('maque#create_captured_service', maque#process_service_args(a:args))
  endif
endfunction

function! maque#add_captured_service(args) abort
  return maque#util#schedule('maque#_add_captured_service', [a:args])
endfunction

function! maque#create_shell(generic, pane, cmd) abort
  let [new_generic, new_pane, new_cmd] = maque#captured_service_params(a:generic, a:pane, a:cmd)
  let comm = maque#command#new_shell(new_generic.command, new_generic.name, new_cmd)
  call maque#insert_command(comm)
  return maque#init_command(new_generic, new_pane, comm)
endfunction

function! maque#_add_shell(args) abort
  let [success, new_args] = maque#util#parse_args(a:args, 1, 2)
  if success
    return call('maque#create_shell', maque#process_service_args(new_args))
  endif
endfunction

function! maque#add_shell(args) abort
  return maque#util#schedule('maque#_add_shell', [a:args])
endfunction

function! maque#process_command_args(args) abort
  let cmd = a:args[0]
  let params = get(a:args, 1, {})
  let name = s:pop(params, 'name', split(cmd, ' ')[0])
  if !has_key(params, 'pane') && !has_key(params, 'pane_name')
    let params['pane_name'] = 'main'
  endif
  return [name, cmd, params]
endfunction

function! maque#create_command_cmd(args) abort
  let [success, new_args] = maque#util#parse_args(a:args, 1, 2)
  if success
    let [name, cmd, params] = maque#process_command_args(new_args)
    call maque#create_command(name, cmd, params)
  endif
endfunction

function! maque#initialized() abort
  let s:Handler = maque#util#handler_function('initialized', 'maque#util#true')
  return s:Handler()
endfunction

function! maque#dummy_pane(...)
  let pane = {'name': g:maque_handler}
  function! pane.description() dict
    return 'dummy pane (' . self.name . ')'
  endfunction
  function! pane.create() dict
  endfunction
  function! pane.make(...) dict
    return call('s:maque#make', a:000)
  endfunction
  function! pane.toggle(...) abort dict
    return 0
  endfunction
  return pane
endfunction

function! maque#commands()
  if !exists('g:maque_commands')
    let g:maque_commands = {}
  endif
  return g:maque_commands
endfunction

function! maque#command(name)
  return maque#commands()[a:name]
endfunction

function! maque#making(...) abort
  return exists('g:maque_making_command') && index(a:000, g:maque_making_command) !=# -1
endfunction

function! maque#pane(name, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let handler = remove(__splat_var_cpy, 0)
  else
    let handler = g:maque_handler
  endif
  let s:Pane = maque#util#handler_function('pane', 'maque#dummy_pane', handler)
  return s:Pane(a:name)
endfunction

function! maque#layout(name, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let handler = remove(__splat_var_cpy, 0)
  else
    let handler = g:maque_handler
  endif
  let s:Layout = maque#util#handler_function('layout', 'maque#dummy_layout', handler)
  return s:Layout(a:name)
endfunction

function! maque#current_pane(...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let handler = remove(__splat_var_cpy, 0)
  else
    let handler = g:maque_handler
  endif
  let s:Pane = maque#util#handler_function('current_pane', 'maque#dummy_pane', handler)
  return s:Pane()
endfunction

function! maque#args()
  return maque#util#variable('maque_args_' . &makeprg)
endfunction

function! maque#prefix(cmd) abort
  let cmd = substitute(a:cmd, '[-:]', '_', 'g')
  return maque#util#variable('maque_prefix_' . cmd)
endfunction

function! maque#auto_prg()
  if !exists('g:maqueprg')
    call maque#set_params('')
  endif
  return g:maqueprg
endfunction

function! maque#filetype()
  return exists('b:maque_filetype') ? b:maque_filetype : &filetype
endfunction

function! maque#restart_command(name)
  if has_key(maque#commands(), a:name)
    call maque#command(a:name).restart()
  else
    call maque#util#warn('no such command: ' . a:name)
  endif
endfunction

function! maque#kill_command(name)
  if has_key(maque#commands(), a:name)
    call maque#command(a:name).kill()
  else
    call maque#util#warn('no such command: ' . a:name)
  endif
endfunction

function! maque#save_maqueprg() abort
  if exists('g:maqueprg')
    let g:Maque_maqueprg_save = g:maqueprg
    let g:Maque_last_command_save = g:maque_last_command
  endif
  exe 'silent! doautocmd VimLeavePre obsession'
endfunction

function! maque#load_maqueprg() abort
  if exists('g:Maque_maqueprg_save')
    if !exists('g:maqueprg') || !len(g:maqueprg)
      let g:maqueprg = g:Maque_maqueprg_save
    endif
    unlet! g:Maque_maqueprg_save
  endif
  if exists('g:Maque_last_command_save')
    let g:maque_last_command = g:Maque_last_command_save
    unlet! g:Maque_last_command_save
  endif
endfunction

function! maque#make_line(...) abort
  let Setter = maque#util#lookup('maque#ft#' . maque#filetype() . '#set_line', 'maque#ft#common#set_line')
  call(Setter, [])
  return maque#make()
endfunction

function! maque#make_file(...) abort
  let Setter = maque#util#lookup('maque#ft#' . maque#filetype() . '#set_file', 'maque#ft#common#set_file')
  call(Setter, [])
  return maque#make()
endfunction

function! maque#make_all(...) abort
  call maque#set_params()
  return maque#make()
endfunction

function! maque#autostart_ok() abort
  return !argc()
endfunction
