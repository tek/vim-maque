function! s:SID()
  if exists('s:SID_VALUE')
    return s:SID_VALUE
  endif
  let s:SID_VALUE = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
  return s:SID_VALUE
endfunction

function! s:RemoteVimConstructor(name, command, params)
  let remoteVimObj = {}
  let remoteVimObj = maque#command#new('', a:params)
  let remoteVimObj.name = a:name
  let remoteVimObj.command = function('<SNR>' . s:SID() . '_s:RemoteVim_command')
  let remoteVimObj.execute = function('<SNR>' . s:SID() . '_s:RemoteVim_execute')
  let remoteVimObj.eval = function('<SNR>' . s:SID() . '_s:RemoteVim_eval')
  let remoteVimObj.remote = function('<SNR>' . s:SID() . '_s:RemoteVim_remote')
  let remoteVimObj.launch_vim = function('<SNR>' . s:SID() . '_s:RemoteVim_launch_vim')
  let remoteVimObj.server_name = function('<SNR>' . s:SID() . '_s:RemoteVim_server_name')
  return remoteVimObj
endfunction

function! <SID>s:RemoteVim_command() dict
  return "vim --servername " . self.server_name()
endfunction

function! <SID>s:RemoteVim_execute(cmdline) dict
  call self.remote('send', ":" . a:cmdline . "<cr>")
endfunction

function! <SID>s:RemoteVim_eval(expr) dict
  call self.remote('expr', a:expr)
endfunction

function! <SID>s:RemoteVim_remote(method, args) dict
  call self.launch_vim()
  let esc = escape(a:args, "'" . '"')
  let cmd = self.command() . " --remote-" . a:method . " " . '"' . esc . '"'
  call maque#util#system(cmd)
endfunction

function! <SID>s:RemoteVim_launch_vim() dict
  let pane = self.pane()
  if type(pane) ==# type({}) && !pane.process_alive()
    echo 'maque: launching remote vim.'
    call self.make()
    call maque#util#wait_until("maque#util#server_alive('" . self.server_name() . "')", 25)
  endif
endfunction

function! <SID>s:RemoteVim_server_name() dict
  if !(has_key(self, '_server_name'))
    let id = maque#tmux#vim_id()
    let self._server_name = "maque_" . id . "_" . self.name
  endif
  return self._server_name
endfunction

function! maque#command#vim#new(name, command, args)
  return s:RemoteVimConstructor(a:name, a:command, a:args)
endfunction

