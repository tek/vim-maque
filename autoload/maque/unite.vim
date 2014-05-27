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

function! s:key(action, source)
  return eval('g:maque_unite_' . a:source . '_mapping_' . a:action)
endfunction

function! maque#unite#unmap(actions, source)
  if eval('g:maque_unite_' . a:source . '_mappings')
    for action in a:actions
      execute 'nunmap <buffer> ' . s:key(action, a:source)
    endfor
  endif
endfunction

function! s:map_key(action, source)
  let comm = 'nmap <expr><silent><buffer> ' . s:key(a:action, a:source) . ' unite#do_action("' . a:action . '")'
  execute comm
endfunction

function! maque#unite#map(actions, source)
  if eval('g:maque_unite_' . a:source . '_mappings')
    for action in a:actions
      call s:map_key(action, a:source)
    endfor
  endif
endfunction

function! g:MaqueUniteSourceConstructor(source, description, actions)
  let maqueUniteSourceObj = {}
  let maqueUniteSourceObj.source = a:source
  let maqueUniteSourceObj.description = a:description
  let maqueUniteSourceObj.actions = a:actions
  let maqueUniteSourceObj.name = 'maque_' . a:source
  let maqueUniteSourceObj.default_kind = maqueUniteSourceObj.name
  let maqueUniteSourceObj.hooks = {'on_syntax': 'unite#sources#' . maqueUniteSourceObj.name . '#init', 'on_close': 'unite#sources#' . maqueUniteSourceObj.name . '#close'}
  let maqueUniteSourceObj.init = function('<SNR>' . s:SID() . '_MaqueUniteSource_init')
  let maqueUniteSourceObj.close = function('<SNR>' . s:SID() . '_MaqueUniteSource_close')
  return maqueUniteSourceObj
endfunction

function! s:MaqueUniteSource_init() dict
  call maque#unite#map(self.actions, self.source)
endfunction

function! s:MaqueUniteSource_close() dict
  call maque#unite#unmap(self.actions, self.source)
endfunction
