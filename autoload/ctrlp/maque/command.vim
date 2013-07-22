call add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlp#maque#command#init()',
  \ 'accept': 'ctrlp#maque#command#accept',
  \ 'lname': 'maque',
  \ 'sname': 'mq',
  \ 'enter': 'ctrlp#maque#command#enter()',
  \ 'exit': 'ctrlp#maque#command#exit()',
  \ 'type': 'maque_cmd',
  \ 'sort': 0,
  \ 'nolim': 1,
  \ })

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

function! s:format(name) "{{{
  let cmd = g:maque_commands[a:name]
  let pane = cmd.pane()
  return '['.a:name .']  '.cmd.command() .'  ['.pane.description() .']'
endfunction "}}}

function! ctrlp#maque#command#init() "{{{
  return map(keys(g:maque_commands), 's:format(v:val)')
endfunction "}}}

function! ctrlp#maque#command#accept(mode, str) "{{{
  let matches = matchlist(a:str, '\s*\(\w\+\)')
  if len(matches)
    let name = matches[1]
    if a:mode == 'e'
      call ctrlp#exit()
      call g:maque_commands[name].make()
    endif
  endif
endfunction "}}}

function! ctrlp#maque#command#id() "{{{
  return s:id
endfunction "}}}

function! ctrlp#maque#command#enter() "{{{
endfunction "}}}

function! ctrlp#maque#command#exit() "{{{
endfunction "}}}
