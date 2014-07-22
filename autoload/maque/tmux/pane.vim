"
" This file was automatically generated by riml 0.4.0
" Modify with care!
"
function! s:SID()
  if exists('s:SID_VALUE')
    return s:SID_VALUE
  endif
  let s:SID_VALUE = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
  return s:SID_VALUE
endfunction

" included: 'view.riml'
function! g:ViewConstructor(name, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let params = remove(__splat_var_cpy, 0)
  else
    let params = {}
  endif
  let viewObj = {}
  let viewObj.name = a:name
  let attrs = {'_original_size': [0, 0], 'minimized': 0, 'minimized_size': 2, 'minimize_on_toggle': get(g:, 'maque_tmux_minimize_on_toggle', 0), 'focus_on_restore': 0, 'vertical': 1, 'size': 0}
  call extend(attrs, params)
  let attrs.minimized_size = max([attrs.minimized_size, 2])
  call extend(viewObj, attrs)
  let viewObj.toggle = function('<SNR>' . s:SID() . '_View_toggle')
  let viewObj.toggle_minimized = function('<SNR>' . s:SID() . '_View_toggle_minimized')
  let viewObj.minimize = function('<SNR>' . s:SID() . '_View_minimize')
  let viewObj.restore = function('<SNR>' . s:SID() . '_View_restore')
  let viewObj.apply_size = function('<SNR>' . s:SID() . '_View_apply_size')
  let viewObj._vertical = function('<SNR>' . s:SID() . '_View__vertical')
  let viewObj.fixed_size = function('<SNR>' . s:SID() . '_View_fixed_size')
  let viewObj.effective_size = function('<SNR>' . s:SID() . '_View_effective_size')
  let viewObj.layout_size = function('<SNR>' . s:SID() . '_View_layout_size')
  let viewObj.layout_position = function('<SNR>' . s:SID() . '_View_layout_position')
  let viewObj.pack_layout = function('<SNR>' . s:SID() . '_View_pack_layout')
  let viewObj.pack = function('<SNR>' . s:SID() . '_View_pack')
  return viewObj
endfunction

function! s:View_toggle() dict
  if self.open()
    if self.minimize_on_toggle
      call self.toggle_minimized()
    else
      call self.close()
    endif
  else
    call self.create()
  endif
endfunction

function! s:View_toggle_minimized() dict
  if self.minimized
    call self.restore()
  else
    call self.minimize()
  endif
endfunction

function! s:View_minimize() dict
  if self.open() && !self.minimized
    let self._original_size = self.current_size()
    if !(self.in_layout())
      call self.apply_size(self.minimized_size)
    endif
    let self.minimized = 1
    call self.pack_layout()
  endif
endfunction

function! s:View_restore() dict
  if self.open() && self.minimized
    if !(self.in_layout())
      call self.resize(self._original_size[0], self._original_size[1])
    endif
    let self.minimized = 0
    if self.focus_on_restore
      call self.focus()
    endif
    call self.pack_layout()
  endif
endfunction

function! s:View_apply_size(size, ...) dict
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let both = remove(__splat_var_cpy, 0)
  else
    let both = 0
  endif
  let secondary = both ? self._original_size[!self._vertical()] : 0
  if self._vertical()
    call self.resize(secondary, a:size)
  else
    call self.resize(a:size, secondary)
  endif
endfunction

function! s:View__vertical() dict
  if self.in_layout()
    return self.layout.layout_vertical()
  else
    return self.vertical
  endif
endfunction

function! s:View_fixed_size() dict
  return self.size !=# 0 || self.minimized
endfunction

function! s:View_effective_size() dict
  return (self.minimized ? self.minimized_size : self.size) + 0
endfunction

function! s:View_layout_size() dict
  return self.current_size()[self._vertical()] + 0
endfunction

function! s:View_layout_position() dict
  return self.current_position()[self._vertical()] + 0
endfunction

function! s:View_pack_layout() dict
  if self.in_layout()
    call self.layout.pack()
  endif
  call self.pack()
endfunction

function! s:View_pack() dict
endfunction

let s:use_cache = 0
let s:cached_panes = {}
function! maque#tmux#pane#enable_cache()
  call maque#tmux#pane#disable_cache()
  call maque#tmux#pane#all()
  let s:use_cache = 1
endfunction

function! maque#tmux#pane#disable_cache()
  let s:use_cache = 0
endfunction

function! s:parse_tmux_output(line)
  let values = split(a:line)
  return {'id': values[0], 'pid': values[1] + 0, 'width': values[2] + 0, 'height': values[3] + 0, 'left': values[4] + 0, 'top': values[5] + 0}
endfunction

function! maque#tmux#pane#all(...)
  let force = get(a:000, 0)
  if !s:use_cache || force
    let cmd = 'list-panes -a -F "#{pane_id} #{pane_pid} #{pane_width}' . ' #{pane_height} #{pane_left} #{pane_top}"'
    let lines = split(maque#tmux#command_output(cmd), "\n")
    let s:cached_panes = {}
    for line in lines
      let data = s:parse_tmux_output(line)
      let s:cached_panes[data.id] = data
    endfor
  endif
  return s:cached_panes
endfunction

function! maque#tmux#pane#size(id)
  let panes = maque#tmux#pane#all()
  if has_key(panes, a:id)
    let pane = panes[a:id]
    return [pane.width, pane.height]
  else
    return [0, 0]
  endif
endfunction

function! maque#tmux#pane#position(id)
  let panes = maque#tmux#pane#all()
  if has_key(panes, a:id)
    let pane = panes[a:id]
    return [pane.left, pane.top]
  else
    return [0, 0]
  endif
endfunction

function! s:PaneConstructor(name, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let params = remove(__splat_var_cpy, 0)
  else
    let params = {}
  endif
  let paneObj = {}
  let attrs = {'id': -1, 'errorfile': tempname(), '_splitter': 'tmux neww -d', 'eval_splitter': 0, 'capture': 1, 'autoclose': 0, '_last_killed': 0, '_killed': 0, 'shell_pid': 0, 'command_pid': 0, 'wait_before_autoclose': 2, 'create_minimized': 0, 'restore_on_make': 1, 'kill_running_on_make': 1, 'focus_on_make': 0, 'manual_termination': 0, 'layout': 0, 'minimal_shell': 0}
  call extend(attrs, params)
  let paneObj.command_executable = ''
  let paneObj.spawning_make = 0
  let viewObj = g:ViewConstructor(a:name, attrs)
  call extend(paneObj, viewObj)
  let paneObj.create = function('<SNR>' . s:SID() . '_Pane_create')
  let paneObj.create_free = function('<SNR>' . s:SID() . '_Pane_create_free')
  let paneObj.determine_id = function('<SNR>' . s:SID() . '_Pane_determine_id')
  let paneObj.post_create = function('<SNR>' . s:SID() . '_Pane_post_create')
  let paneObj.create_and_wait = function('<SNR>' . s:SID() . '_Pane_create_and_wait')
  let paneObj.make = function('<SNR>' . s:SID() . '_Pane_make')
  let paneObj.create_and_make = function('<SNR>' . s:SID() . '_Pane_create_and_make')
  let paneObj.kill = function('<SNR>' . s:SID() . '_Pane_kill')
  let paneObj._kill = function('<SNR>' . s:SID() . '_Pane__kill')
  let paneObj.kill_wait = function('<SNR>' . s:SID() . '_Pane_kill_wait')
  let paneObj.send = function('<SNR>' . s:SID() . '_Pane_send')
  let paneObj.send_keys = function('<SNR>' . s:SID() . '_Pane_send_keys')
  let paneObj.open = function('<SNR>' . s:SID() . '_Pane_open')
  let paneObj.close = function('<SNR>' . s:SID() . '_Pane_close')
  let paneObj.current_size = function('<SNR>' . s:SID() . '_Pane_current_size')
  let paneObj.current_position = function('<SNR>' . s:SID() . '_Pane_current_position')
  let paneObj.set_preferred_size = function('<SNR>' . s:SID() . '_Pane_set_preferred_size')
  let paneObj.resize = function('<SNR>' . s:SID() . '_Pane_resize')
  let paneObj.focus = function('<SNR>' . s:SID() . '_Pane_focus')
  let paneObj.pipe_to_file = function('<SNR>' . s:SID() . '_Pane_pipe_to_file')
  let paneObj.pipe_cmd = function('<SNR>' . s:SID() . '_Pane_pipe_cmd')
  let paneObj.reset_capture = function('<SNR>' . s:SID() . '_Pane_reset_capture')
  let paneObj.output = function('<SNR>' . s:SID() . '_Pane_output')
  let paneObj.description = function('<SNR>' . s:SID() . '_Pane_description')
  let paneObj.splitter = function('<SNR>' . s:SID() . '_Pane_splitter')
  let paneObj.set_shell_pid = function('<SNR>' . s:SID() . '_Pane_set_shell_pid')
  let paneObj.set_command_pid = function('<SNR>' . s:SID() . '_Pane_set_command_pid')
  let paneObj.set_command_executable = function('<SNR>' . s:SID() . '_Pane_set_command_executable')
  let paneObj.process_alive = function('<SNR>' . s:SID() . '_Pane_process_alive')
  let paneObj.ready_for_make = function('<SNR>' . s:SID() . '_Pane_ready_for_make')
  let paneObj.in_layout = function('<SNR>' . s:SID() . '_Pane_in_layout')
  let paneObj.splitter_params = function('<SNR>' . s:SID() . '_Pane_splitter_params')
  let paneObj._handle_running_process = function('<SNR>' . s:SID() . '_Pane__handle_running_process')
  return paneObj
endfunction

function! s:Pane_create() dict
  if !(self.open())
    if self.in_layout()
      call self.layout.create_pane(self)
    else
      call self.create_free()
    endif
  endif
endfunction

function! s:Pane_create_free() dict
  if !(self.open())
    let panes_before = maque#tmux#pane#all()
    call maque#util#system(self.splitter(), 1)
    call self.determine_id(panes_before)
    call self.post_create()
  endif
endfunction

function! s:Pane_determine_id(panes_before) dict
  let matcher = 'index(keys(a:panes_before), v:val) == -1'
  let matches = filter(keys(maque#tmux#pane#all(1)), matcher)
  let self.id = len(matches) ># 0 ? matches[0] : -1
endfunction

function! s:Pane_post_create() dict
  if self.open()
    let self.minimized = 0
    if self.create_minimized
      call self.toggle()
    endif
    call self.send(' cd ' . getcwd())
    call self.set_shell_pid()
  endif
endfunction

function! s:Pane_create_and_wait(...) dict
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let timeout = remove(__splat_var_cpy, 0)
  else
    let timeout = 1
  endif
  call self.create()
  let counter = 0
  while (!self.open()) && (counter <# timeout * 10)
    sleep 100m
    let counter += 1
  endwhile
endfunction

function! s:Pane_make(cmd, ...) dict
  let capture = get(a:000, 0, self.capture)
  let autoclose = get(a:000, 1, self.autoclose)
  if self.ready_for_make()
    if self.minimized && self.restore_on_make
      call self.restore()
    endif
    call self.send(a:cmd)
    if capture
      if !self.manual_termination
        call self.send(' tmux ' . self.pipe_cmd())
      endif
      call self.pipe_to_file()
    endif
    if autoclose
      call self.send(' sleep ' . self.wait_before_autoclose . '; exit')
    endif
    if self.focus_on_make
      call self.focus()
    endif
  else
    call maque#util#warn('make called on pane "' . self.name . '" while not open!')
  endif
  let self.spawning_make = 0
endfunction

function! s:Pane_create_and_make(cmd, ...) dict
  if !(self.open())
    let self.spawning_make = 1
  endif
  call self.create()
  call call(self.make, [a:cmd] + a:000, self)
endfunction

function! s:Pane_kill(...) dict
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let signal = remove(__splat_var_cpy, 0)
  else
    let signal = '0'
  endif
  let force_signal = (signal !=# '0')
  if self.process_alive()
    if self.command_pid !=# self._last_killed
      let self._killed = 0
      let self._last_killed = self.command_pid
    endif
    if !(force_signal)
      let signal = s:next_signal(self._killed)
    endif
    call self._kill(signal)
    if !(force_signal)
      let self._killed += 1
    endif
    return 1
  else
    call maque#util#warn('no process running!')
  endif
endfunction

function! s:Pane__kill(signal) dict
  call maque#util#system('kill -' . a:signal . ' ' . self.command_pid, 1)
  call maque#util#warn('sent SIG' . a:signal . " to pane '" . self.name . "'!")
endfunction

function! s:Pane_kill_wait() dict
  for index in range(len(g:maque_tmux_kill_signals))
    call self.kill()
    if !(self.process_alive())
      return 1
    endif
    sleep 1
    if !(self.process_alive())
      return 1
    endif
  endfor
  return !self.process_alive()
endfunction

function! s:Pane_send(cmd) dict
  call self.send_keys("'" . a:cmd . "' 'ENTER'")
endfunction

function! s:Pane_send_keys(cmd) dict
  call maque#tmux#command('send-keys -t ' . self.id . ' ' . a:cmd)
endfunction

function! s:Pane_open() dict
  return has_key(maque#tmux#pane#all(), self.id)
endfunction

function! s:Pane_close() dict
  if self.open()
    call maque#tmux#command('kill-pane -t ' . self.id)
  endif
  let self.command_pid = 0
  let self.shell_pid = 0
  call maque#tmux#pane#enable_cache()
  call self.pack_layout()
endfunction

function! s:Pane_current_size() dict
  return maque#tmux#pane#size(self.id)
endfunction

function! s:Pane_current_position() dict
  return maque#tmux#pane#position(self.id)
endfunction

function! s:Pane_set_preferred_size() dict
  if self.minimized
    call self.apply_size(self.minimized_size)
  elseif self.fixed_size()
    call self.apply_size(self.size)
  endif
endfunction

function! s:Pane_resize(width, height) dict
  let cmd = 'resize-pane -t ' . self.id
  if a:width ># 0
    let cmd .= ' -x ' . a:width
  endif
  if a:height ># 0
    let cmd .= ' -y ' . a:height
  endif
  call maque#tmux#command(cmd)
endfunction

function! s:Pane_focus() dict
  call maque#tmux#command('select-pane -t ' . self.id)
endfunction

function! s:Pane_pipe_to_file() dict
  let filter = g:maque_tmux_filter_escape_sequences ? g:maque_tmux_pane_escape_filter : 'tee'
  let redirect = filter . ' > ' . self.errorfile
  call maque#tmux#command(self.pipe_cmd() . ' ' . shellescape(redirect))
endfunction

function! s:Pane_pipe_cmd() dict
  return 'pipe-pane -t ' . self.id
endfunction

function! s:Pane_reset_capture() dict
  call maque#tmux#command(self.pipe_cmd())
  call delete(self.errorfile)
  call self.pipe_to_file()
endfunction

function! s:Pane_output() dict
  return filereadable(self.errorfile) ? readfile(self.errorfile) : []
endfunction

function! s:Pane_description() dict
  return 'tmux pane "' . self.name . '"'
endfunction

function! s:Pane_splitter() dict
  if self.in_layout()
    let splitter = self.layout.splitter()
  else
    if self.eval_splitter
      let splitter = eval(self._splitter)
    else
      let splitter = self._splitter
    endif
  endif
  return splitter . self.splitter_params()
endfunction

function! s:Pane_set_shell_pid() dict
  let panes = maque#tmux#pane#all()
  if has_key(panes, self.id)
    let self.shell_pid = panes[self.id].pid
  endif
endfunction

function! s:Pane_set_command_pid() dict
  let self.command_pid = 0
  if self.open()
    let pids = maque#util#child_pids(self.shell_pid)
    let [pid, comm] = empty(pids) ? [0, ''] : pids[0]
    let self.command_pid = pid + 0
    let self.command_executable = comm
  endif
  return self.command_pid
endfunction

function! s:Pane_set_command_executable() dict
  call self.set_command_pid()
  return self.command_executable
endfunction

function! s:Pane_process_alive() dict
  return self.set_command_pid() ># 0
endfunction

function! s:Pane_ready_for_make() dict
  return self.open() && (self.spawning_make || !self.process_alive() || self._handle_running_process())
endfunction

function! s:Pane_in_layout() dict
  return type(self.layout) !=# type(0)
endfunction

function! s:Pane_splitter_params() dict
  let params = ''
  if self.minimal_shell
    let params .= ' "' . g:maque_tmux_minimal_shell . '"'
  endif
  return params
endfunction

function! s:Pane__handle_running_process() dict
  if self.kill_running_on_make
    if self.kill_wait()
      return 1
    else
      call maque#util#warn('Failed to kill running process!')
    endif
  else
    call maque#util#warn('Refusing to kill running process!')
  endif
endfunction

function! s:next_signal(idx)
  let sigs = g:maque_tmux_kill_signals
  return sigs[min([a:idx, len(sigs) - 1])]
endfunction

function! maque#tmux#pane#new(name, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let params = remove(__splat_var_cpy, 0)
  else
    let params = {}
  endif
  return s:PaneConstructor(a:name, params)
endfunction

function! s:VimPaneConstructor(...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let params = remove(__splat_var_cpy, 0)
  else
    let params = {}
  endif
  let vimPaneObj = {}
  let paneObj = s:PaneConstructor('vim', params)
  call extend(vimPaneObj, paneObj)
  let vimPaneObj.open = function('<SNR>' . s:SID() . '_VimPane_open')
  let vimPaneObj.Pane_open = function('<SNR>' . s:SID() . '_Pane_open')
  return vimPaneObj
endfunction

function! s:VimPane_open() dict
  if self.id ==# -1
    let self.id = maque#tmux#vim_id()
  endif
  return self.Pane_open()
endfunction

function! maque#tmux#pane#new_vim(...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let params = remove(__splat_var_cpy, 0)
  else
    let params = {}
  endif
  return s:VimPaneConstructor(params)
endfunction
