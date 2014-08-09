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

function! unite#filters#exclude_panes#define()
  return g:maque_unite_filter_exclude_panes
endfunction

function! unite#filters#exclude_panes#ignore(candidate)
  return index(g:maque_unite_tmux_pane_ignore, a:candidate.action__name) ==# -1
endfunction

function! s:ExcludePanesConstructor()
  let excludePanesObj = {}
  let excludePanesObj.name = 'exclude_panes'
  let excludePanesObj.description = 'Exclude panes given in g:maque_unite_tmux_pane_ignore'
  let excludePanesObj.filter = function('<SNR>' . s:SID() . '_ExcludePanes_filter')
  return excludePanesObj
endfunction

function! s:ExcludePanes_filter(candidates, context) dict
  return filter(a:candidates, 'unite#filters#exclude_panes#ignore(v:val)')
endfunction

let g:maque_unite_filter_exclude_panes = s:ExcludePanesConstructor()
