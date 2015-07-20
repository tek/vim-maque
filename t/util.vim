describe 'autoload function lookup'

  before
    runtime plugin/maque.vim
    function! Dummy()
    endfunction
  end

  it 'should find an existing function'
    Expect maque#util#is_autoload('maque#tmux#make') == 1
  end

  it 'should not find an nonexistent function'
    Expect maque#util#is_autoload('maque#tmux#Rt6ke34fHDDL') == 0
  end

  it 'should not find an invalid function'
    Expect maque#util#is_autoload('maque#tmux#($%^') == 0
  end

  it 'should iterate the arguments until a function is found, with nested evaluation'
    let g:funcname = 'maque#tmux#make'
    let Func = maque#util#lookup('g:nonexistent', 'maque#nonexistent', 'g:funcname')
    Expect Func == function(g:funcname)
  end

  it 'should find an existent handler function'
    let g:maque_handler = 'tmux'
    let Func = maque#util#handler_function('make', 0)
    Expect Func == function('maque#tmux#make')
  end

  it 'should return the default argument when querying a nonexistent handler function'
    let g:maque_handler = 'tmux'
    let Func = maque#util#handler_function('nonexistent', 'maque#make')
    Expect Func == function('maque#make')
  end

end

describe 'buffer path test'

  it 'should determine a path to be within the current project'
    let path = fnamemodify('plugin/maque.vim', ':p')
    Expect maque#util#path_is_in_project(path) == 1
  end

end

describe 'pid listing'

  it 'should filter and strip digit sequences and executable names'
    function! maque#util#output_lines(cmd) "{{{
      return ['  23 zsh', '12 tmux  ', 'hamster', '6', '       ', ' 5 vim']
    endfunction "}}}

    let pids = maque#util#child_pids('1')
    Expect pids == [['23', 'zsh'], ['12', 'tmux'], ['5', 'vim']]
  end

end

describe 'variable lookup'

  function! s:evaluate() "{{{
    let found = maque#util#variable('maque_stuff')
    Expect found == 'correct'
  endfunction "}}}

  it 'should return the global default'
    let g:maque_stuff_default = 'correct'
    call s:evaluate()
  end

  it 'should return the buffer default'
    let g:maque_stuff_default = 'erroneous!'
    let b:maque_stuff_default = 'correct'
    call s:evaluate()
  end

  it 'should return the global override'
    let g:maque_stuff_default = 'erroneous!'
    let b:maque_stuff_default = 'invalid!'
    let g:maque_stuff = 'correct'
    call s:evaluate()
  end

  it 'should return the global override'
    let g:maque_stuff_default = 'erroneous!'
    let b:maque_stuff_default = 'invalid!'
    let g:maque_stuff = 'faulty!'
    let b:maque_stuff = 'correct'
    call s:evaluate()
  end

end
