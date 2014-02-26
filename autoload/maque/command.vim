function! maque#command#new(command, ...) "{{{
  let params = a:0 ? a:1 : {}
  let command = {
        \ '_command': a:command,
        \ '_pane': get(params, 'pane', 'main'),
        \ 'handler': g:maque_handler,
        \ }
  let cmd_type = get(params, 'type', 'shell')
  if cmd_type == 'eval'

    function! command.command() dict "{{{
      return eval(self._command)
    endfunction "}}}

  else

    function! command.command() dict "{{{
      return self._command
    endfunction "}}}

  endif

  function! command.make() dict "{{{
    let pane = self.pane()
    call maque#make_pane(pane, self.command(), self.handler)
  endfunction "}}}

  let pane_type = get(params, 'ptype', 'name')
  if pane_type == 'eval'

    function! command.pane() dict "{{{
      try
        return eval(self._pane)
      catch
        echo v:exception
        return maque#pane(self._pane)
      endtry
    endfunction "}}}

  else

    function! command.pane() dict "{{{
      return maque#pane(self._pane)
    endfunction "}}}

  endif

  function! command.restart() dict "{{{
    if self.pane().kill_wait()
      call self.make()
    endif
  endfunction "}}}

  function! command.kill() dict "{{{
    call self.pane().kill()
  endfunction "}}}

  return command
endfunction "}}}
