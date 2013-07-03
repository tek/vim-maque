function! maque#tmux#send(cmd) "{{{
  call system('tmux send-keys -t '.g:ScreenShellTmuxPane.' "'.a:cmd.'" ENTER')
endfunction "}}}
