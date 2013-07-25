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

  it 'should determine a buffer to be within the current project'
    edit plugin/maque.vim
    Expect maque#util#buffer_is_in_project(1) == 1
  end

end

describe 'pid listing'

  it 'should filter and strip digit sequences'
    function! maque#util#output_lines(cmd) "{{{
      return ['  23', '12', 'hamster', '       ', ' 5']
    endfunction "}}}

    let pids = maque#util#child_pids('1')
    Expect pids == ['23', '12', '5']
  end

end
