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

function! s:CommandConstructor(command, name, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let params = remove(__splat_var_cpy, 0)
  else
    let params = {}
  endif
  let commandObj = {}
  if has_key(params, 'pane')
    let params['pane_name'] = remove(params, 'pane')
  endif
  let attrs = {'_command': a:command, 'pane_name': 'main', 'handler': g:maque_handler, 'cmd_type': 'shell', 'pane_type': 'name', 'copy_to_main': 0, 'name': a:name, 'compiler': '', 'nested': 0}
  call extend(commandObj, attrs)
  call extend(commandObj, params)
  let commandObj.command = function('<SNR>' . s:SID() . '_Command_command')
  let commandObj._command_eval = function('<SNR>' . s:SID() . '_Command__command_eval')
  let commandObj._command_shell = function('<SNR>' . s:SID() . '_Command__command_shell')
  let commandObj.cmd_compact = function('<SNR>' . s:SID() . '_Command_cmd_compact')
  let commandObj.make = function('<SNR>' . s:SID() . '_Command_make')
  let commandObj.pane = function('<SNR>' . s:SID() . '_Command_pane')
  let commandObj._pane_eval = function('<SNR>' . s:SID() . '_Command__pane_eval')
  let commandObj._pane_name = function('<SNR>' . s:SID() . '_Command__pane_name')
  let commandObj.restart = function('<SNR>' . s:SID() . '_Command_restart')
  let commandObj.kill = function('<SNR>' . s:SID() . '_Command_kill')
  let commandObj.running = function('<SNR>' . s:SID() . '_Command_running')
  let commandObj.stopped = function('<SNR>' . s:SID() . '_Command_stopped')
  let commandObj.toggle = function('<SNR>' . s:SID() . '_Command_toggle')
  return commandObj
endfunction

function! s:Command_command() dict
  return call(get(self, '_command_' . self.cmd_type), [], self)
endfunction

function! s:Command__command_eval() dict
  return eval(self._command)
endfunction

function! s:Command__command_shell() dict
  return self._command
endfunction

function! s:Command_cmd_compact() dict
  return self.command()
endfunction

function! s:Command_make() dict
  let g:maque_making_command = self.name
  silent doautocmd User MaqueCommandMake
  let pane = self.pane()
  let pane.compiler = self.compiler
  let pane.nested = self.nested
  if self.copy_to_main
    call maque#set_main_command(self)
  endif
  call maque#make_pane(pane, self.command(), self.handler)
  unlet g:maque_making_command
endfunction

function! s:Command_pane() dict
  return call(get(self, '_pane_' . self.pane_type), [], self)
endfunction

function! s:Command__pane_eval() dict
  try
    return eval(self.pane_name)
  catch
    echo v:exception
    return self._pane_name
  endtry
endfunction

function! s:Command__pane_name() dict
  return maque#pane(self.pane_name)
endfunction

function! s:Command_restart() dict
  if self.kill()
    call self.make()
  endif
endfunction

function! s:Command_kill() dict
  return self.pane().kill_wait()
endfunction

function! s:Command_running() dict
  return self.pane().process_alive()
endfunction

function! s:Command_stopped() dict
  return !self.running()
endfunction

function! s:Command_toggle() dict
  let pane = self.pane()
  if pane.process_alive()
    call pane.toggle()
  else
    call self.make()
  endif
endfunction

function! maque#command#new(...)
  return call('s:CommandConstructor', a:000)
endfunction

function! s:RemoteVimConstructor(name, params)
  let remoteVimObj = {}
  let commandObj = s:CommandConstructor('', a:name, extend({'main': 0}, a:params))
  call extend(remoteVimObj, commandObj)
  let remoteVimObj.command = function('<SNR>' . s:SID() . '_RemoteVim_command')
  let remoteVimObj.cmd_compact = function('<SNR>' . s:SID() . '_RemoteVim_cmd_compact')
  let remoteVimObj.execute = function('<SNR>' . s:SID() . '_RemoteVim_execute')
  let remoteVimObj.eval = function('<SNR>' . s:SID() . '_RemoteVim_eval')
  let remoteVimObj.remote = function('<SNR>' . s:SID() . '_RemoteVim_remote')
  let remoteVimObj.launch_vim = function('<SNR>' . s:SID() . '_RemoteVim_launch_vim')
  let remoteVimObj.server_name = function('<SNR>' . s:SID() . '_RemoteVim_server_name')
  return remoteVimObj
endfunction

function! s:RemoteVim_base_command(remoteVimObj)
  return "vim --servername " . a:remoteVimObj.server_name()
endfunction

function! s:RemoteVim_command() dict
  let arg = 'let g:maque_remote = 1'
  let cmd = s:RemoteVim_base_command(self) . " --cmd " . '"' . arg . '"'
  return cmd
endfunction

function! s:RemoteVim_cmd_compact() dict
  return "remote vim " . self.server_name()
endfunction

function! s:RemoteVim_execute(cmdline) dict
  call self.remote('send', ":" . a:cmdline . "<cr>")
endfunction

function! s:RemoteVim_eval(expr) dict
  call self.remote('expr', a:expr)
endfunction

function! s:RemoteVim_remote(method, args) dict
  call self.launch_vim()
  let esc = escape(a:args, "'" . '"')
  let cmd = s:RemoteVim_base_command(self) . " --remote-" . a:method . " " . '"' . esc . '"'
  call maque#util#system(cmd)
endfunction

function! s:RemoteVim_launch_vim() dict
  let pane = self.pane()
  if type(pane) ==# type({}) && !pane.process_alive()
    echo 'maque: launching remote vim.'
    call self.make()
    call maque#util#wait_until("maque#util#server_alive('" . self.server_name() . "')", 25)
  endif
endfunction

function! s:RemoteVim_server_name() dict
  if !(has_key(self, '_server_name'))
    if self.main
      let self._server_name = v:servername
    else
      let id = maque#tmux#vim_id()
      let self._server_name = "maque_" . id . "_" . self.name
    endif
  endif
  return self._server_name
endfunction

function! maque#command#new_vim(name, args)
  return s:RemoteVimConstructor(a:name, a:args)
endfunction

function! s:MainVimConstructor()
  let mainVimObj = {}
  let remoteVimObj = s:RemoteVimConstructor('main_vim', {'pane_name': 'vim', 'main': 1})
  call extend(mainVimObj, remoteVimObj)
  let mainVimObj.server_name = function('<SNR>' . s:SID() . '_MainVim_server_name')
  return mainVimObj
endfunction

function! s:MainVim_server_name() dict
  return v:servername
endfunction

function! maque#command#new_main_vim()
  return s:MainVimConstructor()
endfunction

function! s:VimCommandConstructor(...)
  let vimCommandObj = {}
  let commandObj = call('s:CommandConstructor', a:000)
  call extend(vimCommandObj, commandObj)
  let vimCommandObj.make = function('<SNR>' . s:SID() . '_VimCommand_make')
  return vimCommandObj
endfunction

function! s:VimCommand_make() dict
  execute self.command()
endfunction

function! maque#command#new_vim_command(...)
  return call('s:VimCommandConstructor', a:000)
endfunction
