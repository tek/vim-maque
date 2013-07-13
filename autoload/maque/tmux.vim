" user functions

function! maque#tmux#make(cmd) "{{{
  call maque#tmux#init_pane()
  let &errorfile = tempname()
  call maque#tmux#send(a:cmd)
  " send the pipe canceling command now, so that it executes as soon as the
  " make command is finished
  call maque#tmux#send('tmux '.s:pipe_cmd())
  " initiate the pipe to the errorfile after starting the command, so that it
  " doesn't contain the command line
  call maque#tmux#pipe_to_file(&errorfile)
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

function! maque#tmux#create_pane() "{{{
  if g:maque_tmux_vertical
    ScreenShellVertical
  else
    ScreenShell
  endif
endfunction "}}}

function! maque#tmux#init_pane() "{{{
  if !maque#tmux#pane_open()
    if !g:ScreenShellActive
      call maque#tmux#create_pane()
    else
      ScreenShellReopen
    endif
    call maque#tmux#send('cd '.g:pwd)
  endif
endfunction "}}}

function! maque#tmux#pane_open() abort "{{{
  return index(s:panes(), s:pane()) >= 0
endfunction "}}}

function! maque#tmux#close() "{{{
  call s:tmux('kill-pane -t '.s:pane())
endfunction "}}}

function! maque#tmux#toggle_pane() "{{{
  if maque#tmux#pane_open()
    call maque#tmux#close()
  else
    call maque#tmux#init_pane()
  endif
endfunction "}}}

let g:maque#tmux#escape_filter = "sed -u -e \"s/\r//g\" -e \"s/\e[[0-9;]*m//g\""

function! maque#tmux#pipe_to_file(fname, ...) "{{{
  let filter_escape_sequences = a:0 && a:1
  let redirect = ' > '.fname
  if filter_escape_sequences
    let redirect = g:maque#tmux#escape_filter . redirect
  endif
  call s:tmux(s:pipe_cmd().' '.shellescape(redirect))
endfunction "}}}

function! s:tmux(cmd) "{{{
  let cmd = 'tmux ' .
        \ (exists('g:ScreenShellSession') ? '-S '.g:ScreenShellSession . ' ' : '') .
        \ a:cmd
  return system(cmd)
endfunction "}}}

function! s:pane() "{{{
  return exists('g:ScreenShellTmuxPane') ? g:ScreenShellTmuxPane : -1
endfunction "}}}

function! s:panes() "{{{
  return split(s:tmux('list-panes -F "#{pane_id}"'), "\n")
endfunction "}}}

function! s:pipe_cmd() "{{{
  return 'pipe-pane -t '.s:pane()
endfunction "}}}

" make everything public, keep s: functions for brevity

function! maque#tmux#tmux(cmd) "{{{
  return s:tmux(a:cmd)
endfunction "}}}

function! maque#tmux#pane() "{{{
  return s:pane()
endfunction "}}}

function! maque#tmux#panes() "{{{
  return s:panes()
endfunction "}}}
