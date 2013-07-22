describe 'tmux pane'

  before
    runtime plugin/maque.vim

    function! s:open_stub() dict "{{{
      return s:pane_open
    endfunction "}}}

    function! s:send_keys_stub(cmd) dict "{{{
      let self.command_buffer += [a:cmd]
    endfunction "}}}

    let s:pane_open = 1
    let g:pane = maque#tmux#pane#new('foo', 0)
    let g:pane.command_buffer = []

    let g:pane.open = function('s:open_stub')
    let g:pane.send_keys = function('s:send_keys_stub')
  end

  it 'should run the command if the pane is open'
    let s:pane_open = 1
    let cmd = 'foo bar'
    call g:pane.make(cmd)
    Expect index(g:pane.command_buffer, shellescape(cmd)) >= 0
  end

  it 'should not run the command if the pane is closed'
    let s:pane_open = 0
    let cmd = 'foo bar'
    call g:pane.make(cmd)
    Expect index(g:pane.command_buffer, shellescape(cmd)) == -1
  end

end
