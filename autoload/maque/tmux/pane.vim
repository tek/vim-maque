function! maque#tmux#pane#all() "{{{
  return split(maque#tmux#command('list-panes -a -F "#{pane_id}"'), "\n")
endfunction "}}}

function! maque#tmux#pane#new(name, ...) "{{{
  let params = a:0 ? a:1 : {}
  let pane = {
        \ 'id': -1,
        \ 'errorfile': tempname(),
        \ '_splitter': 'tmux neww -d',
        \ 'capture': 1,
        \ 'autoclose': 0,
        \ }
  call extend(pane, params)
  let pane.name = a:name

  function! pane.create() dict "{{{
    if !self.open()
      let panes_before = maque#tmux#pane#all()
      call system(self.splitter())
      let matcher = 'index(panes_before, v:val) == -1'
      let matches = filter(maque#tmux#pane#all(), matcher)
      let self.id = len(matches) > 0 ? matches[0] : -1
      call self.send('cd '.g:pwd)
    endif
  endfunction "}}}

  function! pane.make(cmd, ...) dict "{{{
    let capture = a:0 ? a:1 : self.capture
    let autoclose = a:0 >= 2 ? a:2 : self.autoclose
    if self.open()
      call self.send(a:cmd)
      if capture
        " send the pipe canceling command now, so that it executes as soon as the
        " make command is finished
        call self.send(' tmux '.self.pipe_cmd())
        " initiate the pipe to the errorfile after starting the command, so that it
        " doesn't contain the command line
        call self.pipe_to_file()
      endif
      if autoclose
        call self.send('exit')
      endif
    else
      call s:warn('make called on pane "'.self.name.'" while not open!')
    endif
  endfunction "}}}

  function! pane.kill() dict "{{{
    try
      for key in ["\n~.", 'C-d', 'C-c', 'C-\', 'C-c']
        call self.send_keys(key)
      endfor
    catch /E484/
    endtry
  endfunction "}}}

  " execute a command in the target pane
  function! pane.send(cmd) dict "{{{
    call self.send_keys("'".a:cmd."'")
    call self.send_keys('ENTER')
  endfunction "}}}

  " send input to the target pane
  function! pane.send_keys(cmd) dict "{{{
    call maque#tmux#command('send-keys -t '.self.id.' '.a:cmd)
  endfunction "}}}

  function! pane.open() dict "{{{
    return self.id >= 0 && index(maque#tmux#pane#all(), self.id) >= 0
  endfunction "}}}

  function! pane.close() dict "{{{
    if self.open()
      call maque#tmux#command('kill-pane -t '.self.id)
    endif
  endfunction "}}}

  function! pane.toggle() dict "{{{
    if self.open()
      call self.close()
    else
      call self.create()
    endif
  endfunction "}}}

  function! pane.pipe_to_file() dict "{{{
    let filter = g:maque_tmux_filter_escape_sequences ?
          \ g:maque_tmux_pane_escape_filter : 'tee'
    let redirect = filter . ' > '.self.errorfile
    call maque#tmux#command(self.pipe_cmd().' '.shellescape(redirect))
  endfunction "}}}

  function! pane.pipe_cmd() dict "{{{
    return 'pipe-pane -t '.self.id
  endfunction "}}}

  function! pane.description() dict "{{{
    return 'tmux pane "'.self.name.'"'
  endfunction "}}}

  if get(params, 'eval_splitter')

    function! pane.splitter() dict "{{{
      return {self._splitter}
    endfunction "}}}

  else

    function! pane.splitter() dict "{{{
      return self._splitter
    endfunction "}}}

  endif

  return pane
endfunction "}}}

function! s:warn(msg) "{{{
  echohl WarningMsg
  echo a:msg
  echohl None
endfunction "}}}
