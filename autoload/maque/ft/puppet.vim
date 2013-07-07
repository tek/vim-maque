function! maque#ft#puppet#set_cursor_node() "{{{
  let found = searchpair('^node \zs\S\+\ze.*{', '', '^}', 'bcsW')
  if found
    let g:maque_puppet_node = expand('<cWORD>')
    if g:maque_puppet_node[-2:] == 'vm'
      let g:maque_puppet_node = g:maque_puppet_node[:-3]
    endif
    normal! g``
    return 1
  endif
endfunction "}}}

function! maque#ft#puppet#reset_makeprg() "{{{
  call maque#set_params('provision '.g:maque_puppet_node)
  let g:maque_makeprg_set = 1
endfunction "}}}

function! maque#ft#puppet#set_makeprg() "{{{
  if exists('g:maque_puppet_node')
    call maque#ft#puppet#reset_makeprg()
  endif
  return g:maque_makeprg_set
endfunction "}}}

function! maque#ft#puppet#user_query_node() "{{{
  let g:maque_puppet_node = input('Node name: ')
  call maque#ft#puppet#reset_makeprg()
endfunction "}}}

function! maque#ft#puppet#command(cmd) "{{{
  call maque#ft#puppet#set_cursor_node()
  if exists('g:maque_puppet_node')
    call maque#set_params(printf(a:cmd, g:maque_puppet_node))
    call maque#make()
  endif
endfunction "}}}

function! maque#ft#puppet#simple_command(name) "{{{
  let cmd = a:name.' %s'
  call maque#ft#puppet#command(cmd)
endfunction "}}}

function! maque#ft#puppet#provision() "{{{
  call maque#ft#puppet#simple_command('provision')
endfunction "}}}

function! maque#ft#puppet#recreate() "{{{
  call maque#ft#puppet#destroy()
  call maque#ft#puppet#up()
endfunction "}}}

function! maque#ft#puppet#up() "{{{
  call maque#ft#puppet#simple_command('up')
endfunction "}}}

function! maque#ft#puppet#destroy() "{{{
  call maque#ft#puppet#simple_command('destroy -f')
endfunction "}}}

function! maque#ft#puppet#reload() "{{{
  call maque#ft#puppet#simple_command('reload')
endfunction "}}}

function! maque#ft#puppet#ssh() "{{{
  call maque#ft#puppet#simple_command('ssh')
  call maque#make_tmux('sudo su -')
endfunction "}}}
