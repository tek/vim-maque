" user functions

function! s:warn(msg) "{{{
  echohl WarningMsg
  echo a:msg
  echohl None
endfunction "}}}

function! maque#tmux#make(cmd) "{{{
  let pane = s:pane()
  if !pane.open()
    call pane.create()
  endif
  call pane.make(a:cmd)
endfunction "}}}

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

function! maque#tmux#toggle_pane() "{{{
  call s:pane().toggle()
endfunction "}}}

function! maque#tmux#cycle_panes() "{{{
  let names = sort(keys(g:maque#tmux#panes))
  let current = index(names, g:maque#tmux#current_pane)
  let new_index = (current + 1) % len(g:maque#tmux#panes)
  let g:maque#tmux#current_pane = names[new_index]
  echo 'maque: selected pane "'.s:pane().name .'".'
endfunction "}}}

function! maque#tmux#close_all() "{{{
  for pane in values(g:maque#tmux#panes)
    echo pane
    call pane.close()
  endfor
endfunction "}}}

" internals

let g:maque#tmux#panes = {
      \ 'main': maque#tmux#pane#new('main', g:maque_tmux_split_cmd)
      \ }
let g:maque#tmux#current_pane = 'main'

function! s:pane() "{{{
  let name = g:maque#tmux#current_pane
  if has_key(g:maque#tmux#panes, s:buffer())
    let name = s:buffer()
  endif
  return g:maque#tmux#panes[name]
endfunction "}}}

function! maque#tmux#command(cmd) "{{{
  return system('tmux '.a:cmd)
endfunction "}}}

function! maque#tmux#create_buffer_pane(...) "{{{
  let splitter = a:0 ? a:1 : g:maque_tmux_split_cmd
  if has_key(g:maque#tmux#panes, s:buffer())
    call s:warn('maque: buffer pane already created!')
  else
    let g:maque#tmux#panes[s:buffer()] = maque#tmux#pane#new(s:buffer(),
          \ splitter)
  endif
endfunction "}}}

function! maque#tmux#delete_buffer_pane() "{{{
  if has_key(g:maque#tmux#panes, s:buffer())
    unlet g:maque#tmux#panes[s:buffer()]
  endif
endfunction "}}}

function! maque#tmux#add_pane(name, ...) "{{{
  let splitter = a:0 ? a:1 : g:maque_tmux_split_cmd
  if has_key(g:maque#tmux#panes, s:buffer())
    call s:warn('maque: pane "'.a:name.'" already created!')
  else
    let g:maque#tmux#panes[a:name] = maque#tmux#pane#new(a:name, splitter)
    let g:maque#tmux#current_pane = a:name
  endif
endfunction "}}}

function! s:buffer() "{{{
  return 'buffer'.bufnr('%')
endfunction "}}}

augroup maque_tmux
  autocmd!
  autocmd VimLeave * call maque#tmux#close_all()
augroup END
