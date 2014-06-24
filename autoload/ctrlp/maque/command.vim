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
  nnoremap <buffer> <silent> <c-r> :<c-u>call ctrlp#maque#command#restart()<cr>
  nnoremap <buffer> <silent> <c-d> :<c-u>call ctrlp#maque#command#kill()<cr>
  nnoremap <buffer> <silent> <c-s> :<c-u>call ctrlp#maque#command#set_main()<cr>
  return map(keys(g:maque_commands), 's:format(v:val)')
endfunction "}}}

function! ctrlp#maque#command#accept(mode, str) "{{{
  let matches = matchlist(a:str, '\[\([^\]]\+\)')
  if len(matches)
    let name = matches[1]
    if a:mode == 'e'
      call ctrlp#exit()
      call maque#make_command(name)
    elseif a:mode == 'r'
      call ctrlp#exit()
      call maque#async('maque#restart_command', name)
    elseif a:mode == 'd'
      call maque#kill_command(name)
      call ctrlp#exit()
    elseif a:mode == 's'
      call maque#set_main_command_name(name)
      call ctrlp#exit()
      echo 'Selected command "'.name.'" for the main pane.'
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

function! ctrlp#maque#command#restart() "{{{
  call ctrlp#call('<SID>AcceptSelection', ['r'])
endfunction "}}}

function! ctrlp#maque#command#kill() "{{{
  call ctrlp#call('<SID>AcceptSelection', ['d'])
endfunction "}}}

function! ctrlp#maque#command#set_main() "{{{
  call ctrlp#call('<SID>AcceptSelection', ['s'])
endfunction "}}}
