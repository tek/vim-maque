let g:maque_tmux_minimal_shell = 'zsh -f'

describe 'pane.reset_capture()'
  before
    let g:maque_tmux_kill_signals = ['KILL']
    let g:maque_tmux_filter_escape_sequences = 0
    call maque#test#create({
          \ 'capture': 1,
          \ 'manual_termination': 1,
          \ } )
    let g:test_file = './t/temp/reset_capture'
    silent !mkdir -p ./t/temp
    execute 'silent !rm -f ' . g:test_file
    execute 'silent !touch ' . g:test_file
    call g:pane.make('tail -f ' . g:test_file)
    call maque#test#wait_until('g:pane.process_alive()')
    execute 'redir! > ' . g:test_file
    silent echo 'line 1'
    redir END
  end

  after
    call maque#test#finish()
  end

  it 'resets the tmux pipe'
    if exists('$TRAVIS')
      return
    endif
    Expect g:pane.output() == ['', 'line 1']
    call g:pane.reset_capture()
    Expect g:pane.output() == []
    sleep 100m
    execute 'redir! >> ' . g:test_file
    echo 'line 2'
    silent redir END
    Expect g:pane.output() == ['', 'line 2']
  end
end

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
    call maque#test#pane()
    let g:pane.command_buffer = []

    let g:pane.open = function('Open_stub')
    let g:pane.send_keys = function('Send_keys_stub')

    let g:cmd = 'foo bar'

    function! s:make() "{{{
      call g:pane.make(g:cmd)
      return g:pane.command_buffer
    endfunction "}}}
  end

  after
    unlet g:pane
  end

  it 'should run the command if the pane is open'
    let s:pane_open = 1
    let command_buffer = s:make()
    Expect match(command_buffer, g:cmd) == 1
  end

  it 'should not run the command if the pane is closed'
    let s:pane_open = 0
    let command_buffer = s:make()
    Expect match(command_buffer, g:cmd) == -1
  end

  it 'should exit if autoclose is 1'
    let g:pane.autoclose = 1
    let command_buffer = s:make()
    Expect match(command_buffer, 'exit') == 1
  end

  it 'should not exit if autoclose is 0'
    let g:pane.autoclose = 0
    let command_buffer = s:make()
    Expect match(command_buffer, 'exit') == -1
  end
end

describe 'pane process management'

  before
    let g:maque_tmux_kill_signals = []
    call maque#test#create()
  end

  after
    call maque#test#finish()
  end

  it 'should determine the pid of its shell'
    Expect g:pane.shell_pid > 0
  end

  it 'should determine the pid of a running command'
    call g:pane.make('tail -f plugin/maque.vim')
    call maque#test#wait_until('g:pane.set_command_executable() == "tail"', 50)
    Expect g:pane.process_alive() > 0
    call g:pane.set_command_pid()
    Expect g:pane.command_pid > 0
    Expect g:pane.process_alive() to_be_true
  end

  it 'should kill a simple process with SIGINT'
    if exists('$TRAVIS')
      return
    endif
    let max_tries = 1
    let g:maque_tmux_kill_signals = ['INT']
    call g:pane.make('tail -f plugin/maque.vim')
    call maque#test#wait_until('g:pane.process_alive()')
    call g:pane.kill()
    call maque#test#wait_until('!g:pane.process_alive()')
    Expect g:pane.command_pid == 0
  end

  it 'should kill a subshell with SIGKILL'
    let g:maque_tmux_kill_signals = ['INT', 'TERM', 'KILL']
    call g:pane.make('zsh -i')
    call maque#test#wait_until('g:pane.process_alive()')
    call g:pane.kill()
    Expect g:pane.process_alive() > 0
    call g:pane.kill()
    Expect g:pane.process_alive() > 0
    call g:pane.kill()
    call maque#test#wait_until('!g:pane.process_alive()')
    Expect g:pane.command_pid == 0
  end
end

describe 'pane.kill_running_on_make'
  before
    let g:maque_tmux_kill_signals = ['KILL']
    call maque#test#make('tail -f plugin/maque.vim')
    call maque#test#wait_until('g:pane.process_alive()')
  end

  after
    call maque#test#finish()
  end

  it 'should kill a running command when the option is set'
    if exists('$TRAVIS')
      return
    endif
    let g:pane.kill_running_on_make = 1
    let pid = g:pane.command_pid
    call g:pane.make('tail -f plugin/maque.vim')
    call maque#test#wait_until('g:pane.process_alive()')
    Expect g:pane.command_pid != pid
  end

  it 'should abort make when the option is unset'
    let g:pane.kill_running_on_make = 0
    let pid = g:pane.command_pid
    call g:pane.make('tail -f plugin/maque.vim')
    Expect g:pane.command_pid == pid
  end
end
