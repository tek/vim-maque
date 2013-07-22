call add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlp#maque#tmux#init()',
  \ 'accept': 'ctrlp#maque#tmux#accept',
  \ 'lname': 'maque_tmux',
  \ 'sname': 'mqtm',
  \ 'enter': 'ctrlp#maque#tmux#enter()',
  \ 'exit': 'ctrlp#maque#tmux#exit()',
  \ 'type': 'tmux_pane',
  \ 'sort': 0,
  \ 'nolim': 1,
  \ })

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

function! s:format(pane) "{{{
  let active = a:pane.name == g:maque#tmux#current_pane ? '[+]' : ''
  return a:pane.name .' '.active
endfunction "}}}

function! ctrlp#maque#tmux#init() "{{{
  nnoremap <buffer> <silent> <c-y> :<c-u>call ctrlp#maque#tmux#create_pane()<cr>
  nnoremap <buffer> <silent> <c-e> :<c-u>call ctrlp#maque#tmux#read_errors()<cr>
  let panes = values(g:maque#tmux#panes)
  return map(panes, 's:format(v:val)')
endfunction "}}}

function! ctrlp#maque#tmux#accept(mode, str) "{{{
  let matches = matchlist(a:str, '\(\w\+\)', )
  if len(matches)
    let name = matches[1]
    let pane = g:maque#tmux#panes[name]
    if a:mode == 'e'
      call ctrlp#exit()
      let g:maque#tmux#current_pane = name
      echo 'set "'.name.'" as active pane.'
    elseif a:mode == 't'
      call pane.toggle()
    elseif a:mode == 'k'
      call pane.kill()
    elseif a:mode == 'r'
      call ctrlp#exit()
      call maque#tmux#parse(name)
    end
  endif
endfunction "}}}

function! ctrlp#maque#tmux#id() "{{{
  return s:id
endfunction "}}}

function! ctrlp#maque#tmux#enter() "{{{
endfunction "}}}

function! ctrlp#maque#tmux#exit() "{{{
endfunction "}}}

function! ctrlp#maque#tmux#create_pane() "{{{
  let params = split(ctrlp#call('<SID>getinput'))
  call insert(params, 0, 1)
  call call('maque#tmux#add_pane', params)
  call ctrlp#exit()
  call ctrlp#init(ctrlp#maque#tmux#id())
endfunction "}}}

function! ctrlp#maque#tmux#read_errors() "{{{
  call ctrlp#call('<SID>AcceptSelection', ['r'])
endfunction "}}}
