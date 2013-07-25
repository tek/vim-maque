describe 'makeprg setter'
  before
    redir >> log
    set filetype=rspec
  end

  it 'should use the filetype setter'
    let g:function_called = 0
    function! maque#ft#rspec#set_makeprg() "{{{
      let g:function_called = 1
    endfunction "}}}
    echo exists('*maque#set_makeprg')
    call maque#set_makeprg()
    Expect g:function_called to_be_true
  end

  it 'should use the overridden filetype setter'
    let b:maque_filetype = 'tex'
    let g:function_called = 0
    function! maque#ft#rspec#set_makeprg() "{{{
      let g:function_called = 0
    endfunction "}}}
    function! maque#ft#tex#set_makeprg() "{{{
      let g:function_called = 1
    endfunction "}}}
    call maque#set_makeprg()
    Expect g:function_called to_be_true
  end

  it 'should use the setter from the global variable'
    let b:maque_filetype = 'tex'
    let g:function_called = 0
    function! maque#ft#rspec#set_makeprg() "{{{
      let g:function_called = 0
    endfunction "}}}
    function! maque#ft#tex#set_makeprg() "{{{
      let g:function_called = 0
    endfunction "}}}
    function! Set_g() "{{{
      let g:function_called = 1
    endfunction "}}}
    let g:maque_makeprg_setter = 'Set_g'
    call maque#set_makeprg()
    Expect g:function_called to_be_true
  end

  it 'should use the setter from the buffer variable'
    let b:maque_filetype = 'tex'
    let g:function_called = 0
    function! maque#ft#rspec#set_makeprg() "{{{
      let g:function_called = 0
    endfunction "}}}
    function! maque#ft#tex#set_makeprg() "{{{
      let g:function_called = 0
    endfunction "}}}
    function! Set_g() "{{{
      let g:function_called = 0
    endfunction "}}}
    function! Set_b() "{{{
      let g:function_called = 1
    endfunction "}}}
    let g:maque_makeprg_setter = 'Set_g'
    let b:maque_makeprg_setter = 'Set_b'
    call maque#set_makeprg()
    Expect g:function_called to_be_true
  end

end
