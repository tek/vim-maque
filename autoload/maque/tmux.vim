function! maque#tmux#send(cmd) "{{{
  call system('tmux send-keys -t '.g:ScreenShellTmuxPane.' "'.a:cmd.'" ENTER')
endfunction "}}}

function! maque#tmux#init_pane() "{{{
  if !g:ScreenShellActive
    if g:maque_tmux_vertical
      ScreenShellVertical
    else
      ScreenShell
    endif
    call maque#tmux#send('cd '.g:pwd)
  endif
endfunction "}}}

function! maque#tmux#make(cmd) "{{{
  call maque#tmux#init_pane()
  let &errorfile = tempname()
  let pipe_cmd = 'tmux pipe-pane -t '.g:ScreenShellTmuxPane
  let filter = "sed -u -e \"s/\r//g\" -e \"s/\e[[0-9;]*m//g\" > ".&errorfile
  call maque#tmux#send(a:cmd.';'.pipe_cmd)
  call system(pipe_cmd.' '.shellescape(filter))
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
