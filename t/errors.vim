function! s:setup_test_dir() "{{{
  let g:olddir = getcwd()
  let g:tempdir = getcwd().'/tmp'
  let g:cwd = g:tempdir.'/cwd'
  call mkdir(g:cwd, 'p')
  let g:inside1 = g:cwd.'/inside1'
  let g:inside2 = g:cwd.'/inside2'
  let g:outside1 = g:tempdir.'/outside1'
  let g:outside2 = '../outside2'
  exe 'edit' g:inside1
  exe 'edit' g:inside2
  exe 'edit' g:outside1
  exe 'edit' g:tempdir.'/outside2'
  exe 'cd' g:cwd

  let trace = [g:outside1, g:outside2, g:inside1, g:outside2, g:inside2,
        \ g:outside1]
  let errors = map(trace, '{ "lnum": 1, "filename": v:val }')
  call setqflist(errors)
endfunction "}}}

describe 'error parsing'
  before
    call s:setup_test_dir()
  end

  after
    exe 'cd' g:olddir
    call system('rm -rf '.g:tempdir)
  end

  it 'checks the test environment'
    exe 'cd' g:cwd
    Expect empty(getqflist()) == 0
    Expect expand('#1:p') == g:inside1
    Expect expand('#2:p') == g:inside2
    Expect expand('#3:p') == g:outside1
    Expect expand('#4:p') == fnamemodify(g:outside2, ':p')
  end

  it 'finds the first error in the current project dir'
    exe 'cd' g:cwd
    let g:maque_jump_to_error = 'first'
    let g:maque_seek_cwd_error = 1
    let index = maque#cwd_error_index()
    Expect index == 3
  end

  it 'finds the last error in the current project dir'
    exe 'cd' g:cwd
    let g:maque_jump_to_error = 'last'
    let g:maque_seek_cwd_error = 1
    let index = maque#cwd_error_index()
    Expect index == 5
  end
end
