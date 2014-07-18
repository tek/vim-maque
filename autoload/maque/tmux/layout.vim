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
  let attrs = {'_original_size': [0, 0], 'minimized': 0, 'minimized_size': 2, 'minimize_on_toggle': get(g:, 'maque_tmux_minimize_on_toggle', 0), 'focus_on_restore': 0, 'vertical': 1}
  call extend(attrs, params)
  let attrs.minimized_size = max([attrs.minimized_size, 2])
  call extend(viewObj, attrs)
  let viewObj.toggle = function('<SNR>' . s:SID() . '_View_toggle')
  let viewObj.toggle_minimized = function('<SNR>' . s:SID() . '_View_toggle_minimized')
  let viewObj.minimize = function('<SNR>' . s:SID() . '_View_minimize')
  let viewObj.restore = function('<SNR>' . s:SID() . '_View_restore')
  let viewObj._apply_size = function('<SNR>' . s:SID() . '_View__apply_size')
  let viewObj._vertical = function('<SNR>' . s:SID() . '_View__vertical')
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
    call self._apply_size(self.minimized_size)
    let self.minimized = 1
  endif
endfunction

function! s:View_restore() dict
  if self.open() && self.minimized
    call self.resize(self._original_size[0], self._original_size[1])
    let self.minimized = 0
    if self.focus_on_restore
      call self.focus()
    endif
  endif
endfunction

function! s:View__apply_size(size) dict
  if self._vertical()
    call self.resize(self._original_size[0], a:size)
  else
    call self.resize(a:size, self._original_size[1])
  endif
endfunction

function! s:View__vertical() dict
  if self.in_layout()
    return self.layout.direction ==# 'vertical'
  else
    return self.vertical
  endif
endfunction

function! s:LayoutConstructor(name, args)
  let layoutObj = {}
  let viewObj = g:ViewConstructor(a:name, a:args)
  call extend(layoutObj, viewObj)
  let layoutObj.panes = []
  let layoutObj.direction = get(a:args, 'direction', 'vertical')
  let layoutObj.layout = 0
  let layoutObj.size = get(a:args, 'size')
  let layoutObj.add = function('<SNR>' . s:SID() . '_Layout_add')
  let layoutObj.create = function('<SNR>' . s:SID() . '_Layout_create')
  let layoutObj.create_pane = function('<SNR>' . s:SID() . '_Layout_create_pane')
  let layoutObj.pack = function('<SNR>' . s:SID() . '_Layout_pack')
  let layoutObj.close = function('<SNR>' . s:SID() . '_Layout_close')
  let layoutObj.open = function('<SNR>' . s:SID() . '_Layout_open')
  let layoutObj.focus = function('<SNR>' . s:SID() . '_Layout_focus')
  let layoutObj.split = function('<SNR>' . s:SID() . '_Layout_split')
  let layoutObj.set_size = function('<SNR>' . s:SID() . '_Layout_set_size')
  let layoutObj.current_size = function('<SNR>' . s:SID() . '_Layout_current_size')
  let layoutObj.resize = function('<SNR>' . s:SID() . '_Layout_resize')
  let layoutObj.splitter = function('<SNR>' . s:SID() . '_Layout_splitter')
  let layoutObj.creator = function('<SNR>' . s:SID() . '_Layout_creator')
  let layoutObj.in_layout = function('<SNR>' . s:SID() . '_Layout_in_layout')
  let layoutObj.determine_id = function('<SNR>' . s:SID() . '_Layout_determine_id')
  let layoutObj.post_create = function('<SNR>' . s:SID() . '_Layout_post_create')
  let layoutObj.create_kids = function('<SNR>' . s:SID() . '_Layout_create_kids')
  let layoutObj.create_and_wait = function('<SNR>' . s:SID() . '_Layout_create_and_wait')
  let layoutObj.ref_pane = function('<SNR>' . s:SID() . '_Layout_ref_pane')
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

function! s:Layout_add(pane) dict
  call add(self.panes, a:pane)
  let a:pane.layout = self
endfunction

function! s:Layout_create() dict
  if !(self.open())
    if self.in_layout() && len(self.panes) ># 0
      call self.layout.create_pane(self.panes[0])
    else
      call maque#tmux#command_output(self.creator())
    endif
  endif
endfunction

function! s:Layout_create_pane(pane) dict
  if self.in_layout()
    call self.layout.create_kids()
  endif
  let panes_before = maque#tmux#pane#all()
  if !(a:pane.open())
    if self.open()
      call self.focus()
      call self.split(a:pane)
      call maque#tmux#pane('vim').focus()
    else
      call self.create()
    endif
    call a:pane.determine_id(panes_before)
    call a:pane.post_create()
    call self.pack()
  endif
endfunction

function! s:Layout_pack() dict
  for pane in self.panes
    call pane.set_size()
  endfor
endfunction

function! s:Layout_close() dict
  for pane in s:Layout_open_panes(self)
    call pane.close()
  endfor
endfunction

function! s:Layout_open() dict
  return !empty(s:Layout_open_panes(self))
endfunction

function! s:Layout_focus() dict
  if self.open()
    let pane = s:Layout_open_panes(self)[0]
    call pane.focus()
  endif
endfunction

function! s:Layout_split(pane) dict
  let splitter = self.splitter() . a:pane.splitter_params()
  call maque#tmux#command_output(splitter)
endfunction

function! s:Layout_set_size() dict
  if self.open()
    call self.ref_pane().set_size()
  endif
endfunction

function! s:Layout_current_size() dict
  if self.open()
    return self.ref_pane().current_size()
  else
    return [0, 0]
  endif
endfunction

function! s:Layout_resize(width, height) dict
  if self.open()
    call self.ref_pane().resize(a:width, a:height)
  endif
endfunction

function! s:Layout_splitter() dict
  return self.direction ==# 'vertical' ? 'splitw -v -d' : 'splitw -h -d'
endfunction

function! s:Layout_creator() dict
  return self.direction ==# 'vertical' ? 'splitw -h -d' : 'splitw -v -d'
endfunction

function! s:Layout_in_layout() dict
  return type(self.layout) !=# type(0)
endfunction

function! s:Layout_determine_id(...) dict
endfunction

function! s:Layout_post_create() dict
endfunction

function! s:Layout_create_kids() dict
  for pane in self.panes
    if !(pane.open())
      call pane.create_and_wait()
    endif
  endfor
endfunction

function! s:Layout_create_and_wait(...) dict
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let timeout = remove(__splat_var_cpy, 0)
  else
    let timeout = 5
  endif
  call self.create()
  let counter = 0
  while (!self.open()) && (counter <# timeout * 10)
    sleep 100m
    let counter += 1
  endwhile
endfunction

function! s:Layout_ref_pane() dict
  return self.panes[0]
endfunction

function! maque#tmux#layout#new(name, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let args = remove(__splat_var_cpy, 0)
  else
    let args = {}
  endif
  return s:LayoutConstructor(a:name, args)
endfunction
