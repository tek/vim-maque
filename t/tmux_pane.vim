  function! s:wait_until(predicate) "{{{
    let counter = 0
    let timeout = 50
    while !eval(a:predicate) && counter < timeout
      sleep 200m
      let counter += 1
    endwhile
  endfunction "}}}

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
    let g:pane = maque#tmux#pane#new('foo', {'capture': 0})
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
    Expect match(command_buffer, g:cmd) == 0
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
    let g:pane = maque#tmux#pane#new('foo', {'capture': 0})
    call g:pane.create()
  end

  after
    call g:pane.kill('KILL')
    call g:pane.close()
    unlet g:pane
  end

  it 'should determine the pid of its shell'
    Expect g:pane.shell_pid > '0'
  end

  it 'should determine the pid of a running command'
    call g:pane.make('tail -f plugin/maque.vim')
    call s:wait_until('g:pane.process_alive()')
    Expect g:pane.process_alive() > 0
    call g:pane.set_command_pid()
    Expect g:pane.command_pid > '0'
    Expect g:pane.process_alive() to_be_true
  end

  it 'should kill a simple process with SIGINT'
    let max_tries = 1
    let g:maque_tmux_kill_signals = ['INT']
    call g:pane.make('tail -f plugin/maque.vim')
    call s:wait_until('g:pane.process_alive()')
    call g:pane.kill()
    call s:wait_until('!g:pane.process_alive()')
    Expect g:pane.command_pid == 0
  end

  it 'should kill a subshell with SIGKILL'
    let g:maque_tmux_kill_signals = ['INT', 'TERM', 'KILL']
    call g:pane.make('zsh -i')
    call s:wait_until('g:pane.process_alive()')
    call g:pane.kill()
    Expect g:pane.process_alive() > 0
    call g:pane.kill()
    Expect g:pane.process_alive() > 0
    call g:pane.kill()
    call s:wait_until('!g:pane.process_alive()')
    Expect g:pane.command_pid == 0
  end

end

describe 'minimize'

  after
    call g:pane.close()
    unlet g:pane
  end

  it 'minimize the pane when toggling'
    let g:master_pane = maque#tmux#pane#new('master')
    let splitter = 'tmux split-window -v -d'
    let g:pane = maque#tmux#pane#new('toggle test', {
          \ '_splitter': splitter,
          \ 'capture': 0,
          \ 'minimize_on_toggle': 1,
          \ 'vertical': 0,
          \ })
    call g:pane.create()
    call s:wait_until('g:pane.open()')
    let original_size = maque#tmux#pane#size(g:pane.id)
    call g:pane.toggle()
    call s:wait_until('g:pane.minimized')
    Expect g:pane.open() == 1
    Expect g:pane.minimized == 1
    let size = maque#tmux#pane#size(g:pane.id)
    Expect size[1] == '2'
    call g:pane.toggle()
    call s:wait_until('!g:pane.minimized')
    Expect g:pane.open() == 1
    Expect g:pane.minimized == 0
    let size = maque#tmux#pane#size(g:pane.id)
    Expect size == original_size
  end

end

describe 'pane.kill_running_on_make'
  before
    let g:maque_tmux_kill_signals = ['KILL']
    let g:pane = maque#tmux#pane#new('foo', {'capture': 0})
    call g:pane.create()
    call g:pane.make('tail -f plugin/maque.vim')
    call s:wait_until('g:pane.process_alive()')
  end

  after
    call g:pane.kill('KILL')
    call g:pane.close()
    unlet g:pane
  end

  it 'should kill a running command when the option is set'
    let g:pane.kill_running_on_make = 1
    let pid = g:pane.command_pid
    call g:pane.make('tail -f plugin/maque.vim')
    call s:wait_until('g:pane.process_alive()')
    Expect g:pane.command_pid != pid
  end

  it 'should abort make when the option is unset'
    let g:pane.kill_running_on_make = 0
    let pid = g:pane.command_pid
    call g:pane.make('tail -f plugin/maque.vim')
    Expect g:pane.command_pid == pid
  end
end
