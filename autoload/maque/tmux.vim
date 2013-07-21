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
  call g:maque#tmux#panes[a:pane].create()
  call g:maque#tmux#panes[a:pane].make(a:cmd)
endfunction "}}}

" parse the active pane's last command's output into the quickfix list
function! maque#tmux#parse() "{{{
  if filereadable(s:pane().errorfile)
    execute 'cgetfile'.s:pane().errorfile
    if empty(getqflist())
      call s:warn('maque: no errors!')
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
  let names = sort(keys(g:maque#tmux#panes))
  let current = index(names, g:maque#tmux#current_pane)
  let new_index = (current + 1) % len(g:maque#tmux#panes)
  let g:maque#tmux#current_pane = names[new_index]
  echo 'maque: selected pane "'.s:pane().name .'".'
endfunction "}}}

" create a pane and restrict interaction from the current buffer to it
function! maque#tmux#create_buffer_pane(...) "{{{
  let splitter = a:0 ? a:1 : g:maque_tmux_split_cmd
  if has_key(g:maque#tmux#panes, s:buffer())
    call s:warn('maque: buffer pane already created!')
  else
    let g:maque#tmux#panes[s:buffer()] = maque#tmux#pane#new(s:buffer(),
          \ splitter)
  endif
endfunction "}}}

" remove this buffer's pane association
function! maque#tmux#delete_buffer_pane() "{{{
  if has_key(g:maque#tmux#panes, s:buffer())
    unlet g:maque#tmux#panes[s:buffer()]
  endif
endfunction "}}}

" add a new named pane, pass additional args to pane constructor
function! maque#tmux#add_pane(name, ...) "{{{
  if has_key(g:maque#tmux#panes, a:name)
    call s:warn('maque: pane "'.a:name.'" already created!')
  else
    let g:maque#tmux#panes[a:name] = call('maque#tmux#pane#new', [a:name] +
          \ a:000)
    let g:maque#tmux#current_pane = a:name
  endif
endfunction "}}}

" kill the process running in the active pane
function! maque#tmux#kill() "{{{
  call s:pane().kill()
endfunction "}}}

" internals

if !exists('g:maque#tmux#panes')
  let g:maque#tmux#panes = {
        \ 'main': maque#tmux#pane#new('main', 0),
        \ 'aux': maque#tmux#pane#new('aux', g:maque_tmux_aux_split_cmd, 0, 1),
        \ }
  let g:maque#tmux#current_pane = 'main'
endif

function! maque#tmux#command(cmd) "{{{
  return system('tmux '.a:cmd)
endfunction "}}}

function! maque#tmux#close_all() "{{{
  for pane in values(g:maque#tmux#panes)
    call pane.close()
  endfor
endfunction "}}}

function! s:pane() "{{{
  let name = g:maque#tmux#current_pane
  if has_key(g:maque#tmux#panes, s:buffer())
    let name = s:buffer()
  endif
  return g:maque#tmux#panes[name]
endfunction "}}}

function! s:aux_pane() "{{{
  return get(g:maque#tmux#panes, 'aux', s:pane())
endfunction "}}}

function! s:buffer() "{{{
  return 'buffer'.bufnr('%')
endfunction "}}}

function! s:warn(msg) "{{{
  echohl WarningMsg
  echo a:msg
  echohl None
endfunction "}}}

augroup maque_tmux "{{{
  autocmd!
  autocmd VimLeave * call maque#tmux#close_all()
augroup END "}}}
