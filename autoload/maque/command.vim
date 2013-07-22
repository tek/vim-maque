function! maque#command#new(command, ...) "{{{
  let params = a:0 ? a:1 : {}
  let command = {
        \ '_command': a:command,
        \ '_pane': get(params, 'pane', 'main')
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
    call pane.create()
    return pane.make(self.command())
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

  return command
endfunction "}}}
