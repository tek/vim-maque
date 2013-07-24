describe 'create_buffer_pane'
  before
    let g:maque_tmux_panes = {}
    let g:maque_tmux_current_pane = 0
    let g:test_splitter = 'splittttt'
  end

  it 'should create a pane associated with the current buffer'
    edit 'foo'
    edit 'bar'
    call maque#tmux#create_buffer_pane({ 'eval_splitter': 1, '_splitter':
          \ 'g:test_splitter', })
    let splitter = maque#tmux#current_pane().splitter()
    Expect splitter == g:test_splitter
    bnext
    Expect maque#tmux#current_pane() == 0
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

