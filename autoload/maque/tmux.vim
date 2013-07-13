" user functions

function! maque#tmux#make(cmd) "{{{
  call maque#tmux#create_pane()
  let &errorfile = tempname()
  call maque#tmux#send(a:cmd)
  " send the pipe canceling command now, so that it executes as soon as the
  " make command is finished
  call maque#tmux#send('tmux '.s:pipe_cmd())
  " initiate the pipe to the errorfile after starting the command, so that it
  " doesn't contain the command line
  call maque#tmux#pipe_to_file(&errorfile, 1)
endfunction "}}}

function! maque#tmux#parse() "{{{
  if filereadable(&errorfile)
    cgetfile
    if empty(getqflist())
      echohl WarningMsg | echo 'maque: no errors!' | echohl None
    else
      copen
      call maque#jump_to_error()
    endif
  endif
endfunction "}}}

" internals

function! maque#tmux#send(cmd) "{{{
  " execute a command in the target pane
  call s:tmux('send-keys -t '.s:pane().' "'.a:cmd.'" ENTER')
endfunction "}}}

let g:maque#tmux#pane = -1

function! maque#tmux#create_pane() "{{{
  if !maque#tmux#pane_open()
    let panes_before = s:panes()
    call s:tmux(g:maque_tmux_split_cmd)
    let matcher = 'index(panes_before, v:val) == -1'
    let matches = filter(s:panes(), matcher)
    let g:maque#tmux#pane = len(matches) > 0 ? matches[0] : -1
    call s:add_close_autocmd()
    call maque#tmux#send('cd '.g:pwd)
  endif
endfunction "}}}

function! maque#tmux#pane_open() abort "{{{
  return index(s:panes(), s:pane()) >= 0
endfunction "}}}

function! maque#tmux#close() "{{{
  augroup maque_tmux_pane
    autocmd!
  augroup END
  call s:tmux('kill-pane -t '.s:pane())
endfunction "}}}

function! maque#tmux#toggle_pane() "{{{
  if maque#tmux#pane_open()
    call maque#tmux#close()
  else
    call maque#tmux#create_pane()
  endif
endfunction "}}}

let g:maque#tmux#escape_filter = "sed -u -e \"s/\r//g\" -e \"s/\e[[0-9;]*m//g\""

function! maque#tmux#pipe_to_file(fname, filter_escape_sequences) "{{{
  let filter = a:filter_escape_sequences ? g:maque#tmux#escape_filter : 'tee'
  let redirect = filter . ' > '.a:fname
  call s:tmux(s:pipe_cmd().' '.shellescape(redirect))
endfunction "}}}

function! s:tmux(cmd) "{{{
  return system('tmux '.a:cmd)
endfunction "}}}

function! s:pane() "{{{
  return g:maque#tmux#pane
endfunction "}}}

function! s:panes() "{{{
  return split(s:tmux('list-panes -F "#{pane_id}"'), "\n")
endfunction "}}}

function! s:add_close_autocmd() "{{{
  augroup maque_tmux_pane
    autocmd!
    autocmd VimLeave * call maque#tmux#close()
  augroup END
endfunction "}}}

function! s:pipe_cmd() "{{{
  return 'pipe-pane -t '.s:pane()
endfunction "}}}

" make everything public, keep s: functions for brevity

function! maque#tmux#tmux(cmd) "{{{
  return s:tmux(a:cmd)
endfunction "}}}

function! maque#tmux#panes() "{{{
  return s:panes()
endfunction "}}}
