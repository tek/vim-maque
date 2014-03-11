describe 'command restart'
  before
    runtime plugin/maque.vim
    runtime plugin/tmux.vim
  end

  it 'should start a new process'
    let pane = maque#tmux#add_pane('test')
    let cmd = maque#add_command('test', 'tail -f plugin/maque.vim', {'pane_name': 'test'})
    call maque#make_command('test')
    let pid = pane.set_command_pid()
    sleep 1
    call maque#restart_command('test')
    sleep 1
    Expect pane.set_command_pid() != pid
  end
end
