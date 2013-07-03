function! maque#tmux#send(cmd) "{{{
  call system('tmux send-keys -t '.g:ScreenShellTmuxPane.' "'.a:cmd.'" ENTER')
endfunction "}}}

function! maque#tmux#make(cmd) "{{{
  if ! g:ScreenShellActive
    if g:maque_tmux_vertical
      ScreenShellVertical
    else
      ScreenShell
    end
    call maque#tmux#send('cd '.g:pwd)
  end
  let pipe_cmd = 'tmux pipe-pane -t '.g:ScreenShellTmuxPane
  call maque#tmux#send(a:cmd.';'.pipe_cmd)
  let g:maque_errorfile = tempname()
  let filter = "sed -u -e \"s/\r//g\" -e \"s/\e[[0-9;]*m//g\" > ".g:maque_errorfile
  call system(pipe_cmd.' '.shellescape(filter))
endfunction "}}}

function! maque#tmux#parse() "{{{
  if exists('g:maque_errorfile')
    cgetfile
    if empty(getqflist())
      echohl WarningMsg | echo 'maque: no errors!' | echohl None
    else
      copen
      execute 'c'.g:maque_jump_to_error
      normal! zv
    endif
  endif
endfunction "}}}
