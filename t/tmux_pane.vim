describe 'pane.make'

  before
    let g:maque_tmux_filter_escape_sequences = 0

    function! Open_stub() dict "{{{
      return s:pane_open
    endfunction "}}}

    function! Send_keys_stub(cmd) dict "{{{
      let self.command_buffer += [a:cmd]
    endfunction "}}}

    let s:pane_open = 1
    let g:pane = maque#tmux#pane#new('foo')
    let g:pane.command_buffer = []

    let g:pane.open = function('Open_stub')
    let g:pane.send_keys = function('Send_keys_stub')

    let g:cmd = 'foo bar'

    function! s:make() "{{{
      call g:pane.make(g:cmd)
      return g:pane.command_buffer
    endfunction "}}}
  end

  it 'should run the command if the pane is open'
    let s:pane_open = 1
    let command_buffer = s:make()
    Expect index(command_buffer, shellescape(g:cmd)) >= 0
  end

  it 'should not run the command if the pane is closed'
    let s:pane_open = 0
    let command_buffer = s:make()
    Expect index(command_buffer, shellescape(g:cmd)) == -1
  end

  it 'should exit if autoclose is 1'
    let g:pane.autoclose = 1
    let command_buffer = s:make()
    Expect index(command_buffer, shellescape('exit')) >= 0
  end

  it 'should not exit if autoclose is 0'
    let g:pane.autoclose = 0
    let command_buffer = s:make()
    Expect index(command_buffer, shellescape('exit')) == -1
  end

end
