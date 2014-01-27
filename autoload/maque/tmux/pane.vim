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
    let s:cached_panes = split(maque#tmux#command_output(cmd), "\n")
  endif
  return s:cached_panes
endfunction "}}}

function! maque#tmux#pane#size(id) "{{{
  let cmd = 'list-panes -t '.a:id .' -F "#{pane_id} #{pane_width} #{pane_height}"'
  let panes = split(maque#tmux#command_output(cmd), "\n")
  let mypane = matchlist(panes, a:id .' \zs\d\+ \d\+$')
  if len(mypane)
    return split(mypane[0])
  else
    return [0, 0]
  endif
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
        \ 'minimize_on_toggle': get(g:, 'maque_tmux_minimize_on_toggle', 0),
        \ 'vertical': 1,
        \ 'minimized': 0,
        \ 'minimized_size': 2,
        \ 'create_minimized': 0,
        \ 'restore_on_make': 1,
        \ '_original_size': [0, 0],
        \ 'kill_running_on_make': 1,
        \ 'focus_on_restore': 0,
        \ 'focus_on_make': 0,
        \ 'manual_termination': 0,
        \ 'layout': 0,
        \ }
  call extend(pane, params)
  let pane.name = a:name
  let pane.minimized_size = max([pane.minimized_size, 2])

  function! pane.create() abort dict "{{{
    if !self.open()
      if self.in_layout()
        call self.layout.create_pane(self)
      else
        call self.create_free()
      endif
    endif
  endfunction "}}}

  function! pane.create_free() dict "{{{
    if !self.open()
      let panes_before = maque#tmux#pane#all()
      call system(self.splitter())
      call self.determine_id(panes_before)
      call self.post_create()
    endif
  endfunction "}}}

  function! pane.determine_id(panes_before) abort dict "{{{
      let matcher = 'index(a:panes_before, v:val) == -1'
      let matches = filter(maque#tmux#pane#all(1), matcher)
      let self.id = len(matches) > 0 ? matches[0] : -1
  endfunction "}}}

  function! pane.post_create() abort dict "{{{
    if self.open()
      let self.minimized = 0
      if self.create_minimized
        call self.toggle()
      endif
      call self.send(' cd '.getcwd())
      call self.set_shell_pid()
    endif
  endfunction "}}}

  function! pane.make(cmd, ...) dict "{{{
    let capture = a:0 ? a:1 : self.capture
    let autoclose = a:0 >= 2 ? a:2 : self.autoclose
    if self.ready_for_make()
      if self.minimized && self.restore_on_make
        call self.restore()
      endif
      call self.send(a:cmd)
      if capture
        if !self.manual_termination
          " send the pipe canceling command now, so that it executes as soon as the
          " make command is finished
          " omit this if manual_termination is set, i.e. the program is
          " interactive or just doesn't terminate automatically (guard, log)
          call self.send(' tmux '.self.pipe_cmd())
        endif
        " initiate the pipe to the errorfile after starting the command, so that it
        " doesn't contain the command line
        call self.pipe_to_file()
      endif
      if autoclose
        call self.send(' sleep '.self.wait_before_autoclose.'; exit')
      endif
      call self.set_command_pid()
      if self.focus_on_make
        call self.focus()
      endif
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

  function! pane.kill_wait() dict "{{{
    for index in range(len(g:maque_tmux_kill_signals))
      call self.kill()
      if !self.process_alive()
        return 1
      endif
      sleep 1
      if !self.process_alive()
        return 1
      endif
    endfor
    return !self.process_alive()
  endfunction "}}}

  " execute a shell command in the target pane
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
      if self.minimize_on_toggle
        call self.toggle_minimized()
      else
        call self.close()
      endif
    else
      call self.create()
    endif
  endfunction "}}}

  function! pane.toggle_minimized() dict "{{{
    if self.minimized
      call self.restore()
    else
      call self.minimize()
    endif
  endfunction "}}}

  function! pane.minimize() dict "{{{
    let self._original_size = maque#tmux#pane#size(self.id)
    if self.vertical
      call self.resize(self.minimized_size, self._original_size[1])
    else
      call self.resize(self._original_size[0], self.minimized_size)
    endif
    let self.minimized = 1
  endfunction "}}}

  function! pane.restore() dict "{{{
    call call(self.resize, self._original_size, self)
    let self.minimized = 0
    if self.focus_on_restore
      call self.focus()
    endif
  endfunction "}}}

  function! pane.focus() dict "{{{
    call maque#tmux#command('select-pane -t '.self.id)
    if g:maque_tmux_map_focus_vim
      let cmd = 'run "tmux last-pane; tmux unbind-key -n '.g:maque_tmux_focus_vim_key .'"'
      call maque#tmux#command('bind-key -n '.g:maque_tmux_focus_vim_key .' '.cmd)
    endif
  endfunction "}}}

  function! pane.resize(width, height) dict "{{{
    let cmd = 'resize-pane -t '.self.id.' -x '.a:width.' -y '.a:height
    call maque#tmux#command(cmd)
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

  function! pane.reset_capture() dict "{{{
    call maque#tmux#command(self.pipe_cmd())
    call delete(self.errorfile)
    call self.pipe_to_file()
  endfunction "}}}

  function! pane.description() dict "{{{
    return 'tmux pane "'.self.name.'"'
  endfunction "}}}

  if get(params, 'eval_splitter')

    function! pane.splitter() dict "{{{
      if self.in_layout()
        return {self._splitter}
      else
        return self.layout.splitter()
      endif
    endfunction "}}}

  else

    function! pane.splitter() dict "{{{
      if self.in_layout()
        return self.layout.splitter()
      else
        return self._splitter
      endif
    endfunction "}}}

  endif

  function! pane.set_shell_pid() dict "{{{
    let cmd = 'list-panes -t '.self.id .' -F "#{pane_id} #{pane_pid}"'
    let panes = split(maque#tmux#command_output(cmd), "\n")
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
    return self.command_pid
  endfunction "}}}

  function! pane.process_alive() dict "{{{
    return self.set_command_pid() > 0
  endfunction "}}}

  function! pane.ready_for_make() dict "{{{
    return self.open() && (!self.process_alive() || self._handle_running_process())
  endfunction "}}}

  function! pane.in_layout() abort dict "{{{
    return type(self.layout) != type(0)
  endfunction "}}}

  function! pane._handle_running_process() dict "{{{
    if self.kill_running_on_make
      if self.kill_wait()
        return 1
      else
        call maque#util#warn('Failed to kill running process!')
      endif
    else
      call maque#util#warn('Refusing to kill running process!')
    endif
  endfunction "}}}

  return pane
endfunction "}}}

function! s:signal(idx) "{{{
  let sigs = g:maque_tmux_kill_signals
  return sigs[min([a:idx, len(sigs)-1])]
endfunction "}}}
