function! s:SID()
  if exists('s:SID_VALUE')
    return s:SID_VALUE
  endif
  let s:SID_VALUE = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
  return s:SID_VALUE
endfunction

function! s:LayoutConstructor(name, args)
  let layoutObj = {}
  let layoutObj.name = a:name
  let layoutObj.panes = []
  let layoutObj.direction = get(a:args, 'direction', 'vertical')
  let layoutObj.add = function('<SNR>' . s:SID() . '_s:Layout_add')
  let layoutObj.create = function('<SNR>' . s:SID() . '_s:Layout_create')
  let layoutObj.create_pane = function('<SNR>' . s:SID() . '_s:Layout_create_pane')
  let layoutObj.pack = function('<SNR>' . s:SID() . '_s:Layout_pack')
  let layoutObj.open = function('<SNR>' . s:SID() . '_s:Layout_open')
  let layoutObj.focus = function('<SNR>' . s:SID() . '_s:Layout_focus')
  let layoutObj.splitter = function('<SNR>' . s:SID() . '_s:Layout_splitter')
  let layoutObj.creator = function('<SNR>' . s:SID() . '_s:Layout_creator')
  let layoutObj._open_panes = function('<SNR>' . s:SID() . '_s:Layout__open_panes')
  return layoutObj
endfunction

function! <SID>s:Layout_add(pane) dict
  call add(self.panes, a:pane)
  let a:pane.layout = self
endfunction

function! <SID>s:Layout_create() dict
  call maque#tmux#command_output(self.creator())
endfunction

function! <SID>s:Layout_create_pane(pane) dict
  let panes_before = maque#tmux#pane#all()
  if self.open()
    echom 'open'
    call self.focus()
    call maque#tmux#command_output(self.splitter())
    call maque#tmux#pane('vim').focus()
  else
    echom 'creating'
    call self.create()
  endif
  call a:pane.determine_id(panes_before)
  call a:pane.post_create()
  let panes = self._open_panes()
endfunction

function! <SID>s:Layout_pack() dict
endfunction

function! <SID>s:Layout_open() dict
  return len(self._open_panes()) ># 0
endfunction

function! <SID>s:Layout_focus() dict
  if self.open()
    let pane = self._open_panes()[0]
    call pane.focus()
  endif
endfunction

function! <SID>s:Layout_splitter() dict
  return self.direction ==# 'vertical' ? 'splitw -v -d' : 'splitw -h -d'
endfunction

function! <SID>s:Layout_creator() dict
  return self.direction ==# 'vertical' ? 'splitw -h -d' : 'splitw -v -d'
endfunction

function! <SID>s:Layout__open_panes() dict
  let panes = []
  for pane in self.panes
    if pane.open()
      call add(panes, pane)
    endif
  endfor
  return panes
endfunction

function! maque#tmux#layout#new(name, args)
  return s:LayoutConstructor(a:name, a:args)
endfunction

