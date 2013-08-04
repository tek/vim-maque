let s:use_cache = 0
let s:cached_panes = []

function! maque#tmux#pane#enable_cache() "{{{
  call maque#tmux#pane#all()
  let s:use_cache = 1
endfunction "}}}

function! maque#tmux#pane#disable_cache() "{{{
  let s:use_cache = 0
endfunction "}}}

function! maque#tmux#pane#all(...) "{{{
  let force = get(a:000, 0)
  if !s:use_cache || force
    let cmd = 'list-panes -a -F "#{pane_id}"'
    let s:cached_panes = split(maque#tmux#command(cmd, 1), "\n")
  endif
  return s:cached_panes
endfunction "}}}

function! maque#tmux#pane#new(name, ...) "{{{
  let params = a:0 ? a:1 : {}
  let pane = {
        \ 'id': -1,
        \ 'errorfile': tempname(),
        \ '_splitter': 'tmux neww -d',
        \ 'capture': 1,
        \ 'autoclose': 0,
        \ '_last_killed': 0,
        \ '_killed': 0,
        \ 'shell_pid': 0,
        \ 'command_pid': 0,
        \ 'wait_before_autoclose': 2,
        \ }
  call extend(pane, params)
  let pane.name = a:name

  function! pane.create() dict "{{{
    if !self.open()
      let panes_before = maque#tmux#pane#all()
      call system(self.splitter())
      let matcher = 'index(panes_before, v:val) == -1'
      let matches = filter(maque#tmux#pane#all(1), matcher)
      let self.id = len(matches) > 0 ? matches[0] : -1
      if self.open()
        call self.send(' cd '.getcwd())
        call self.set_shell_pid()
      endif
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
        call self.send(' sleep '.self.wait_before_autoclose.'; exit')
      endif
      call self.set_command_pid()
    else
      call maque#util#warn('make called on pane "'.self.name.'" while not open!')
    endif
  endfunction "}}}

  " Send a signal to the command.
  " Iterates g:maque_tmux_kill_signals for subsequent calls until the process
  " is dead (default INT, TERM, KILL)
  " Argument overrides the employed signal and does not advance the current
  " signal.
  function! pane.kill(...) dict "{{{
    if self.process_alive()
      if self.command_pid != self._last_killed
        let self._killed = 0
        let self._last_killed = self.command_pid
      endif
      let signal = a:0 ? a:1 : s:signal(self._killed)
      call self._kill(signal)
      if !a:0
        let self._killed += 1
      endif
      return 1
    else
      call maque#util#warn('no process running!')
    endif
  endfunction "}}}

  function! pane._kill(signal) dict "{{{
    call system('kill -'.a:signal.' '.self.command_pid)
    call maque#util#warn('sent SIG'.a:signal." to pane '".self.name."'!")
  endfunction "}}}

  " execute a command in the target pane
  function! pane.send(cmd) dict "{{{
    call self.send_keys("'".a:cmd."' 'ENTER'")
  endfunction "}}}

  " send input to the target pane
  function! pane.send_keys(cmd) dict "{{{
    call maque#tmux#command('send-keys -t '.self.id.' '.a:cmd)
  endfunction "}}}

  function! pane.open() dict "{{{
    return self.id >= 0 && index(maque#tmux#pane#all(), self.id) >= 0
  endfunction "}}}

  " Kill the pane if it's open, reset pids in any case
  function! pane.close() dict "{{{
    if self.open()
      call maque#tmux#command('kill-pane -t '.self.id)
    endif
    let self.command_pid = 0
    let self.shell_pid = 0
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

  function! pane.set_shell_pid() dict "{{{
    let cmd = 'list-panes -t '.self.id .' -F "#{pane_id} #{pane_pid}"'
    let panes = split(maque#tmux#command(cmd), "\n")
    let mypane = matchlist(panes, self.id .' \zs\d\+$')
    if len(mypane)
      let self.shell_pid = mypane[0]
    endif
  endfunction "}}}

  function! pane.set_command_pid() dict "{{{
    let self.command_pid = 0
    if self.open()
      let pids = maque#util#child_pids(self.shell_pid)
      let self.command_pid = len(pids) ? pids[0] : 0
    endif
  endfunction "}}}

  function! pane.process_alive() dict "{{{
    if self.command_pid > 0
      call self.set_command_pid()
      return self.command_pid > 0
    endif
  endfunction "}}}

  return pane
endfunction "}}}

function! s:signal(idx) "{{{
  let sigs = g:maque_tmux_kill_signals
  return sigs[min([a:idx, len(sigs)-1])]
endfunction "}}}
