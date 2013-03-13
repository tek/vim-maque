function! maque_puppet#set_cursor_node() "{{{
  let found = searchpair('^node \zs\S\+\ze.*{', '', '^}', 'bcsW')
  if found
    let g:maque_puppet_node = expand('<cWORD>')[:-3]
    normal! g``
    return 1
  endif
endfunction "}}}

function! maque_puppet#set_makeprg() "{{{
  if maque_puppet#set_cursor_node()
    let &makeprg = 'vagrant provision '.g:maque_puppet_node
    let g:maque_puppet_makeprg_set = 1
  endif
  return exists('g:maque_puppet_makeprg_set')
endfunction "}}}

function! maque_puppet#command(cmd) "{{{
  call maque_puppet#set_cursor_node()
  if exists('g:maque_puppet_node')
    let &makeprg = printf(a:cmd, g:maque_puppet_node)
    call maque#make()
  endif
endfunction "}}}

function! maque_puppet#simple_command(name) "{{{
  let cmd = 'vagrant '.a:name.' %s'
  call maque_puppet#command(cmd)
endfunction "}}}

function! maque_puppet#provision() "{{{
  call maque_puppet#simple_command('provision')
endfunction "}}}

function! maque_puppet#recreate() "{{{
  call maque_puppet#destroy()
  call maque_puppet#up()
endfunction "}}}

function! maque_puppet#up() "{{{
  call maque_puppet#simple_command('up')
endfunction "}}}

function! maque_puppet#destroy() "{{{
  call maque_puppet#simple_command('destroy -f')
endfunction "}}}

function! maque_puppet#reload() "{{{
  call maque_puppet#simple_command('reload')
endfunction "}}}

function! maque_puppet#ssh() "{{{
  call maque_puppet#simple_command('ssh')
  call maque_tmux#send_to_tmux('sudo su -')
endfunction "}}}
