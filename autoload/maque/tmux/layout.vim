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

function! s:LayoutConstructor(name, args)
  let layoutObj = {}
  let layoutObj.name = a:name
  let layoutObj.panes = []
  let layoutObj.direction = get(a:args, 'direction', 'vertical')
  let layoutObj.layout = 0
  let layoutObj.size = get(a:args, 'size')
  let layoutObj.add = function('<SNR>' . s:SID() . '_s:Layout_add')
  let layoutObj.create = function('<SNR>' . s:SID() . '_s:Layout_create')
  let layoutObj.create_pane = function('<SNR>' . s:SID() . '_s:Layout_create_pane')
  let layoutObj.pack = function('<SNR>' . s:SID() . '_s:Layout_pack')
  let layoutObj.open = function('<SNR>' . s:SID() . '_s:Layout_open')
  let layoutObj.focus = function('<SNR>' . s:SID() . '_s:Layout_focus')
  let layoutObj.set_size = function('<SNR>' . s:SID() . '_s:Layout_set_size')
  let layoutObj.splitter = function('<SNR>' . s:SID() . '_s:Layout_splitter')
  let layoutObj.creator = function('<SNR>' . s:SID() . '_s:Layout_creator')
  let layoutObj.in_layout = function('<SNR>' . s:SID() . '_s:Layout_in_layout')
  let layoutObj.determine_id = function('<SNR>' . s:SID() . '_s:Layout_determine_id')
  let layoutObj.post_create = function('<SNR>' . s:SID() . '_s:Layout_post_create')
  return layoutObj
endfunction

function! s:Layout_open_panes(layoutObj)
  let panes = []
  for pane in a:layoutObj.panes
    if pane.open()
      call add(panes, pane)
    endif
  endfor
  return panes
endfunction

function! <SID>s:Layout_add(pane) dict
  call add(self.panes, a:pane)
  let a:pane.layout = self
endfunction

function! <SID>s:Layout_create() dict
  if self.in_layout()
    call self.layout.create_pane(self)
  else
    call maque#tmux#command_output(self.creator())
  endif
endfunction

function! <SID>s:Layout_create_pane(pane) dict
  let panes_before = maque#tmux#pane#all()
  if self.open()
    call self.focus()
    call maque#tmux#command_output(self.splitter())
    call maque#tmux#pane('vim').focus()
  else
    call self.create()
  endif
  call a:pane.determine_id(panes_before)
  call a:pane.post_create()
  call self.pack()
endfunction

function! <SID>s:Layout_pack() dict
  for pane in self.panes
    call pane.set_size()
  endfor
endfunction

function! <SID>s:Layout_open() dict
  return !empty(s:Layout_open_panes(self))
endfunction

function! <SID>s:Layout_focus() dict
  if self.open()
    let pane = s:Layout_open_panes(self)[0]
    call pane.focus()
  endif
endfunction

function! <SID>s:Layout_set_size() dict
endfunction

function! <SID>s:Layout_splitter() dict
  return self.direction ==# 'vertical' ? 'splitw -v -d' : 'splitw -h -d'
endfunction

function! <SID>s:Layout_creator() dict
  return self.direction ==# 'vertical' ? 'splitw -h -d' : 'splitw -v -d'
endfunction

function! <SID>s:Layout_in_layout() dict
  return type(self.layout) !=# type(0)
endfunction

function! <SID>s:Layout_determine_id(...) dict
endfunction

function! <SID>s:Layout_post_create() dict
endfunction

function! maque#tmux#layout#new(name, args)
  return s:LayoutConstructor(a:name, a:args)
endfunction
