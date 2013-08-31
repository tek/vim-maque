function! maque#make(...) "{{{
  let command = 'main'
  if a:0 && len(a:1)
    if has_key(maque#commands(), a:1)
      let command = a:1
    else
      let g:maqueprg = a:1
    endif
  endif
  return maque#make_command(command)
endfunction "}}}

function! maque#make_aux(cmd) "{{{
  let Handler = maque#util#handler_function('make_aux', '')
  if type(Handler) == 2
    return Handler(a:cmd)
  else
    call maque#util#warn('no handler for aux cmds!')
  endif
endfunction "}}}

function! maque#make_auto() "{{{
  if maque#set_makeprg()
    call maque#dispatch#focus()
    return maque#make()
  endif
endfunction "}}}

function! maque#make_pane(pane, cmd) "{{{
  let Handler = maque#util#handler_function('make_pane', '')
  if type(Handler) == 2
    return Handler(a:pane, a:cmd)
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
  call maque#util#warn('no makeprg setter found! Using generic settings.')
  return maque#set_params()
endfunction "}}}

function! maque#remove_errorfile() "{{{
  exe 'silent !'.'rm -f '.&ef
  redraw!
endfunction "}}}

function! maque#query() "{{{
  let fname = input('File name: ', '', 'file')
  call maque#set_params(fname)
endfunction "}}}

function! maque#parse() "{{{
  let Parser = function('maque#'.g:maque_handler.'#parse')
  return Parser()
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
  let params = a:0 ? ' '.a:1 : ''
  let g:maqueprg = &makeprg.' '.maque#args().params
  return 1
endfunction "}}}

function! maque#add_command(name, cmd, ...) "{{{
  let args = a:0 ? a:1 : {}
  if has_key(maque#commands(), a:name)
    call maque#util#warn('command "'.a:name.'" already created!')
  else
    let commands = maque#commands()
    let commands[a:name] = maque#command#new(a:cmd, args)
  endif
  return maque#command(a:name)
endfunction "}}}

function! maque#make_command(name) "{{{
  if has_key(maque#commands(), a:name)
    call maque#command(a:name).make()
  else
    call maque#util#warn('no such command: '.a:name)
  endif
endfunction "}}}

function! maque#dummy_pane(...) "{{{
  let pane = { 'name': g:maque_handler }

  function! pane.description() dict "{{{
    return self.name
  endfunction "}}}

  function! pane.create() dict "{{{
  endfunction "}}}

  function! pane.make(...) dict "{{{
    call call('maque#make', a:000)
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

function! maque#pane(name) "{{{
  let Pane = maque#util#handler_function('pane', 'maque#dummy_pane')
  return Pane(a:name)
endfunction "}}}

function! maque#current_pane() "{{{
  let Pane = maque#util#handler_function('current_pane', 'maque#dummy_pane')
  return Pane()
endfunction "}}}

function! maque#args() "{{{
  return maque#util#variable('maque_args_'.&makeprg)
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
