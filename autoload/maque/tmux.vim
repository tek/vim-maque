" public functions

" TODO always call determine_target_pane(a:000), refactor
" use abort

" execute a command in the active pane, creating it if necessary
function! maque#tmux#make(cmd) "{{{
  call maque#tmux#make_pane(s:pane(), a:cmd)
endfunction "}}}

function! maque#tmux#make_aux(cmd) "{{{
  call maque#tmux#make_pane(s:aux_pane(), a:cmd)
endfunction "}}}

function! maque#tmux#make_in(pane, cmd) "{{{
  call maque#tmux#make_pane(g:maque_tmux_panes[a:pane], a:cmd)
endfunction "}}}

function! maque#tmux#make_pane(pane, cmd) "{{{
  call maque#tmux#pane#enable_cache()
  call a:pane.create()
  call a:pane.make(a:cmd)
  call maque#tmux#pane#disable_cache()
endfunction "}}}

" parse the active pane's last command's output into the quickfix list
function! maque#tmux#parse(...) "{{{
  let pane = a:0 ? g:maque_tmux_panes[a:1] : maque#tmux#error_pane()
  if filereadable(pane.errorfile)
    execute 'cgetfile'.pane.errorfile
    if empty(getqflist())
      call maque#util#warn('no errors!')
    else
      copen
      call maque#jump_to_error()
    endif
  endif
endfunction "}}}

" destroy or (re)create the active pane
function! maque#tmux#toggle_pane() "{{{
  call s:pane().toggle()
endfunction "}}}

" destroy the active pane
function! maque#tmux#close_pane() "{{{
  call s:pane().close()
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

function! maque#tmux#add_layout(name, ...) "{{{
  if has_key(g:maque_tmux_layouts, a:name)
    call maque#util#warn('layout "'.a:name.'" already created!')
  else
    let params = a:0 ? a:1 : {}
    let g:maque_tmux_layouts[a:name] = maque#tmux#layout#new(a:name, params)
  endif
  return maque#layout(a:name)
endfunction "}}}

" kill the process running in the active pane
function! maque#tmux#kill(...) "{{{
  call call(s:pane().kill, a:000, s:pane())
endfunction "}}}

" toggle the specified pane, default to active
function! maque#tmux#toggle(...) "{{{
  let name = a:0 ? a:1 : ''
  let pane = get(g:maque_tmux_panes, name, s:pane())
  call pane.toggle()
endfunction "}}}

" reset the capture buffer for the specified pane, default to active
function! maque#tmux#reset_capture(...) "{{{
  let name = a:0 ? a:1 : ''
  let pane = get(g:maque_tmux_panes, name, s:pane())
  call pane.reset_capture()
endfunction "}}}

function! maque#tmux#pane(name) "{{{
  return get(g:maque_tmux_panes, a:name)
endfunction "}}}

function! maque#tmux#layout(name) "{{{
  return get(g:maque_tmux_layouts, a:name)
endfunction "}}}

function! maque#tmux#current_pane() "{{{
  return s:pane()
endfunction "}}}

" internals

function! maque#tmux#command(cmd, ...) "{{{
  let blocking = get(a:000, 0)
  if blocking || !maque#util#want_async()
    return maque#tmux#command_output(a:cmd)
  else
    call vimproc#system_bg('tmux '.a:cmd)
  endif
endfunction "}}}

function! maque#tmux#command_output(cmd) "{{{
  return system('tmux '.a:cmd)
endfunction "}}}

function! maque#tmux#close_all() "{{{
  let g:maque_async = 0
  if exists('g:maque_tmux_panes')
    for pane in values(g:maque_tmux_panes)
      if pane.name != 'vim'
        call pane.close()
      endif
    endfor
  endif
endfunction "}}}

function! maque#tmux#error_pane() "{{{
  return g:maque_tmux_error_pane == 'main' ? s:pane() : maque#tmux#pane(g:maque_tmux_error_pane)
endfunction "}}}

function! maque#tmux#vim_id() abort "{{{
  let cmd = 'list-panes -F "#{pane_pid} #{pane_id}"'
  let panes = split(maque#tmux#command_output(cmd), "\n")
  let data = map(panes, 'split(v:val)')
  let pid = getpid()
  for item in data
    let children = maque#util#child_pids(item[0])
    if len(children) && children[0] == pid
      return item[1]
    endif
  endfor
endfunction "}}}

function! s:pane() "{{{
  let name = g:maque_tmux_current_pane
  if has_key(g:maque_tmux_panes, s:buffer())
    let name = s:buffer()
  endif
  return get(g:maque_tmux_panes, name, maque#dummy_pane())
endfunction "}}}

function! s:aux_pane() "{{{
  return get(g:maque_tmux_panes, 'aux', s:pane())
endfunction "}}}

function! s:buffer() "{{{
  return 'buffer'.bufnr('%')
endfunction "}}}
