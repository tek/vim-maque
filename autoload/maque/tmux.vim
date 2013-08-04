" public functions

" execute a command in the active pane, creating it if necessary
function! maque#tmux#make(cmd) "{{{
  call s:pane().create()
  call s:pane().make(a:cmd)
endfunction "}}}

function! maque#tmux#make_aux(cmd) "{{{
  call s:aux_pane().create()
  call s:aux_pane().make(a:cmd)
endfunction "}}}

function! maque#tmux#make_in(pane, cmd) "{{{
  call g:maque_tmux_panes[a:pane].create()
  call g:maque_tmux_panes[a:pane].make(a:cmd)
endfunction "}}}

" parse the active pane's last command's output into the quickfix list
function! maque#tmux#parse(...) "{{{
  let pane = a:0 ? g:maque_tmux_panes[a:1] : s:pane()
  if filereadable(pane.errorfile)
    execute 'cgetfile'.pane.errorfile
    if empty(getqflist())
      call maque#util#warn('maque: no errors!')
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
    call maque#util#warn('maque: buffer pane already created!')
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
    call maque#util#warn('maque: pane "'.a:name.'" already created!')
  else
    let params = a:0 ? a:1 : {}
    let g:maque_tmux_panes[a:name] = maque#tmux#pane#new(a:name, params)
  endif
endfunction "}}}

" kill the process running in the active pane
function! maque#tmux#kill(...) "{{{
  call call(s:pane().kill, a:000, s:pane())
endfunction "}}}

function! maque#tmux#pane(name) "{{{
  return get(g:maque_tmux_panes, a:name)
endfunction "}}}

function! maque#tmux#current_pane() "{{{
  return s:pane()
endfunction "}}}

" internals

function! maque#tmux#command(cmd, ...) "{{{
  let blocking = get(a:000, 0)
  if blocking || !s:want_async()
    return system('tmux '.a:cmd)
  else
    call vimproc#system_bg('tmux '.a:cmd)
  endif
endfunction "}}}

function! maque#tmux#close_all() "{{{
  if exists('g:maque_tmux_panes')
    for pane in values(g:maque_tmux_panes)
      call pane.close()
    endfor
  endif
endfunction "}}}

function! s:pane() "{{{
  let name = g:maque_tmux_current_pane
  if has_key(g:maque_tmux_panes, s:buffer())
    let name = s:buffer()
  endif
  return get(g:maque_tmux_panes, name)
endfunction "}}}

function! s:aux_pane() "{{{
  return get(g:maque_tmux_panes, 'aux', s:pane())
endfunction "}}}

function! s:buffer() "{{{
  return 'buffer'.bufnr('%')
endfunction "}}}

function! s:want_async() "{{{
  return exists(':VimProcRead') && g:maque_tmux_async
endfunction "}}}

augroup maque_tmux "{{{
  autocmd!
  autocmd VimLeave * call maque#tmux#close_all()
augroup END "}}}
