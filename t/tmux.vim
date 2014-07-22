describe 'create_buffer_pane'
  before
    let g:maque_tmux_panes = {}
    let g:maque_tmux_current_pane = 0
    let g:test_splitter = 'splittttt'
    let g:maque_handler = 'tmux'
  end

  it 'should create a pane associated with the current buffer'
    edit 'foo'
    edit 'bar'
    call maque#tmux#create_buffer_pane({ 'eval_splitter': 1, '_splitter':
          \ 'g:test_splitter', })
    let splitter = maque#tmux#current_pane().splitter()
    Expect splitter == g:test_splitter
    bnext
    let description = maque#tmux#current_pane().description()
    Expect description == 'dummy pane (tmux)'
  end
end

describe 'add_pane'
  before
    let g:maque_tmux_panes = {}
    let g:test_splitter = 'splittttt'
  end

  it 'should add a pane with evaluated splitter'
    call maque#tmux#add_pane('test', { 'eval_splitter': 1, '_splitter':
          \ 'g:test_splitter', })
    let splitter = maque#tmux#pane('test').splitter()
    Expect splitter == g:test_splitter
  end

  it 'should add a pane with literal splitter'
    call maque#tmux#add_pane('test', { 'eval_splitter': 0, '_splitter':
          \ g:test_splitter, })
    let splitter = maque#tmux#pane('test').splitter()
    Expect splitter == g:test_splitter
  end
end

describe 'integration'
  before
    source plugin/maque.vim
    source plugin/tmux.vim
  end

  it 'schedule a minimized service pane and toggle sizes'
    MaqueAddService 'tail -f plugin/maque.vim', { 'start': 1, 'size': 10,
          \ 'minimized_size': 3 }
    call maque#test#layout()
    let g:pane = maque#tmux#pane('tail')
    let g:layout = maque#tmux#layout('make')
    call maque#test#wait_until('g:pane.set_command_executable() == ''tail''')
    Expect g:pane.effective_size() == 3
    Expect g:pane.layout_size() == 3
    MaqueToggleCommand tail
    Expect g:pane.effective_size() == 10
    Expect g:pane.layout_size() == 10
    MaqueTmuxToggleLayout make
    Expect g:layout.effective_size() == 4
    Expect g:layout.layout_size() == 4
    Expect g:pane.layout_size() == 10
    MaqueToggleCommand tail
    Expect g:layout.layout_size() == 4
    Expect g:pane.layout_size() == 3
    MaqueTmuxToggleLayout make
    Expect g:layout.layout_size() > 4
    Expect g:pane.layout_size() == 3
  end
end
