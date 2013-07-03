function! maque#tmux#send(cmd) "{{{
  call system('tmux send-keys -t '.g:ScreenShellTmuxPane.' "'.a:cmd.'" ENTER')
endfunction "}}}

function! maque#tmux#init_pane() "{{{
  if ! g:ScreenShellActive
    if g:maque_tmux_vertical
      ScreenShellVertical
    else
      ScreenShell
    end
    call maque#tmux#send('cd '.g:pwd)
  end
endfunction "}}}

function! maque#tmux#make(cmd) "{{{
  call maque#tmux#init_pane()
  let pipe_cmd = 'tmux pipe-pane -t '.g:ScreenShellTmuxPane
  let filter = "sed -u -e \"s/\r//g\" -e \"s/\e[[0-9;]*m//g\" > ".&errorfile
  let &errorfile = tempname()
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
      if len(g:maque_jump_to_error)
        execute 'c'.g:maque_jump_to_error
        normal! zv
      endif
    endif
  endif
endfunction "}}}
