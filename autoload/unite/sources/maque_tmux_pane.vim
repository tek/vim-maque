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

" included: 'unite.riml'
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
  let maqueUniteSourceObj.init = function('<SNR>' . s:SID() . '_s:MaqueUniteSource_init')
  let maqueUniteSourceObj.close = function('<SNR>' . s:SID() . '_s:MaqueUniteSource_close')
  return maqueUniteSourceObj
endfunction

function! <SID>s:MaqueUniteSource_init() dict
  call maque#unite#map(self.actions, self.source)
endfunction

function! <SID>s:MaqueUniteSource_close() dict
  call maque#unite#unmap(self.actions, self.source)
endfunction

function! unite#sources#maque_tmux_pane#define()
  return g:unite_source_maque_tmux_pane
endfunction

let s:actions = ['kill', 'toggle', 'close', 'activate', 'parse']
function! s:TmuxPaneSourceConstructor()
  let tmuxPaneSourceObj = {}
  let maqueUniteSourceObj = g:MaqueUniteSourceConstructor('tmux_pane', 'tmux panes managed by maque', s:actions)
  call extend(tmuxPaneSourceObj, maqueUniteSourceObj)
  let tmuxPaneSourceObj.syntax = 'uniteSource__MaqueTmuxPane'
  let tmuxPaneSourceObj.gather_candidates = function('<SNR>' . s:SID() . '_s:TmuxPaneSource_gather_candidates')
  let tmuxPaneSourceObj.format_candidate = function('<SNR>' . s:SID() . '_s:TmuxPaneSource_format_candidate')
  let tmuxPaneSourceObj.init_syntax = function('<SNR>' . s:SID() . '_s:TmuxPaneSource_init_syntax')
  return tmuxPaneSourceObj
endfunction

function! <SID>s:TmuxPaneSource_gather_candidates(args, context) dict
  let longest = max(map(values(g:maque_tmux_panes), 'len(v:val.name)'))
  return map(values(g:maque_tmux_panes), 'self.format_candidate(v:val, longest)')
endfunction

function! <SID>s:TmuxPaneSource_format_candidate(pane, longest) dict
  let name = a:pane.name
  let active = name ==# g:maque_tmux_current_pane ? ' [+]' : ''
  let pad = repeat(' ', a:longest - len(name))
  let line = '[' . name . ']' . pad . '  [' . a:pane.description() . ']' . active
  return {'word': line, 'action__name': name}
endfunction

function! <SID>s:TmuxPaneSource_init_syntax() dict
  syntax match uniteSource__MaqueTmuxPane_name /\%(^\s*\[\)\@<=[^\]]\+/ 
  \ containedin=uniteSource__MaqueTmuxPane contained
  syntax match uniteSource__MaqueTmuxPane_bracket /[\[\]]/ 
  \ containedin=uniteSource__MaqueTmuxPane contained
  highlight link uniteSource__MaqueTmuxPane_name Type
  highlight link uniteSource__MaqueTmuxPane_bracket Identifier
endfunction

let g:unite_source_maque_tmux_pane = s:TmuxPaneSourceConstructor()
function! unite#sources#maque_tmux_pane#init(args, context)
  call g:unite_source_maque_tmux_pane.init()
  call g:unite_source_maque_tmux_pane.init_syntax()
endfunction

function! unite#sources#maque_tmux_pane#close(args, context)
  call g:unite_source_maque_tmux_pane.close()
endfunction
